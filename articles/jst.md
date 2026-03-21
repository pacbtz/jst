# Getting started with jst

## Overview

**jst** provides S7 classes that model every JSON value type. You get a
typed R object — not just a raw string — that serialises to valid JSON
via [`format()`](https://rdrr.io/r/base/format.html) or
[`print()`](https://rdrr.io/r/base/print.html).

| Constructor                                                             | JSON type        | Example output     |
|-------------------------------------------------------------------------|------------------|--------------------|
| [`json_null()`](https://pacbtz.github.io/jst/reference/json-classes.md) | `null`           | `null`             |
| `json_boolean(x)`                                                       | `true` / `false` | `true`             |
| `json_number(x)`                                                        | number           | `42`               |
| `json_string(x)`                                                        | string           | `"hello"`          |
| `json_vector(x)`                                                        | typed array      | `[1, 2, 3]`        |
| `json_array(...)`                                                       | mixed array      | `[1, "two", null]` |
| `json_object(...)`                                                      | object           | `{"x": 1}`         |

All types share the abstract `json` base class, so you can use
`inherits(x, "json")` to check for any JSON value.

## Scalar types

``` r
json_null()
#> Registered S3 method overwritten by 'S7':
#>   method          from
#>   print.S7_object jst
#> <jst::json_null>
json_boolean(TRUE)
#> <jst::json_boolean>
#>  @ value: logi TRUE
json_boolean(FALSE)
#> <jst::json_boolean>
#>  @ value: logi FALSE
json_number(42)
#> <jst::json_number>
#>  @ value: num 42
json_number(3.14)
#> <jst::json_number>
#>  @ value: num 3.14
json_string("hello, world")
#> <jst::json_string>
#>  @ value: chr "hello, world"
```

Numbers are always serialised without scientific notation, and strings
are properly escaped:

``` r
json_number(1e6)          # not "1e+06"
#> <jst::json_number>
#>  @ value: num 1e+06
json_string('say "hi"')   # internal quotes escaped
#> <jst::json_string>
#>  @ value: chr "say \"hi\""
json_string("line1\nline2")
#> <jst::json_string>
#>  @ value: chr "line1\nline2"
```

## Arrays

Use
[`json_vector()`](https://pacbtz.github.io/jst/reference/json-classes.md)
for **homogeneous** arrays of numbers or strings — it stores the raw R
vector and is more efficient than
[`json_array()`](https://pacbtz.github.io/jst/reference/json-classes.md)
for large sequences:

``` r
json_vector(1:10)
#> <jst::json_vector>
#>  @ value: int [1:10] 1 2 3 4 5 6 7 8 9 10
json_vector(c("apple", "banana", "cherry"))
#> <jst::json_vector>
#>  @ value: chr [1:3] "apple" "banana" "cherry"
json_vector(c(1.5, 2.5, 3.5))
#> <jst::json_vector>
#>  @ value: num [1:3] 1.5 2.5 3.5
```

Use
[`json_array()`](https://pacbtz.github.io/jst/reference/json-classes.md)
for **mixed-type** arrays, including nested JSON values:

``` r
json_array(1, "two", TRUE, json_null())
#> <jst::json_array>
#>  @ elements:List of 4
#>  .. $ : num 1
#>  .. $ : chr "two"
#>  .. $ : logi TRUE
#>  .. $ : <jst::json_null>
json_array(json_boolean(FALSE), json_number(0), json_string(""))
#> <jst::json_array>
#>  @ elements:List of 3
#>  .. $ : <jst::json_boolean>
#>  ..  ..@ value: logi FALSE
#>  .. $ : <jst::json_number>
#>  ..  ..@ value: num 0
#>  .. $ : <jst::json_string>
#>  ..  ..@ value: chr ""
```

Passing a plain R vector to
[`json_array()`](https://pacbtz.github.io/jst/reference/json-classes.md)
expands it element-by-element:

``` r
json_array(1:5)          # same as json_array(1, 2, 3, 4, 5)
#> <jst::json_array>
#>  @ elements:List of 5
#>  .. $ : int 1
#>  .. $ : int 2
#>  .. $ : int 3
#>  .. $ : int 4
#>  .. $ : int 5
```

## Objects

[`json_object()`](https://pacbtz.github.io/jst/reference/json-classes.md)
takes **named** arguments and produces a JSON object. Values can be any
R scalar, vector, or already-constructed JSON value:

``` r
json_object(name = "Alice", age = 30, active = TRUE)
#> <jst::json_object>
#>  @ members:List of 3
#>  .. $ name  : chr "Alice"
#>  .. $ age   : num 30
#>  .. $ active: logi TRUE

json_object(
  id      = 1L,
  tags    = json_vector(c("r", "json")),
  address = json_object(city = "London", zip = "EC1A")
)
#> <jst::json_object>
#>  @ members:List of 3
#>  .. $ id     : int 1
#>  .. $ tags   : <jst::json_vector>
#>  ..  ..@ value: chr [1:2] "r" "json"
#>  .. $ address: <jst::json_object>
#>  ..  ..@ members:List of 2
#>  .. .. .. $ city: chr "London"
#>  .. .. .. $ zip : chr "EC1A"
```

## Coercion with `to_json()`

[`to_json()`](https://pacbtz.github.io/jst/reference/to_json.md)
converts plain R values to the most appropriate JSON type, so you rarely
have to call the low-level constructors by hand:

``` r
to_json(NULL)
#> <jst::json_null>
to_json(TRUE)
#> <jst::json_boolean>
#>  @ value: logi TRUE
to_json(99L)
#> <jst::json_number>
#>  @ value: num 99
to_json(3.14)
#> <jst::json_number>
#>  @ value: num 3.14
to_json("hello")
#> <jst::json_string>
#>  @ value: chr "hello"
```

Vectors of length \> 1 become arrays:

``` r
to_json(c(TRUE, FALSE, TRUE))   # json_array  (logical)
#> <jst::json_array>
#>  @ elements:List of 3
#>  .. $ : logi TRUE
#>  .. $ : logi FALSE
#>  .. $ : logi TRUE
to_json(1:5)                    # json_vector (integer)
#> <jst::json_vector>
#>  @ value: int [1:5] 1 2 3 4 5
to_json(c("a", "b", "c"))       # json_vector (character)
#> <jst::json_vector>
#>  @ value: chr [1:3] "a" "b" "c"
```

Named lists become objects; unnamed lists become arrays:

``` r
to_json(list(x = 1, y = "hi"))    # json_object
#> <jst::json_object>
#>  @ members:List of 2
#>  .. $ x: num 1
#>  .. $ y: chr "hi"
to_json(list(1, "two", TRUE))     # json_array
#> <jst::json_array>
#>  @ elements:List of 3
#>  .. $ : num 1
#>  .. $ : chr "two"
#>  .. $ : logi TRUE
```

Already-constructed `json` values pass through unchanged:

``` r
j <- json_boolean(TRUE)
identical(to_json(j), j)
#> [1] TRUE
```

## Building complex documents

Combine constructors and
[`to_json()`](https://pacbtz.github.io/jst/reference/to_json.md) to
build any JSON structure:

``` r
doc <- json_object(
  version  = 1L,
  enabled  = TRUE,
  config   = json_object(
    retries = 3L,
    tags    = json_vector(c("prod", "v2"))
  ),
  items    = json_array(
    json_object(id = 1L, label = "first"),
    json_object(id = 2L, label = "second")
  ),
  metadata = json_null()
)

cat(format(doc))
#> {"version": 1, "enabled": true, "config": {"retries": 3, "tags": ["prod", "v2"]}, "items": [{"id": 1, "label": "first"}, {"id": 2, "label": "second"}], "metadata": null}
```
