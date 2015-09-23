require 'ffi'

module Rust
  class ArrayPointer < FFI::AutoPointer
    def self.release(ptr)
      Array.free(ptr)
    end

    def append(item)
      Array.append(self, item)
    end
    alias << append

    def unshift(item)
      Array.unshift(self, item)
    end
    
    def intersect(other)
      Array.intersect(self, other)
    end
    
    def slice!(offset, amount)
      other = Array.new
      Array.slice_bang(self, other, offset, amount)
    end

    def first
      Array.first(self)
    end
  
    def last
      Array.last(self)
    end
    
    def length
      Array.length(self)
    end
    alias size length
  end
  class Array
    extend FFI::Library
    ffi_lib 'picky_rust'

    attach_function :new,  :rust_array_new,  [],             ArrayPointer
    attach_function :free, :rust_array_free, [ArrayPointer], :void
                    
    attach_function :append,  :rust_array_append,  [ArrayPointer, :uint16], :uint16
    attach_function :unshift, :rust_array_unshift, [ArrayPointer, :uint16], :uint16
    
    attach_function :intersect,  :rust_array_intersect,  [ArrayPointer, ArrayPointer],     ArrayPointer
    attach_function :slice_bang, :rust_array_slice_bang, [ArrayPointer, ArrayPointer, :size_t, :size_t], ArrayPointer
    
    attach_function :first, :rust_array_first, [ArrayPointer], :uint16
    attach_function :last,  :rust_array_last,  [ArrayPointer], :uint16
    
    attach_function :length, :rust_array_length, [ArrayPointer], :size_t
  end
  
  class HashPointer < FFI::AutoPointer
    def self.release(ptr)
      Hash.free(ptr)
    end
    
    # def append_to(key, value)
    #   Hash.append_to(self, key, value)
    # end

    def set(key, value)
      Hash.set(self, key, value)
    end
    alias []= set

    def get(key)
      result = Hash.get(self, key)
      return nil if result.address.zero?
      result
    end
    alias [] get
    
    def length
      Hash.length(self)
    end
    alias size length
  end
  class Hash
    extend FFI::Library
    ffi_lib 'picky_rust'
    
    attach_function :new,  :rust_hash_new, [], HashPointer
    attach_function :free, :rust_hash_free, [HashPointer], :void

    # Special function.
    # attach_function :append_to, :rust_hash_append_to, [HashPointer, :string, :uint16], :uint16

    attach_function :get, :rust_hash_get, [HashPointer, :string], ArrayPointer
    attach_function :set, :rust_hash_set, [HashPointer, :string, ArrayPointer], ArrayPointer
    
    attach_function :length, :rust_hash_length, [HashPointer], :size_t
  end
end