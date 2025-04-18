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
    
    # Get the right error position.
    begin
      /^(.+?):(\d+)/ =~ caller.first
      file, line = $1, $2.to_i
    rescue
      file, line = __FILE__, __LINE__+3
    end
    # Map external interface to C interface.
    module_eval(<<-EOS, file, line)
      def #{external}(*args, &block)
        # p [:calling, :'#{external}', @internal_instance, args]
        f = #{relative}func_map[:'#{internal}']
        # p f
        #{
        if class_method
          puts "Installing #{relative}#{external}(#{params.join(',')})."
          'res = f.call(*args,&block)'
        else
          puts "Installing #{external}(#{params.join(',')})."
          'res = f.call(@internal_instance,*args,&block)'
        end
        }
        #{
        if retval == AS_OBJ
          'res = self.class.from_ptr(res)'
        end
        }
        # p res
        res
      end
    EOS
    func
  end
  
end

module Rust  
  class Array
    extend FunctionMapping

    pr = Fiddle.dlopen File.expand_path('../target/release/libpicky_rust.dylib', __dir__)

    def initialize pointer = nil
      @internal_instance = pointer || self.class.new_rust
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

    __func__ pr, :'self.new_rust', :rust_array_new,  Fiddle::TYPE_VOIDP
    __func__ pr, :free, :rust_array_free, Fiddle::TYPE_VOIDP
    
    __func__ pr, :append,  :rust_array_append, Fiddle::TYPE_INT, Fiddle::TYPE_INT
    __func__ pr, :shift, :rust_array_shift, Fiddle::TYPE_INT
    
    __func__ pr, :intersect, :rust_array_intersect, FunctionMapping::AS_OBJ, Fiddle::TYPE_VOIDP
    __func__ pr, :'slice!', :rust_array_slice_bang, FunctionMapping::AS_OBJ, Fiddle::TYPE_SIZE_T, Fiddle::TYPE_SIZE_T
    
    __func__ pr, :first, :rust_array_first, Fiddle::TYPE_INT
    __func__ pr, :last, :rust_array_last, Fiddle::TYPE_INT
    
    __func__ pr, :length, :rust_array_length, Fiddle::TYPE_INT
    
    __func__ pr, :inspect, :rust_array_inspect, Fiddle::TYPE_VOIDP
    
    alias << append
    alias size length
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