require 'ffi'

class Rust < FFI::AutoPointer
  def self.release(ptr)
    HashMap.free(ptr)
  end

  def populate
    HashMap.populate(self)
  end

  def set(key, value)
    HashMap.set(self, key, value)
  end

  def get(key)
    HashMap.get(self, key)
  end

  module HashMap
    extend FFI::Library
    ffi_lib 'integration'

    attach_function :new,  :rust_hash_map_new, [], Rust
    attach_function :free, :rust_hash_map_free, [Rust], :void
                    
    attach_function :get, :rust_hash_map_get, [Rust, :string], :uint32
    attach_function :set, :rust_hash_map_set, [Rust, :string, :uint32], :uint32
  end
end