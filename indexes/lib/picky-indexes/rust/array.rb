require 'fiddle'  
require 'fiddle/import'

module FunctionMapping
  
  attr_reader :func_map
  
  AS_OBJ = :as_obj
  
  def __func__ from, external, internal, retval, *params
    class_method = external.to_s.match(/\Aself\./)
    relative = class_method ? '' : 'self.class.'
    params = class_method ? params : params.unshift(Fiddle::TYPE_VOIDP)
    # params.map! { |param| param == AS_OBJ ? Fiddle::TYPE_VOIDP : '' }
    
    func = Fiddle::Function.new(
      from[internal.to_s],
      params,
      retval == AS_OBJ ? Fiddle::TYPE_VOIDP : retval
    )
    @func_map ||= {}
    @func_map[internal] = func
    
    [func, class_method, relative, retval]
  end
  
  def __func_impl__ from, external, internal, retval, *params
    func, class_method, relative, retval = __func__(from, external, internal, retval, *params)
    
    # Get the right error position.
    begin
      /^(.+?):(\d+)/ =~ caller.first
      file, line = $1, $2.to_i
    rescue
      file, line = __FILE__, __LINE__+4
    end
    
    # Map external interface to C interface.
    module_eval(<<-EOS, file, line)
      def #{external}(*args, &block)
        # p [:calling, :'#{external}', @internal_instance, args]
        f = #{relative}func_map[:'#{internal}']
        # p f
        #{
        if class_method
          # puts "Installing #{relative}#{external}(#{params.join(',')})."
          'res = f.call(*args,&block)'
        else
          # puts "Installing #{external}(#{params.join(',')})."
          "res = f.call(@internal_instance,*args,&block)"
        end
        }
        #{
        if retval == AS_OBJ
          'res = self.class.from_ptr(res)'
        end
        }
        #{
        # Could it be null?
        if retval == Fiddle::TYPE_VOIDP
          'if res.null?; res = nil; end'
        end
        }
        res
      end
    EOS
    func
  end
  
end

module Rust  
  class Array
    extend FunctionMapping

    pr = Fiddle.dlopen File.expand_path('../../libpicky_rust.dylib', __FILE__)

    def initialize pointer = nil
      @internal_instance = pointer || self.class.new_rust
      ObjectSpace.define_finalizer(self, self.class.releaser_for(@internal_instance))
    end
    
    def self.releaser_for internal_instance
      proc { internal_instance.free }
    end
    
    def to_ptr
      @internal_instance
    end
    
    def self.from_ptr pointer
      new(pointer)
    end

    # TODO Freeing!
    # TODO Add RUBY_OBJECT type which automatically calls its #to_ptr.
    # TODO Add RUBY_OBJECT type which automatically calls this class' #from_ptr.

    __func_impl__ pr, :'self.new_rust', :rust_array_new, Fiddle::TYPE_VOIDP
    # __func_impl__ pr, :free, :rust_array_free, Fiddle::TYPE_VOIDP
    
    __func_impl__ pr, :<<,  :rust_array_append, FunctionMapping::AS_OBJ, Fiddle::TYPE_SHORT
    __func_impl__ pr, :unshift, :rust_array_unshift, FunctionMapping::AS_OBJ, Fiddle::TYPE_SHORT
    
    __func_impl__ pr, :+, :rust_array_plus, FunctionMapping::AS_OBJ, Fiddle::TYPE_VOIDP
    __func__ pr, :-, :rust_array_minus, FunctionMapping::AS_OBJ, Fiddle::TYPE_VOIDP
    def -(other)
      # TODO dup ?
      return self if other.size.zero?
      
      self.class.from_ptr(self.class.func_map[:rust_array_minus].call(to_ptr, other))
    end
    
    __func_impl__ pr, :intersect, :rust_array_intersect, FunctionMapping::AS_OBJ, Fiddle::TYPE_VOIDP
    __func_impl__ pr, :'slice!', :rust_array_slice_bang, FunctionMapping::AS_OBJ, Fiddle::TYPE_SIZE_T, Fiddle::TYPE_SIZE_T
    
    __func_impl__ pr, :first, :rust_array_first, Fiddle::TYPE_SHORT
    __func_impl__ pr, :last, :rust_array_last, Fiddle::TYPE_SHORT
    
    __func_impl__ pr, :length, :rust_array_length, Fiddle::TYPE_SIZE_T
    alias size length
    
    __func__ pr, :'sort_by!', :rust_array_sort_by_bang, FunctionMapping::AS_OBJ, Fiddle::TYPE_VOIDP
    def sort_by! &block
      return self unless block_given?
      
      cb = Fiddle::Closure::BlockCaller.new(Fiddle::TYPE_INT, [Fiddle::TYPE_INT], &block)
      block_func = Fiddle::Function.new(cb, [Fiddle::TYPE_INT], Fiddle::TYPE_INT)
      
      pointer = self.class.func_map[:rust_array_sort_by_bang].call(to_ptr, block_func)
      self.class.from_ptr(pointer)
    end
    
    __func__ pr, :==, :rust_array_eq, Fiddle::TYPE_CHAR, Fiddle::TYPE_VOIDP
    def == other
      # return false if other.class
      
      self.class.func_map[:rust_array_eq].call(to_ptr, other) == 1
    end
    
    __func__ pr, :empty?, :rust_array_empty, Fiddle::TYPE_CHAR # aka BOOL
    def empty?
      self.class.func_map[:rust_array_empty].call(to_ptr) == 1
    end
    
    __func__ pr, :include?, :rust_array_include, Fiddle::TYPE_CHAR, Fiddle::TYPE_VOIDP
    def include? item
      self.class.func_map[:rust_array_include].call(to_ptr, item) == 1
    end
    
    __func__ pr, :shift, :rust_array_shift, Fiddle::TYPE_SHORT
    __func__ pr, :shift, :rust_array_shift_amount, Fiddle::TYPE_VOIDP, Fiddle::TYPE_SIZE_T
    
    def shift(amount = nil)
      if amount
        pointer = self.class.func_map[:rust_array_shift_amount].call(to_ptr, amount)
        self.class.from_ptr(pointer)
      else
        self.class.func_map[:rust_array_shift].call(to_ptr)
      end
    end
    
    __func__ pr, :dup, :rust_array_dup, Fiddle::TYPE_VOIDP
    def dup
      self.class.from_ptr(self.class.func_map[:rust_array_dup].call(to_ptr))
    end
    
    __func__ pr, :inspect, :rust_array_inspect, Fiddle::TYPE_VOIDP
    def inspect
      self.class.func_map[:rust_array_inspect].call(to_ptr).to_s
    end
  end
end

# require 'ffi'
#
# module Rust
#   class ArrayPointer < FFI::AutoPointer
#     def self.release(ptr)
#       Array.free(ptr)
#     end
#
#     def append(item)
#       Array.append(self, item)
#     end
#     alias << append
#
#     def unshift(item)
#       Array.unshift(self, item)
#     end
#
#     def intersect(other)
#       Array.intersect(self, other)
#     end
#
#     def slice!(offset, amount)
#       Array.slice_bang(self, offset, amount)
#     end
#
#     def first
#       Array.first(self)
#     end
#
#     def last
#       Array.last(self)
#     end
#
#     def length
#       Array.length(self)
#     end
#     alias size length
#   end
#   class Array
#     extend FFI::Library
#     ffi_lib 'picky_rust'
#
#     attach_function :new,  :rust_array_new,  [],             ArrayPointer
#     attach_function :free, :rust_array_free, [ArrayPointer], :void
#
#     attach_function :append,  :rust_array_append,  [ArrayPointer, :uint16], :uint16
#     attach_function :unshift, :rust_array_unshift, [ArrayPointer, :uint16], :uint16
#
#     attach_function :intersect,  :rust_array_intersect,  [ArrayPointer, ArrayPointer],     ArrayPointer
#     attach_function :slice_bang, :rust_array_slice_bang, [ArrayPointer, :size_t, :size_t], ArrayPointer
#
#     attach_function :first, :rust_array_first, [ArrayPointer], :uint16
#     attach_function :last,  :rust_array_last,  [ArrayPointer], :uint16
#
#     attach_function :length, :rust_array_length, [ArrayPointer], :size_t
#   end
#
#   class HashPointer < FFI::AutoPointer
#     def self.release(ptr)
#       Hash.free(ptr)
#     end
#
#     # def append_to(key, value)
#     #   Hash.append_to(self, key, value)
#     # end
#
#     def set(key, value)
#       Hash.set(self, key, value)
#     end
#     alias []= set
#
#     def get(key)
#       result = Hash.get(self, key)
#       return nil if result.address.zero?
#       result
#     end
#     alias [] get
#
#     def length
#       Hash.length(self)
#     end
#     alias size length
#   end
#   class Hash
#     extend FFI::Library
#     ffi_lib 'picky_rust'
#
#     attach_function :new,  :rust_hash_new, [], HashPointer
#     attach_function :free, :rust_hash_free, [HashPointer], :void
#
#     # Special function.
#     # attach_function :append_to, :rust_hash_append_to, [HashPointer, :string, :uint16], :uint16
#
#     attach_function :get, :rust_hash_get, [HashPointer, :string], ArrayPointer
#     attach_function :set, :rust_hash_set, [HashPointer, :string, ArrayPointer], ArrayPointer
#
#     attach_function :length, :rust_hash_length, [HashPointer], :size_t
#   end
# end