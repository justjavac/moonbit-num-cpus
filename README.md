# moonbit-num-cpus

A MoonBit module to get the number of CPU cores available on the system, supporting both logical and physical core detection.

## Features

- **Cross-platform support**: Works on Windows, macOS, Linux, and other Unix-like systems
- **Multiple core types**: Get both logical CPU cores (including hyperthreading) and physical CPU cores
- **C FFI implementation**: Uses native system APIs for accurate CPU detection
- **Fallback support**: Graceful fallbacks for unsupported platforms
- **Zero dependencies**: Self-contained implementation

## Usage

```moonbit
fn main {
  let logical_cpus = @justjavac/num_cpus.get()
  let physical_cpus = @justjavac/num_cpus.get_physical()
  
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

- **Windows**: Uses `GetLogicalProcessorInformation()` to count physical processor cores
- **macOS**: Uses `sysctlbyname("hw.physicalcpu")` 
- **Linux**: Parses `/proc/cpuinfo` to count unique physical processors and cores
- **Other Unix**: Falls back to logical CPU count
- **Fallback**: Returns `1` for unknown platforms

This excludes hyperthreading/SMT virtual cores and represents actual physical CPU cores.

## Platform Support

| Platform | Logical CPUs | Physical CPUs | Implementation |
|----------|-------------|---------------|----------------|
| Windows | ✅ | ✅ | Win32 API (`GetSystemInfo`, `GetLogicalProcessorInformation`) |
| macOS | ✅ | ✅ | POSIX (`sysconf`) + BSD (`sysctlbyname`) |
| Linux | ✅ | ✅ | POSIX (`sysconf`) + `/proc/cpuinfo` parsing |
| Other Unix | ✅ | ⚠️ | POSIX (`sysconf`), falls back to logical count |
| JavaScript/Node.js | ✅ | ➖ | `os.cpus().length` / `navigator.hardwareConcurrency` |
| WASM | ⚠️ | ➖ | Returns `1` (limited system access) |

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

1. **Logical CPUs**: Uses standardized POSIX `sysconf()` on Unix systems and Win32 `GetSystemInfo()` on Windows
2. **Physical CPUs**: Uses platform-specific APIs to distinguish physical from logical cores
3. **Graceful Fallbacks**: If physical core detection fails, falls back to logical core count
4. **Safety**: Never returns 0; minimum return value is 1

## Installation

Add this to your `moon.mod.json`:

```json
{
  "deps": {
    "justjavac/num_cpus": "^0.1.2"
  }
}
```

Then run:

```bash
moon install
```

## Examples

### Basic Usage

```moonbit
fn main {
  println("CPU cores: \{@justjavac/num_cpus.get()}")
}
```

### Comparing Logical vs Physical

```moonbit
fn main {
  let logical = @justjavac/num_cpus.get()
  let physical = @justjavac/num_cpus.get_physical()
  
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
  let logical = @justjavac/num_cpus.get()
  let physical = @justjavac/num_cpus.get_physical()
  
  // Use physical cores for CPU-bound tasks
  // Use logical cores for I/O-bound tasks
  // This is just an example - you'd implement is_cpu_bound_workload()
  physical  // Simplified example
}
```

## Building

### For Native Targets

```bash
moon build --target native
```

### For All Targets

```bash
moon build
```

### Running Tests

```bash
moon test
```

## Comparison with Other Languages

| Language | Library | Logical CPUs | Physical CPUs |
|----------|---------|-------------|---------------|
| **MoonBit** | **justjavac/num_cpus** | ✅ | ✅ |
| Rust | `num_cpus` | ✅ | ✅ |
| Go | `runtime.NumCPU()` | ✅ | ➖ |
| Python | `os.cpu_count()` | ✅ | ➖ |
| Node.js | `os.cpus().length` | ✅ | ➖ |
| Java | `Runtime.availableProcessors()` | ✅ | ➖ |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the Rust [`num_cpus`](https://github.com/seanmonstar/num_cpus) crate
- Uses cross-platform system APIs for accurate CPU detection
- Built with MoonBit's C FFI capabilities
