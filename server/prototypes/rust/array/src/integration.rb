require 'ffi'

class Rust < FFI::AutoPointer
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

  module Array
    extend FFI::Library
    ffi_lib 'integration'

    attach_function :new,  :rust_array_new, [], Rust
    attach_function :free, :rust_array_free, [Rust], :void
                    
    attach_function :append, :rust_array_append, [Rust, :uint32], :uint32
    attach_function :first, :rust_array_first, [Rust], :uint32
    attach_function :last, :rust_array_last, [Rust], :uint32
  end
end