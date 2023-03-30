/// Authors: Chance Snow
/// Copyright:
/// Copyright © 2014-2017 Panic, Inc. All rights reserved.
/// Copyright © 2022 Chance Snow.
/// License: MIT License
module playdate.allocator;

import playdate : PlaydateAPI;

///
static PlaydateAPI* pd;

shared static this() {
  import std.experimental.allocator: allocatorObject, theAllocator;
  theAllocator = allocatorObject(PDAllocator.instance);
}

/// Playdate heap allocator.
/// Remarks: Adapted from <a href="https://github.com/dlang/phobos/blob/17b1a11afd74f9f8a69af93d77d4548a557e1b89/std/experimental/allocator/mallocator.d">std.experimental.allocator.mallocator</a>
struct PDAllocator {
  import std.experimental.allocator.common: platformAlignment;

  /// The alignment is a static constant equal to `platformAlignment`, which ensures proper alignment for any D data type.
  enum uint alignment = platformAlignment;

  @nogc nothrow:

  ///
  void[] allocate(size_t bytes) const {
    assert(pd, "Playdate API is inaccessible!");
    if (!bytes) return null;
    auto p = pd.system.realloc(null, bytes);
    return p ? p[0 .. bytes] : null;
  }

  ///
  @system bool deallocate(void[] b) const {
    import playdate : free;
    assert(pd, "Playdate API is inaccessible!");
    pd.system.free(b.ptr);
    return true;
  }

  ///
  @system bool reallocate(ref void[] b, size_t s) const {
    assert(pd, "Playdate API is inaccessible!");
    if (!s) {
      assert(deallocate(b));
      b = null;
      return true;
    }
    auto p = cast(ubyte*) pd.system.realloc(b.ptr, s);
    if (!p) return false;
    b = p[0 .. s];
    return true;
  }

  /// Returns: The global instance of this allocator type.
  static PDAllocator instance;
}
