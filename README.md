# moonbit-num-cpus

[![CI](https://github.com/justjavac/moonbit-num-cpus/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/justjavac/moonbit-num-cpus/actions/workflows/ci.yml)
[![Coverage](https://codecov.io/gh/justjavac/moonbit-num-cpus/graph/badge.svg?branch=main)](https://codecov.io/gh/justjavac/moonbit-num-cpus)
[![Coverage Linux](https://codecov.io/gh/justjavac/moonbit-num-cpus/graph/badge.svg?branch=main&flag=linux)](https://codecov.io/gh/justjavac/moonbit-num-cpus)
[![Coverage macOS](https://codecov.io/gh/justjavac/moonbit-num-cpus/graph/badge.svg?branch=main&flag=macos)](https://codecov.io/gh/justjavac/moonbit-num-cpus)
[![Coverage Windows](https://codecov.io/gh/justjavac/moonbit-num-cpus/graph/badge.svg?branch=main&flag=windows)](https://codecov.io/gh/justjavac/moonbit-num-cpus)

`moonbit-num-cpus` is a small MoonBit module for detecting the number of CPU
cores available on the current machine.

It supports:

- Logical CPU count, including SMT / hyper-threading
- Physical CPU count when the operating system can report it
- Native implementations for Windows, macOS, Linux, and other Unix-like systems
- Safe fallback behavior that never returns less than `1`

## Installation

```bash
moon add justjavac/num_cpus
```

## API

| Function | Description |
| -------- | ----------- |
| `@num_cpus.get()` | Returns the number of logical CPU cores |
| `@num_cpus.get_physical()` | Returns the number of physical CPU cores, or a fallback value when exact detection is unavailable |

## Usage

```moonbit
fn main {
  let logical = @num_cpus.get()
  let physical = @num_cpus.get_physical()

  println("Logical CPU cores: \{logical}")
  println("Physical CPU cores: \{physical}")

  if logical > physical {
    println("SMT or hyper-threading is likely enabled")
  }
}
```

## Common Use Cases

### Size a thread pool

```moonbit
fn worker_count() -> Int {
  @num_cpus.get_physical()
}
```

### Compare logical and physical cores

```moonbit
fn main {
  let logical = @num_cpus.get()
  let physical = @num_cpus.get_physical()
  println("CPU topology: \{physical} physical / \{logical} logical")
}
```

## Platform Support

| Platform | Logical CPUs | Physical CPUs | Implementation |
| -------- | ------------ | ------------- | -------------- |
| Windows | Yes | Yes | `GetSystemInfo` and `GetLogicalProcessorInformation` |
| macOS | Yes | Yes | `sysconf` and `sysctl` |
| Linux | Yes | Yes | `sysconf` and `/proc/cpuinfo` |
| Other Unix-like systems | Yes | Fallback | `sysconf`, with physical count falling back to logical count |

## How It Works

- Logical CPU detection uses native platform APIs rather than external commands.
- Physical CPU detection uses the best available system interface on each OS.
- When physical core detection is unavailable, the module falls back to the logical CPU count.
- The package is designed for the `native` target and declares it as the preferred target.

## Development

```bash
moon test --target native
moon check --deny-warn --target native
```

## License

MIT. See [LICENSE](LICENSE).

## Acknowledgments

Inspired by Rust's [`num_cpus`](https://github.com/seanmonstar/num_cpus) crate.
