// Copyright 2025 justjavac
//
// Licensed under the MIT License
//
// A Moonbit module to get the number of CPU cores available on the system.

///|
/// Get the number of CPU cores available on the system.
/// Returns the number of logical CPU cores.
pub fn get() -> Int {
  get_cpu_count_ffi()
}

///|
/// Get the number of physical CPU cores on the system.
/// Returns the number of physical CPU cores (not including hyperthreading).
pub fn get_physical() -> Int {
  get_physical_cpu_count_ffi()
}

///|
/// FFI function to get CPU count from native system using C sysconf
extern "C" fn get_cpu_count_ffi() -> Int = "moonbit_get_cpu_count"

///|
/// FFI function to get physical CPU count from native system
extern "C" fn get_physical_cpu_count_ffi() -> Int = "moonbit_get_physical_cpu_count"
