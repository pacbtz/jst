# Apply a function over elements of a JSON array or object

Applies `f` to each element of a
[json_array](https://pacbtz.github.io/jst/reference/json-classes.md) or
each member value of a
[json_object](https://pacbtz.github.io/jst/reference/json-classes.md)
and returns a new JSON object of the same type with the transformed
values. Works like [base::lapply](https://rdrr.io/r/base/lapply.html)
but preserves the JSON container type.

## Usage

``` r
json_lapply(x, f, ...)
```

## Arguments

- x:

  A [json_array](https://pacbtz.github.io/jst/reference/json-classes.md)
  or
  [json_object](https://pacbtz.github.io/jst/reference/json-classes.md).

- f:

  A function. For
  [json_array](https://pacbtz.github.io/jst/reference/json-classes.md)
  it receives each element; for
  [json_object](https://pacbtz.github.io/jst/reference/json-classes.md)
  it receives each member value. The return value must be something
  accepted by the respective constructor — a plain R scalar, vector,
  list, `NULL`, or a
  [json](https://pacbtz.github.io/jst/reference/json-classes.md) object.

- ...:

  Additional arguments passed to `f`.

## Value

A [json_array](https://pacbtz.github.io/jst/reference/json-classes.md)
or [json_object](https://pacbtz.github.io/jst/reference/json-classes.md)
(same class as `x`) whose elements/members are the results of calling
`f`.

## Examples

``` r
# Scale every number in an object
obj <- json_object(a = 1, b = 2, c = 3)
json_lapply(obj, function(v) v * 2)
#> <jst::json_object>
#>  @ members:List of 3
#>  .. $ a: num 2
#>  .. $ b: num 4
#>  .. $ c: num 6
#>  @ length : int 3

# Wrap plain values as typed json objects
arr <- json_array(1, "hello", TRUE)
json_lapply(arr, to_json)
#> <jst::json_array>
#>  @ elements:List of 3
#>  .. $ : <jst::json_number>
#>  ..  ..@ value : num 1
#>  ..  ..@ length: int 1
#>  .. $ : <jst::json_string>
#>  ..  ..@ value : chr "hello"
#>  ..  ..@ length: int 1
#>  .. $ : <jst::json_boolean>
#>  ..  ..@ value : logi TRUE
#>  ..  ..@ length: int 1
#>  @ length  : int 3
```
