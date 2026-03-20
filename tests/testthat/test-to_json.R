library(S7)

# ---- NULL --------------------------------------------------------------------

test_that("to_json(NULL) returns json_null", {
  expect_s3_class(to_json(NULL), "json_null")
})

# ---- logical -----------------------------------------------------------------

test_that("to_json(scalar logical) returns json_boolean", {
  x <- to_json(TRUE)
  expect_s3_class(x, "json_boolean")
  expect_equal(x@value, TRUE)
})

test_that("to_json(logical vector) returns json_array", {
  x <- to_json(c(TRUE, FALSE, TRUE))
  expect_s3_class(x, "json_array")
  expect_length(x@elements, 3L)
})

# ---- integer -----------------------------------------------------------------

test_that("to_json(scalar integer) returns json_number", {
  x <- to_json(5L)
  expect_s3_class(x, "json_number")
  expect_equal(x@value, 5)
})

test_that("to_json(integer vector) returns json_vector", {
  x <- to_json(1:5)
  expect_s3_class(x, "json_vector")
  expect_equal(x@value, 1:5)
})

# ---- numeric -----------------------------------------------------------------

test_that("to_json(scalar numeric) returns json_number", {
  x <- to_json(3.14)
  expect_s3_class(x, "json_number")
  expect_equal(x@value, 3.14)
})

test_that("to_json(numeric vector) returns json_vector", {
  x <- to_json(c(1.1, 2.2, 3.3))
  expect_s3_class(x, "json_vector")
})

# ---- character ---------------------------------------------------------------

test_that("to_json(scalar character) returns json_string", {
  x <- to_json("hello")
  expect_s3_class(x, "json_string")
  expect_equal(x@value, "hello")
})

test_that("to_json(character vector) returns json_vector", {
  x <- to_json(c("a", "b"))
  expect_s3_class(x, "json_vector")
})

# ---- list --------------------------------------------------------------------

test_that("to_json(named list) returns json_object", {
  x <- to_json(list(a = 1, b = "x"))
  expect_s3_class(x, "json_object")
  expect_equal(names(x@members), c("a", "b"))
})

test_that("to_json(unnamed list) returns json_array", {
  x <- to_json(list(1, "two", TRUE))
  expect_s3_class(x, "json_array")
  expect_length(x@elements, 3L)
})

# ---- json passthrough --------------------------------------------------------

test_that("to_json(json) returns the same object unchanged", {
  j <- json_boolean(TRUE)
  expect_identical(to_json(j), j)
})

# ---- round-trip formatting ---------------------------------------------------

test_that("to_json round-trip: NULL", {
  expect_equal(format(to_json(NULL)), "null")
})

test_that("to_json round-trip: TRUE", {
  expect_equal(format(to_json(TRUE)), "true")
})

test_that("to_json round-trip: numeric scalar", {
  expect_equal(format(to_json(42)), "42")
})

test_that("to_json round-trip: string scalar", {
  expect_equal(format(to_json("hello")), '"hello"')
})

test_that("to_json round-trip: named list", {
  expect_equal(format(to_json(list(n = 1, s = "x"))), '{"n": 1, "s": "x"}')
})

test_that("to_json round-trip: unnamed list", {
  expect_equal(format(to_json(list(1, "two"))), '[1, "two"]')
})
