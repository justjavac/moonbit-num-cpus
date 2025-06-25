// Copyright 2025 justjavac
//
// Licensed under the MIT License

///|
/// Example usage of the num_cpus module
fn main {
  let logical_cpus = get()
  let physical_cpus = get_physical()
  println("Number of logical CPU cores: \{logical_cpus}")
  println("Number of physical CPU cores: \{physical_cpus}")
}
