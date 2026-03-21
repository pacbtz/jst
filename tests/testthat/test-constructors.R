library(S7)

# ---- json_null ---------------------------------------------------------------

test_that("json_null() constructs correctly", {
  x <- json_null()
  expect_s7_class(x, jst::json_null)
})

test_that("json_null() formats as null", {
  expect_equal(format(json_null()), "null")
})

# ---- json_boolean ------------------------------------------------------------

test_that("json_boolean() constructs from TRUE/FALSE", {
  expect_equal(json_boolean(TRUE)@value, TRUE)
  expect_equal(json_boolean(FALSE)@value, FALSE)
})

test_that("json_boolean() formats correctly", {
  expect_equal(format(json_boolean(TRUE)), "true")
  expect_equal(format(json_boolean(FALSE)), "false")
})

test_that("json_boolean() rejects NA", {
  expect_error(json_boolean(NA), "non-NA scalar logical")
})

test_that("json_boolean() rejects non-logical", {
  expect_error(json_boolean(1), "non-NA scalar logical")
})

test_that("json_boolean() rejects length > 1", {
  expect_error(json_boolean(c(TRUE, FALSE)), "non-NA scalar logical")
})

# ---- json_number -------------------------------------------------------------

test_that("json_number() constructs from numeric", {
  expect_equal(json_number(42)@value, 42)
  expect_equal(json_number(3.14)@value, 3.14)
  expect_equal(json_number(-0.5)@value, -0.5)
})

test_that("json_number() coerces integer", {
  x <- json_number(1L)
  expect_equal(x@value, 1)
})

test_that("json_number() formats without scientific notation", {
  expect_equal(format(json_number(1e4)), "10000")
  expect_equal(format(json_number(0.001)), "0.001")
})

test_that("json_number() rejects NaN and Inf", {
  expect_error(json_number(NaN), "finite")
  expect_error(json_number(Inf), "finite")
  expect_error(json_number(-Inf), "finite")
})

test_that("json_number() rejects length > 1", {
  expect_error(json_number(c(1, 2)), "scalar numeric")
})

# ---- json_string -------------------------------------------------------------

test_that("json_string() constructs from character", {
  expect_equal(json_string("hello")@value, "hello")
  expect_equal(json_string("")@value, "")
})

test_that("json_string() wraps value in double quotes", {
  expect_equal(format(json_string("hi")), '"hi"')
})

test_that("json_string() escapes special characters", {
  expect_equal(format(json_string('say "hi"')), '"say \\"hi\\""')
  expect_equal(format(json_string("line1\nline2")), '"line1\\nline2"')
  expect_equal(format(json_string("tab\there")), '"tab\\there"')
  expect_equal(format(json_string("back\\slash")), '"back\\\\slash"')
})

test_that("json_string() rejects length > 1", {
  expect_error(json_string(c("a", "b")), "scalar character")
})

# ---- json_vector -------------------------------------------------------------

test_that("json_vector() constructs from integer vector", {
  x <- json_vector(1:5)
  expect_s7_class(x, jst::json_vector)
  expect_equal(x@value, 1:5)
})

test_that("json_vector() constructs from double vector", {
  x <- json_vector(c(1.1, 2.2))
  expect_equal(x@value, c(1.1, 2.2))
})

test_that("json_vector() constructs from character vector", {
  x <- json_vector(c("a", "b", "c"))
  expect_equal(x@value, c("a", "b", "c"))
})

test_that("json_vector() formats numeric as JSON array", {
  expect_equal(format(json_vector(1:3)), "[1, 2, 3]")
})

test_that("json_vector() formats character as JSON array of strings", {
  expect_equal(format(json_vector(c("x", "y"))), '["x", "y"]')
})

test_that("json_vector() rejects empty vector", {
  expect_error(json_vector(integer(0)), "non-empty")
})

test_that("json_vector() rejects logical vector", {
  expect_error(json_vector(c(TRUE, FALSE)), "character, integer, or double")
})

# ---- json_array --------------------------------------------------------------

test_that("json_array() constructs from multiple args", {
  x <- json_array(1, "two", TRUE)
  expect_s7_class(x, jst::json_array)
  expect_length(x@elements, 3L)
})

test_that("json_array() with atomic vector expands to per-element", {
  x <- json_array(1:3)
  expect_length(x@elements, 3L)
})

test_that("json_array() formats as JSON array", {
  expect_equal(format(json_array(1, 2, 3)), "[1, 2, 3]")
  expect_equal(format(json_array(1, "two", TRUE)), '[1, "two", true]')
})

test_that("json_array() handles nested json objects", {
  x <- json_array(json_null(), json_boolean(TRUE))
  expect_equal(format(x), "[null, true]")
})

test_that("json_array() empty is []", {
  expect_equal(format(json_array()), "[]")
})

# ---- json_object -------------------------------------------------------------

test_that("json_object() constructs from named args", {
  x <- json_object(a = 1, b = "hello")
  expect_s7_class(x, jst::json_object)
  expect_equal(names(x@members), c("a", "b"))
})

test_that("json_object() formats as JSON object", {
  expect_equal(format(json_object(x = 1, y = "hi")), '{"x": 1, "y": "hi"}')
})

test_that("json_object() empty is {}", {
  expect_equal(format(json_object()), "{}")
})

test_that("json_object() rejects unnamed args", {
  expect_error(json_object(1, 2), "must be named")
})

test_that("json_object() rejects partially unnamed args", {
  expect_error(json_object(a = 1, 2), "must be named")
})

test_that("json_object() escapes key names", {
  x <- json_object(`k"ey` = 1)
  expect_equal(format(x), '{"k\\"ey": 1}')
})
