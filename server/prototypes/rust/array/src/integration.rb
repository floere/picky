require 'ffi'

module Rust
  class ArrayPointer < FFI::AutoPointer
    def self.release(ptr)
      Array.free(ptr)
    end

    def append(item)
      Array.append(self, item)
    end

    def first()
      Array.first(self)
    end
  
    def last()
      Array.last(self)
    end
  end
  class Array
    extend FFI::Library
    ffi_lib 'picky'

    attach_function :new,  :rust_array_new, [], ArrayPointer
    attach_function :free, :rust_array_free, [ArrayPointer], :void
                    
    attach_function :append, :rust_array_append, [ArrayPointer, :uint16], :uint16
    attach_function :first, :rust_array_first, [ArrayPointer], :uint16
    attach_function :last, :rust_array_last, [ArrayPointer], :uint16
  end
  
  class HashPointer < FFI::AutoPointer
    def self.release(ptr)
      Hash.free(ptr)
    end

    def populate
      Hash.populate(self)
    end

    def set(key, value)
      Hash.set(self, key, value)
    end

    def get(key)
      Hash.get(self, key)
    end
  end
  class Hash
    extend FFI::Library
    ffi_lib 'picky'
    
    attach_function :new,  :rust_hash_new, [], HashPointer
    attach_function :free, :rust_hash_free, [HashPointer], :void
                    
    attach_function :get, :rust_hash_get, [HashPointer, :string], :uint32
    attach_function :set, :rust_hash_set, [HashPointer, :string, :uint32], :uint32
  end
end