# Coerce R values to JSON

Converts common R types to the appropriate
[json](https://pacbtz.github.io/jst/reference/json-classes.md)
sub-class:

- `NULL` -\>
  [json_null](https://pacbtz.github.io/jst/reference/json-classes.md)

- `logical(1)` -\>
  [json_boolean](https://pacbtz.github.io/jst/reference/json-classes.md);
  longer logical -\>
  [json_array](https://pacbtz.github.io/jst/reference/json-classes.md)

- `numeric(1)` / `integer(1)` -\>
  [json_number](https://pacbtz.github.io/jst/reference/json-classes.md);
  longer -\>
  [json_vector](https://pacbtz.github.io/jst/reference/json-classes.md)

- `character(1)` -\>
  [json_string](https://pacbtz.github.io/jst/reference/json-classes.md);
  longer -\>
  [json_vector](https://pacbtz.github.io/jst/reference/json-classes.md)

- named `list` -\>
  [json_object](https://pacbtz.github.io/jst/reference/json-classes.md);
  unnamed `list` -\>
  [json_array](https://pacbtz.github.io/jst/reference/json-classes.md)

- Any [json](https://pacbtz.github.io/jst/reference/json-classes.md)
  value is returned unchanged.

## Usage

``` r
to_json(x, ...)
```

## Arguments

- x:

  An R object.

- ...:

  Unused.

## Value

A [json](https://pacbtz.github.io/jst/reference/json-classes.md) object.

## Examples

``` r
to_json(NULL)
#> <jst::json_null>
to_json(TRUE)
#> <jst::json_boolean>
#>  @ value : logi TRUE
#>  @ length: int 1
to_json(1:5)
#> <jst::json_vector>
#>  @ value : int [1:5] 1 2 3 4 5
#>  @ type  : chr "integer"
#>  @ length: int 5
to_json(list(a = 1, b = "x"))
#> <jst::json_object>
#>  @ members:List of 2
#>  .. $ a: num 1
#>  .. $ b: chr "x"
#>  @ length : int 2
```
