require 'ffi'
# require 'ffi/autopointer'

module Rust
  
  module ArrayBackend
    extend FFI::Library
  
    ffi_lib File.expand_path('../../libpicky_rust.dylib', __FILE__) # FFI::Library::LIBC
  
    attach_function :rust_array_new, [], :pointer
  
    callback :rust_array_sort_by_bang_callback, [:uint16], :int32
  
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
    attach_function :rust_array_dup,          [:pointer],                   :pointer
    attach_function :rust_array_inspect,      [:pointer],                   :string
  end
  
  class Array < FFI::AutoPointer
    include Rust::ArrayBackend
    
    attr_reader :internal_instance

    def initialize pointer = nil
      @internal_instance = pointer || rust_array_new
    end
    
    def release
      # internal_instance.free # TODO
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
      
      @internal_instance = rust_array_sort_by_bang(to_ptr, block)
      
      self
    end
    
    def == other
      # return false if other.class # TODO
      
      rust_array_eq(to_ptr, other.internal_instance)
    end
    def dup
      self.class.from_ptr rust_array_dup(to_ptr)
    end
    def inspect
      rust_array_inspect(to_ptr).to_s
    end

  end
end