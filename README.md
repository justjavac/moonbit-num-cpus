# moonbit-num-cpus

A MoonBit module to get the number of CPU cores available on the system.

## Usage

```moonbit
fn main {
  let cpu_count = @num_cpus.get()
  println("Number of CPU cores: \{cpu_count}")
}
```

## API

### `get() -> Int`

Returns the number of logical CPU cores available on the system.

## Installation

Add this to your `moon.mod.json`:

```json
{
  "deps": {
    "justjavac/num_cpus": "^0.1.0"
  }
}
```

## License

MIT License
