require 'ffi'
# require 'ffi/autopointer'

module Rust
  
  module ArrayBackend
    extend FFI::Library
  
    ffi_lib File.expand_path('../../libpicky_rust.dylib', __FILE__) # FFI::Library::LIBC
  
    attach_function :rust_array_new, [], :pointer
  
    callback :rust_array_sort_by_bang_callback, [:uint16], :int32
    callback :rust_array_reject_callback,       [:uint16], :bool
    callback :rust_array_each_callback,         [:uint16], :void
  
    attach_function :rust_array_append,       [:pointer, :uint16],          :pointer
    attach_function :rust_array_unshift,      [:pointer, :uint16],          :pointer
    attach_function :rust_array_first,        [:pointer],                   :uint16
    attach_function :rust_array_first_amount, [:pointer, :size_t],          :pointer
    attach_function :rust_array_last,         [:pointer],                   :uint16
    attach_function :rust_array_plus,         [:pointer, :pointer],         :pointer
    attach_function :rust_array_minus,        [:pointer, :pointer],         :pointer
    attach_function :rust_array_length,       [:pointer],                   :size_t
    attach_function :rust_array_intersect,    [:pointer, :pointer],         :pointer
    attach_function :rust_array_slice_bang,   [:pointer, :size_t, :size_t], :pointer
    attach_function :rust_array_empty,        [:pointer],                   :bool
    attach_function :rust_array_eq,           [:pointer, :pointer],         :bool
    attach_function :rust_array_shift,        [:pointer],                   :uint16
    attach_function :rust_array_shift_amount, [:pointer, :size_t],          :pointer
    attach_function :rust_array_include,      [:pointer, :uint16],          :bool
    attach_function :rust_array_sort_by_bang, [:pointer, :rust_array_sort_by_bang_callback], :pointer
    attach_function :rust_array_reject,       [:pointer, :rust_array_reject_callback],       :pointer
    attach_function :rust_array_each,         [:pointer, :rust_array_each_callback],         :void
    attach_function :rust_array_dup,          [:pointer],                   :pointer
    attach_function :rust_array_inspect,      [:pointer],                   :string
    
    # attach_function :rust_array_find,         [:pointer, :uint16],          :uint16
  end
  
  class Array < FFI::AutoPointer
    include Rust::ArrayBackend
    
    attr_reader :internal_instance

    def initialize pointer = nil
      @internal_instance = pointer || rust_array_new
      super(@internal_instance)
    end
    
    def self.release array
      p [:freeing, array.internal_instance]
      # array.internal_instance.rust_array_free
    end
    
    def self.from_ptr pointer
      new(pointer)
    end
    def to_ptr
      @internal_instance
    end
    
    def << item
      # TODO ?
      self.class.from_ptr rust_array_append(to_ptr, item)
      
      # self
    end
    
    def unshift item
      self.class.from_ptr rust_array_unshift(to_ptr, item)
    end
    
    def first amount = nil
      if amount
        self.class.from_ptr rust_array_first_amount(to_ptr, amount)
      else
        rust_array_first(to_ptr)
      end
    end
    def last amount = nil
      if amount
        self.class.from_ptr rust_array_last_amount(to_ptr, amount)
      else
        rust_array_last(to_ptr)
      end
    end
    
    def +(other)
      if other.class != self.class
        # TODO Improve speed!
        new_other = self.class.new
        other.each do |i|
          new_other << i
        end
        other = new_other
      end
      
      self.class.from_ptr rust_array_plus(to_ptr, other.internal_instance)
    end
    def -(other)
      # TODO dup ?
      return self if other.size.zero?
      
      self.class.from_ptr rust_array_minus(to_ptr, other.internal_instance)
    end

    def length
      rust_array_length(to_ptr)
    end
    alias size length
    
    def intersect other
      self.class.from_ptr rust_array_intersect(to_ptr, other.internal_instance)
    end
    
    def slice! start, length # TODO Other sigs.
      return nil if self.empty?
      
      self.class.from_ptr rust_array_slice_bang(to_ptr, start, length)
    end
    
    def empty?
      rust_array_empty(to_ptr)
    end
    
    def shift(amount = nil)
      if amount
        self.class.from_ptr rust_array_shift_amount(to_ptr, amount)
      else
        rust_array_shift(to_ptr)
      end
    end
    
    def include? item
      rust_array_include(to_ptr, item)
    end
    
    def sort_by! &block
      return self unless block_given?
      return self if size < 2
      
      @internal_instance = rust_array_sort_by_bang(to_ptr, block)
      
      self
    end
    
    def reject &block
      return self unless block_given?
      
      self.class.from_ptr rust_array_reject(to_ptr, block)
    end
    
    def each &block
      return self unless block_given?
      
      rust_array_each(to_ptr, block)
    end
    
    def == other
      return false if self.class != other.class
      
      rust_array_eq(to_ptr, other.internal_instance)
    end
    def dup
      self.class.from_ptr rust_array_dup(to_ptr)
    end
    def inspect
      rust_array_inspect(to_ptr).to_s
    end
    def to_ary
      result = []
      rust_array_each(to_ptr) do |i|
        result << i
      end
      result
    end

  end
end
