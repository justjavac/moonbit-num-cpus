// Copyright 2025 justjavac
//
// Licensed under the MIT License

///|
test "example can read cpu counts" {
  assert_true(@num_cpus.get() >= 1)
  assert_true(@num_cpus.get_physical() >= 1)
}
