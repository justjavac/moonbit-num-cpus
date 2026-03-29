// Copyright 2025 justjavac
//
// Licensed under the MIT License

///|
test "get cpu count" {
  let cpu_count = get()
  // CPU count should be at least 1
  assert_true(cpu_count >= 1)
  // CPU count should be reasonable (less than 1000 for most systems)
  assert_true(cpu_count <= 1000)
  println("CPU count: \{cpu_count}")
}

///|
test "get cpu count is consistent" {
  let count1 = get()
  let count2 = get()
  // The CPU count should be consistent between calls
  assert_eq(count1, count2)
}

///|
test "get physical cpu count" {
  let cpu_count = get_physical()
  // Physical CPU count should be at least 1
  assert_true(cpu_count >= 1)
  // Physical CPU count should be reasonable (less than 1000 for most systems)
  assert_true(cpu_count <= 1000)
  println("Physical CPU count: \{cpu_count}")
}

///|
test "get physical cpu count is consistent" {
  let count1 = get_physical()
  let count2 = get_physical()
  // The physical CPU count should be consistent between calls
  assert_eq(count1, count2)
}
