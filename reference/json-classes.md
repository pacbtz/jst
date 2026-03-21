# JSON value types

S7 classes for representing all JSON value types. The `json` class is
the abstract base; each JSON value type has a dedicated sub-class:

|                |                  |                                                |
|----------------|------------------|------------------------------------------------|
| Class          | JSON type        | Constructor example                            |
| `json_null`    | `null`           | `json_null()`                                  |
| `json_boolean` | `true` / `false` | `json_boolean(TRUE)`                           |
| `json_number`  | number           | `json_number(3.14)`                            |
| `json_string`  | string           | `json_string("hi")`                            |
| `json_vector`  | typed array      | `json_vector(1:20)`, `json_vector(c("a","b"))` |
| `json_array`   | mixed array      | `json_array(1, "two", json_null())`            |
| `json_object`  | object           | `json_object(x = 1, y = "a")`                  |

Use [`to_json()`](https://pacbtz.github.io/jst/reference/to_json.md) to
coerce ordinary R values to the appropriate JSON type. All JSON objects
have [`format()`](https://rdrr.io/r/base/format.html) and
[`print()`](https://rdrr.io/r/base/print.html) methods that produce
valid JSON text.

## Usage

``` r
json()

json_null()

json_boolean(value = FALSE)

json_number(value = 0)

json_string(value = "")

json_vector(value)

json_array(...)

json_object(...)
```

## Arguments

- value:

  The R value to store (logical, numeric, or character scalar/vector).

- ...:

  Named or unnamed arguments passed to the constructor.

## Examples

``` r
json_null()
#> Registered S3 method overwritten by 'S7':
#>   method          from
#>   print.S7_object jst 
#> <jst::json_null>
json_boolean(TRUE)
#> <jst::json_boolean>
#>  @ value: logi TRUE
json_number(42)
#> <jst::json_number>
#>  @ value: num 42
json_string("hello")
#> <jst::json_string>
#>  @ value: chr "hello"

# json_vector: typed homogeneous array — stores the raw R vector
json_vector(1:20)
#> <jst::json_vector>
#>  @ value: int [1:20] 1 2 3 4 5 6 7 8 9 10 ...
json_vector(c(1.5, 2.5, 3.5))
#> <jst::json_vector>
#>  @ value: num [1:3] 1.5 2.5 3.5
json_vector(c("apple", "banana", "cherry"))
#> <jst::json_vector>
#>  @ value: chr [1:3] "apple" "banana" "cherry"

# json_array: mixed-type array — each element can differ
json_array(1, "two", TRUE, json_null())
#> <jst::json_array>
#>  @ elements:List of 4
#>  .. $ : num 1
#>  .. $ : chr "two"
#>  .. $ : logi TRUE
#>  .. $ : <jst::json_null>

# json_object requires named arguments
json_object(x = 1, y = "hello", z = TRUE)
#> <jst::json_object>
#>  @ members:List of 3
#>  .. $ x: num 1
#>  .. $ y: chr "hello"
#>  .. $ z: logi TRUE
json_object(items = json_array(1:3), count = 3L)
#> <jst::json_object>
#>  @ members:List of 2
#>  .. $ items: <jst::json_array>
#>  ..  ..@ elements:List of 3
#>  .. .. .. $ : int 1
#>  .. .. .. $ : int 2
#>  .. .. .. $ : int 3
#>  .. $ count: int 3
```
