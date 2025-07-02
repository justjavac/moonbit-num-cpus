///|
/// # CPU Core Detection Module
/// 
/// This module provides cross-platform functionality to detect the number of
/// CPU cores available on the system. It distinguishes between logical cores
/// (including hyperthreading) and physical cores.
/// 
/// ## Features
/// 
/// - **Cross-platform support**: Works on Linux, Windows, macOS, and other Unix-like systems
/// - **Logical core detection**: Get total number of logical CPU cores including hyperthreading
/// - **Physical core detection**: Get actual number of physical CPU cores
/// - **Thread-safe**: All functions are safe to call from multiple threads
/// - **FFI-based**: Uses native system APIs for accurate detection
/// 
/// ## Usage Examples
/// 
/// ```moonbit
/// // Get logical CPU cores (includes hyperthreading)
/// let logical_cores = @num_cpus.get()
/// println("System has {logical_cores} logical CPU cores")
/// 
/// // Get physical CPU cores (excludes hyperthreading)
/// let physical_cores = @num_cpus.get_physical()
/// println("System has {physical_cores} physical CPU cores")
/// 
/// // Calculate hyperthreading ratio
/// if physical_cores > 0 {
///   let ht_ratio = logical_cores / physical_cores
///   if ht_ratio > 1 {
///     println("Hyperthreading is enabled (ratio: {ht_ratio}:1)")
///   } else {
///     println("No hyperthreading detected")
///   }
/// }
/// ```
/// 
/// ## Platform Support
/// 
/// | Platform | Logical Cores | Physical Cores | Method |
/// |----------|---------------|----------------|---------|
/// | Linux    | ✅ sysconf    | ✅ /proc/cpuinfo | Parse CPU info |
/// | Windows  | ✅ GetSystemInfo | ✅ GetLogicalProcessorInfo | WinAPI |
/// | macOS    | ✅ sysctl hw.logicalcpu | ✅ sysctl hw.physicalcpu | BSD sysctl |
/// | Unix     | ✅ sysconf    | ⚠️ Fallback to logical | POSIX sysconf |
/// 
/// ## Error Handling
/// 
/// - Functions return sensible defaults (typically 1) if detection fails
/// - Physical core detection may fall back to logical core count on some platforms
/// - No exceptions are thrown; functions always return a positive integer

///|
/// Get the number of CPU cores available on the system.
/// 
/// This function returns the number of logical CPU cores, which includes
/// hyperthreading cores if available. For example, on a quad-core processor
/// with hyperthreading, this would return 8.
/// 
/// The function uses FFI (Foreign Function Interface) to call native system
/// APIs to retrieve the CPU count information.
/// 
/// Returns:
/// - The number of logical CPU cores available on the system.
/// 
/// Example:
/// ```moonbit
/// let logical_cores = @num_cpus.get()
/// println("Logical CPU cores: {logical_cores}")
/// ```
/// 
/// Note:
/// - On multi-threaded systems, this includes all logical cores
/// - The result is cached by the operating system and reflects the current
///   hardware configuration
/// - This function is thread-safe
pub fn get() -> Int {
  get_cpu_count_ffi()
}

///|
/// Get the number of physical CPU cores on the system.
/// 
/// This function returns the number of physical CPU cores, excluding
/// hyperthreading. For example, on a quad-core processor with hyperthreading,
/// this would return 4 (the actual physical cores), not 8.
/// 
/// The function uses FFI to call native system APIs that can distinguish
/// between physical and logical cores.
/// 
/// Returns:
/// - The number of physical CPU cores (not including hyperthreading).
/// 
/// Example:
/// ```moonbit
/// let physical_cores = @num_cpus.get_physical()
/// let logical_cores = @num_cpus.get()
/// println("Physical cores: {physical_cores}")
/// println("Logical cores: {logical_cores}")
/// println("Hyperthreading ratio: {logical_cores / physical_cores}")
/// ```
/// 
/// Note:
/// - This count excludes logical cores created by hyperthreading
/// - On systems without hyperthreading, this will return the same value as `get()`
/// - The implementation may fall back to logical core count on some platforms
/// - This function is thread-safe
pub fn get_physical() -> Int {
  get_physical_cpu_count_ffi()
}

///|
/// FFI function to get CPU count from native system using C sysconf.
/// 
/// This is an internal FFI (Foreign Function Interface) binding that calls
/// the native C function `moonbit_get_cpu_count` to retrieve the number of
/// logical CPU cores from the operating system.
/// 
/// Platform-specific implementation details:
/// - **Linux/Unix**: Uses `sysconf(_SC_NPROCESSORS_ONLN)` to get online processors
/// - **Windows**: Uses `GetSystemInfo()` to get processor count
/// - **macOS**: Uses `sysctl()` with `hw.logicalcpu` parameter
/// 
/// Returns:
/// - The number of logical CPU cores as reported by the operating system
/// 
/// Note:
/// - This function is internal and should not be called directly
/// - Use `get()` instead for public API access
/// - The actual implementation is provided by the linked C code
extern "C" fn get_cpu_count_ffi() -> Int = "moonbit_get_cpu_count"

///|
/// FFI function to get physical CPU count from native system.
/// 
/// This is an internal FFI binding that calls the native C function
/// `moonbit_get_physical_cpu_count` to retrieve the number of physical
/// CPU cores, excluding hyperthreading.
/// 
/// Platform-specific implementation details:
/// - **Linux**: Parses `/proc/cpuinfo` to count unique physical processors
/// - **Windows**: Uses `GetLogicalProcessorInformation()` to distinguish
///   physical from logical cores
/// - **macOS**: Uses `sysctl()` with `hw.physicalcpu` parameter
/// - **Fallback**: Returns logical core count if physical count unavailable
/// 
/// Returns:
/// - The number of physical CPU cores as reported by the operating system
/// - Falls back to logical core count on platforms where physical count
///   cannot be determined
/// 
/// Note:
/// - This function is internal and should not be called directly
/// - Use `get_physical()` instead for public API access
/// - The actual implementation is provided by the linked C code
/// - May require elevated permissions on some platforms for accurate results
extern "C" fn get_physical_cpu_count_ffi() -> Int = "moonbit_get_physical_cpu_count"
