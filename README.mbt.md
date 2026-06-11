# moonbit-num-cpus

```mbt nocheck
fn main {
  let logical = @num_cpus.get()
  let physical = @num_cpus.get_physical()
  println("logical: \{logical}, physical: \{physical}")
}
```
