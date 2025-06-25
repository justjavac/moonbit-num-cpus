# moonbit-num-cpus

A MoonBit module to get the number of CPU cores available on the system,
supporting both logical and physical core detection.

## Installation

Add `justjavac/num_cpus` to your dependencies:

```bash
moon update
moon add justjavac/num_cpus
```

## Usage

```moonbit
fn main {
  let logical_cpus = @num_cpus.get()
  let physical_cpus = @num_cpus.get_physical()
  
  println("Logical CPU cores: \{logical_cpus}")
  println("Physical CPU cores: \{physical_cpus}")
  
  if logical_cpus > physical_cpus {
    println("Hyperthreading/SMT is enabled")
  }
}
```

## API

### `get() -> Int`

Returns the number of **logical** CPU cores available on the system.

- **Windows**: Uses `GetSystemInfo()` to get `dwNumberOfProcessors`
- **Unix/Linux/macOS**: Uses `sysconf(_SC_NPROCESSORS_ONLN)`
- **Fallback**: Returns `1` for unknown platforms

This includes cores from hyperthreading/simultaneous multithreading (SMT).

### `get_physical() -> Int`

Returns the number of **physical** CPU cores available on the system.

- **Windows**: Uses `GetLogicalProcessorInformation()` to count physical
  processor cores
- **macOS**: Uses `sysctlbyname("hw.physicalcpu")`
- **Linux**: Parses `/proc/cpuinfo` to count unique physical processors and
  cores
- **Other Unix**: Falls back to logical CPU count
- **Fallback**: Returns `1` for unknown platforms

This excludes hyperthreading/SMT virtual cores and represents actual physical
CPU cores.

## Platform Support

| Platform   | Logical CPUs | Physical CPUs | Implementation                                                |
| ---------- | ------------ | ------------- | ------------------------------------------------------------- |
| Windows    | ✅           | ✅            | Win32 API (`GetSystemInfo`, `GetLogicalProcessorInformation`) |
| macOS      | ✅           | ✅            | POSIX (`sysconf`) + BSD (`sysctlbyname`)                      |
| Linux      | ✅           | ✅            | POSIX (`sysconf`) + `/proc/cpuinfo` parsing                   |
| Other Unix | ✅           | ⚠️            | POSIX (`sysconf`), falls back to logical count                |

- ✅ = Full support
- ⚠️ = Limited/fallback support
- ➖ = Not applicable

## Implementation Details

### C FFI Architecture

The native implementation uses C FFI to call platform-specific system APIs:

```c
// Windows
int moonbit_get_cpu_count();           // GetSystemInfo
int moonbit_get_physical_cpu_count();  // GetLogicalProcessorInformation

// Unix-like systems  
int moonbit_get_cpu_count();           // sysconf(_SC_NPROCESSORS_ONLN)
int moonbit_get_physical_cpu_count();  // Platform-specific implementations
```

### Cross-Platform Strategy

1. **Logical CPUs**: Uses standardized POSIX `sysconf()` on Unix systems and
   Win32 `GetSystemInfo()` on Windows
2. **Physical CPUs**: Uses platform-specific APIs to distinguish physical from
   logical cores
3. **Graceful Fallbacks**: If physical core detection fails, falls back to
   logical core count
4. **Safety**: Never returns 0; minimum return value is 1

## Examples

### Basic Usage

```moonbit
fn main {
  println("CPU cores: \{@num_cpus.get()}")
}
```

### Comparing Logical vs Physical

```moonbit
fn main {
  let logical = @num_cpus.get()
  let physical = @num_cpus.get_physical()
  
  let ratio = logical.to_double() / physical.to_double()
  
  if ratio == 1.0 {
    println("No hyperthreading detected")
  } else if ratio == 2.0 {
    println("2x hyperthreading (common)")
  } else {
    println("SMT ratio: \{ratio}")
  }
}
```

### Thread Pool Sizing

```moonbit
fn get_optimal_thread_count() -> Int {
  let logical = @num_cpus.get()
  let physical = @num_cpus.get_physical()
  
  // Use physical cores for CPU-bound tasks
  // Use logical cores for I/O-bound tasks
  // This is just an example - you'd implement is_cpu_bound_workload()
  physical  // Simplified example
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the Rust [`num_cpus`](https://github.com/seanmonstar/num_cpus)
  crate
- Uses cross-platform system APIs for accurate CPU detection
- Built with MoonBit's C FFI capabilities
