library(S7)

# ---- json_object ------------------------------------------------------------

test_that("json_lapply over json_object returns json_object", {
  obj <- json_object(a = 1, b = 2, c = 3)
  result <- json_lapply(obj, function(v) v * 2)
  expect_s7_class(result, jst::json_object)
})

test_that("json_lapply over json_object transforms member values", {
  obj <- json_object(a = 1, b = 2, c = 3)
  result <- json_lapply(obj, function(v) v * 2)
  expect_equal(result@members$a, 2)
  expect_equal(result@members$b, 4)
  expect_equal(result@members$c, 6)
})

test_that("json_lapply over json_object preserves member names", {
  obj <- json_object(x = 10, y = 20)
  result <- json_lapply(obj, function(v) v + 1)
  expect_equal(names(result@members), c("x", "y"))
})

test_that("json_lapply over json_object preserves length", {
  obj <- json_object(a = 1, b = 2, c = 3)
  result <- json_lapply(obj, function(v) v)
  expect_equal(result@length, 3L)
})

test_that("json_lapply over json_object with to_json produces typed values", {
  obj <- json_object(a = 1, b = "hello", c = TRUE)
  result <- json_lapply(obj, to_json)
  expect_s7_class(result@members$a, jst::json_number)
  expect_s7_class(result@members$b, jst::json_string)
  expect_s7_class(result@members$c, jst::json_boolean)
})

test_that("json_lapply over json_object serialises correctly", {
  obj <- json_object(a = 1, b = 2)
  result <- json_lapply(obj, function(v) v * 10)
  expect_equal(format(result), '{"a": 10, "b": 20}')
})

test_that("json_lapply over empty json_object returns empty json_object", {
  obj <- json_object()
  result <- json_lapply(obj, function(v) v)
  expect_s7_class(result, jst::json_object)
  expect_equal(result@length, 0L)
})

test_that("json_lapply passes ... to f", {
  obj <- json_object(a = 1, b = 2)
  result <- json_lapply(obj, function(v, mult) v * mult, mult = 5)
  expect_equal(result@members$a, 5)
  expect_equal(result@members$b, 10)
})

# ---- json_array -------------------------------------------------------------

test_that("json_lapply over json_array returns json_array", {
  arr <- json_array(1, 2, 3)
  result <- json_lapply(arr, function(v) v * 2)
  expect_s7_class(result, jst::json_array)
})

test_that("json_lapply over json_array transforms elements", {
  arr <- json_array(1, 2, 3)
  result <- json_lapply(arr, function(v) v + 10)
  expect_equal(result@elements[[1L]], 11)
  expect_equal(result@elements[[2L]], 12)
  expect_equal(result@elements[[3L]], 13)
})

test_that("json_lapply over json_array preserves length", {
  arr <- json_array(1, 2, 3)
  result <- json_lapply(arr, function(v) v)
  expect_equal(result@length, 3L)
})

test_that("json_lapply over json_array with to_json produces typed values", {
  arr <- json_array(1, "two", TRUE)
  result <- json_lapply(arr, to_json)
  expect_s7_class(result@elements[[1L]], jst::json_number)
  expect_s7_class(result@elements[[2L]], jst::json_string)
  expect_s7_class(result@elements[[3L]], jst::json_boolean)
})

test_that("json_lapply over json_array serialises correctly", {
  arr <- json_array(1, 2, 3)
  result <- json_lapply(arr, function(v) v * 2)
  expect_equal(format(result), "[2, 4, 6]")
})

test_that("json_lapply over empty json_array returns empty json_array", {
  arr <- json_array()
  result <- json_lapply(arr, function(v) v)
  expect_s7_class(result, jst::json_array)
  expect_equal(result@length, 0L)
})

test_that("json_lapply passes ... to f for json_array", {
  arr <- json_array(1, 2, 3)
  result <- json_lapply(arr, function(v, add) v + add, add = 100)
  expect_equal(result@elements[[1L]], 101)
  expect_equal(result@elements[[2L]], 102)
  expect_equal(result@elements[[3L]], 103)
})

# ---- nested structures ------------------------------------------------------

test_that("json_lapply can replace nested objects", {
  obj <- json_object(
    inner = json_object(x = 1, y = 2),
    other = json_object(x = 3, y = 4)
  )
  result <- json_lapply(obj, function(v) json_lapply(v, function(n) n * 10))
  expect_equal(result@members$inner@members$x, 10)
  expect_equal(result@members$other@members$y, 40)
})

# ---- error handling ---------------------------------------------------------

test_that("json_lapply errors on scalar json types", {
  expect_error(json_lapply(json_number(1), identity), "json_array or json_object")
  expect_error(json_lapply(json_string("x"), identity), "json_array or json_object")
  expect_error(json_lapply(json_null(), identity), "json_array or json_object")
})
