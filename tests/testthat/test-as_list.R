library(S7)

# ---- scalar types -----------------------------------------------------------

test_that("as.list on json_null returns NULL", {
  expect_null(as.list(json_null()))
})

test_that("as.list on json_boolean returns logical scalar", {
  expect_identical(as.list(json_boolean(TRUE)), TRUE)
  expect_identical(as.list(json_boolean(FALSE)), FALSE)
})

test_that("as.list on json_number returns numeric scalar", {
  expect_identical(as.list(json_number(3.14)), 3.14)
  expect_identical(as.list(json_number(0)), 0)
})

test_that("as.list on json_string returns character scalar", {
  expect_identical(as.list(json_string("hello")), "hello")
  expect_identical(as.list(json_string("")), "")
})

# ---- json_vector ------------------------------------------------------------

test_that("as.list on json_vector returns atomic vector", {
  expect_identical(as.list(json_vector(1:3)), 1:3)
  expect_identical(as.list(json_vector(c("a", "b"))), c("a", "b"))
  expect_identical(as.list(json_vector(c(TRUE, FALSE))), c(TRUE, FALSE))
  expect_identical(as.list(json_vector(c(1.5, 2.5))), c(1.5, 2.5))
})

# ---- json_array -------------------------------------------------------------

test_that("as.list on json_array returns unnamed list", {
  result <- as.list(json_array(1, "two", TRUE))
  expect_type(result, "list")
  expect_null(names(result))
  expect_equal(result[[1L]], 1)
  expect_equal(result[[2L]], "two")
  expect_equal(result[[3L]], TRUE)
})

test_that("as.list on json_array recurses into json elements", {
  result <- as.list(json_array(json_number(42), json_null()))
  expect_equal(result[[1L]], 42)
  expect_null(result[[2L]])
})

test_that("as.list on empty json_array returns empty list", {
  result <- as.list(json_array())
  expect_identical(result, list())
})

# ---- json_object ------------------------------------------------------------

test_that("as.list on json_object returns named list", {
  result <- as.list(json_object(a = 1, b = "x", c = TRUE))
  expect_type(result, "list")
  expect_equal(names(result), c("a", "b", "c"))
  expect_equal(result$a, 1)
  expect_equal(result$b, "x")
  expect_equal(result$c, TRUE)
})

test_that("as.list on json_object recurses into json member values", {
  obj <- json_object(n = json_number(7), s = json_string("hi"), z = json_null())
  result <- as.list(obj)
  expect_equal(result$n, 7)
  expect_equal(result$s, "hi")
  expect_null(result$z)
})

test_that("as.list on empty json_object returns empty named list", {
  result <- as.list(json_object())
  expect_identical(result, list())
})

# ---- nested structures ------------------------------------------------------

test_that("as.list recursively converts nested json_object", {
  obj <- json_object(
    inner = json_object(x = json_number(1), y = json_number(2)),
    val   = json_string("top")
  )
  result <- as.list(obj)
  expect_type(result$inner, "list")
  expect_equal(result$inner$x, 1)
  expect_equal(result$inner$y, 2)
  expect_equal(result$val, "top")
})

test_that("as.list recursively converts json_array inside json_object", {
  obj <- json_object(items = json_array(json_number(1), json_number(2)))
  result <- as.list(obj)
  expect_type(result$items, "list")
  expect_equal(result$items[[1L]], 1)
  expect_equal(result$items[[2L]], 2)
})

# ---- round-trip with to_json ------------------------------------------------

test_that("as.list(to_json(x)) round-trips a named list", {
  original <- list(a = 1, b = "hello", c = TRUE)
  result <- as.list(to_json(original))
  expect_equal(result$a, 1)
  expect_equal(result$b, "hello")
  expect_equal(result$c, TRUE)
})
