import 'dart:ffi' as ffi;

import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// Minimal process allocator replacing `package:ffi` (dropped dependency).
///
/// Same symbols `package:ffi` itself resolves from the process (`calloc` /
/// `free`), so platform behavior is unchanged: [ioCalloc] returns a
/// zero-filled buffer of one [count] of `T`, freed with [ioFree]. All call
/// sites already pair every allocation with a free.
final _callocFn = ffi.DynamicLibrary.process().lookupFunction<
  ffi.Pointer Function(ffi.IntPtr num, ffi.IntPtr size),
  ffi.Pointer Function(int num, int size)
>('calloc');

final _freeFn = ffi.DynamicLibrary.process()
    .lookupFunction<ffi.Void Function(ffi.Pointer), void Function(ffi.Pointer)>(
      'free',
    );

/// Element size for the instantiated types used across the connector.
/// (`sizeOf<T>()` needs a compile-time type, so the generic helper
/// dispatches on the reified `T` instead.)
int _unitSize<T extends ffi.NativeType>() {
  if (T == ffi.Uint8 || T == ffi.Int8) {
    return 1;
  }
  if (T == ffi.Uint16 || T == ffi.Int16) {
    return 2;
  }
  if (T == ffi.Uint32 || T == ffi.Int32 || T == ffi.Float) {
    return 4;
  }
  if (T == ffi.Uint64 || T == ffi.Int64 || T == ffi.Double) {
    return 8;
  }
  // Address-sized: pointers and `size_t` match the platform word.
  if (T == ffi.Pointer<ffi.Void>) {
    return ffi.sizeOf<ffi.IntPtr>();
  }
  if (T == ffi.Size) {
    return ffi.sizeOf<ffi.UintPtr>();
  }
  throw BuError(
    DefaultErrorType.unsupported,
    'ioCalloc: unsupported element type $T.',
  );
}

/// Zeroed buffer for `count` `T` elements; free with [ioFree].
ffi.Pointer<T> ioCalloc<T extends ffi.NativeType>([int count = 1]) =>
    _callocFn(_unitSize<T>() * count, 1).cast<T>();

/// Releases a buffer from [ioCalloc].
void ioFree(ffi.Pointer ptr) => _freeFn(ptr);
