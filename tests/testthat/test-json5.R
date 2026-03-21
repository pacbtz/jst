library(S7)

# ---- json_string -------------------------------------------------------------

test_that("json5: string uses single quotes", {
  expect_equal(format(json_string("hello"), json5 = TRUE), "'hello'")
})

test_that("json5: string double-quote default unchanged", {
  expect_equal(format(json_string("hello")), '"hello"')
})

test_that("json5: single quote inside string is escaped", {
  expect_equal(format(json_string("it's"), json5 = TRUE), "'it\\'s'")
})

test_that("json5: double quote inside string unescaped in json5 mode", {
  # In JSON5 single-quote mode, embedded " does not need escaping
  expect_equal(format(json_string('say "hi"'), json5 = TRUE), "'say \"hi\"'")
})

# ---- json_vector (character) -------------------------------------------------

test_that("json5: character vector uses single quotes", {
  expect_equal(
    format(json_vector(c("a", "b")), json5 = TRUE),
    "['a', 'b']"
  )
})

# ---- json_object keys --------------------------------------------------------

test_that("json5: identifier keys are unquoted", {
  expect_equal(
    format(json_object(x = 1, y = "a"), json5 = TRUE),
    "{x: 1, y: 'a'}"
  )
})

test_that("json5: non-identifier keys remain quoted", {
  obj <- json_object("my-key" = 1, "2bad" = 2)
  out <- format(obj, json5 = TRUE)
  expect_equal(out, '{"my-key": 1, "2bad": 2}')
})

test_that("json5: mixed identifier and non-identifier keys", {
  obj <- json_object(good = 1, "bad-key" = 2)
  out <- format(obj, json5 = TRUE)
  expect_equal(out, '{good: 1, "bad-key": 2}')
})

test_that("json5: $ and _ are valid identifier chars", {
  obj <- json_object(`$ref` = 1, `_private` = 2)
  out <- format(obj, json5 = TRUE)
  expect_equal(out, '{$ref: 1, _private: 2}')
})

# ---- nested structures -------------------------------------------------------

test_that("json5: nested object uses single quotes throughout", {
  obj <- json_object(a = json_object(b = "hello"))
  out <- format(obj, json5 = TRUE)
  expect_equal(out, "{a: {b: 'hello'}}")
})

test_that("json5: array with strings uses single quotes", {
  arr <- json_array("x", "y")
  expect_equal(format(arr, json5 = TRUE), "['x', 'y']")
})

# ---- json_pretty -------------------------------------------------------------

test_that("json5: json_pretty produces single-quoted strings", {
  s <- json_pretty(json_string("hi"), json5 = TRUE)
  expect_equal(s, "'hi'")
})

test_that("json5: json_pretty unquotes identifier keys", {
  out <- json_pretty(json_object(x = 1, y = "a"), json5 = TRUE)
  expect_equal(out, "{\n  x: 1,\n  y: 'a'\n}")
})

test_that("json5: json_pretty keeps quoted non-identifier keys", {
  out <- json_pretty(json_object("my-key" = 1), json5 = TRUE)
  expect_equal(out, '{\n  "my-key": 1\n}')
})

test_that("json5: json_pretty character vector uses single quotes", {
  out <- json_pretty(json_vector(c("a", "b")), json5 = TRUE)
  expect_equal(out, "['a', 'b']")
})

# ---- global option -----------------------------------------------------------

test_that("options(jst.json5 = TRUE) applies to format()", {
  withr::with_options(list(jst.json5 = TRUE), {
    expect_equal(format(json_string("hi")), "'hi'")
    expect_equal(format(json_object(x = 1)), "{x: 1}")
  })
})

test_that("options(jst.json5 = TRUE) applies to json_pretty()", {
  withr::with_options(list(jst.json5 = TRUE), {
    out <- json_pretty(json_object(a = "x"))
    expect_equal(out, "{\n  a: 'x'\n}")
  })
})

test_that("per-call json5 = FALSE overrides global option TRUE", {
  withr::with_options(list(jst.json5 = TRUE), {
    expect_equal(format(json_string("hi"), json5 = FALSE), '"hi"')
  })
})

test_that("per-call json5 = TRUE overrides global option FALSE", {
  withr::with_options(list(jst.json5 = FALSE), {
    expect_equal(format(json_string("hi"), json5 = TRUE), "'hi'")
  })
})
