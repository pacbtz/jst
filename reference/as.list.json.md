# Coerce a JSON object to a plain R value

Recursively converts a
[json](https://pacbtz.github.io/jst/reference/json-classes.md) object
back to ordinary R values:

- [json_null](https://pacbtz.github.io/jst/reference/json-classes.md)
  -\> `NULL`

- [json_boolean](https://pacbtz.github.io/jst/reference/json-classes.md)
  -\> `logical(1)`

- [json_number](https://pacbtz.github.io/jst/reference/json-classes.md)
  -\> `numeric(1)`

- [json_string](https://pacbtz.github.io/jst/reference/json-classes.md)
  -\> `character(1)`

- [json_vector](https://pacbtz.github.io/jst/reference/json-classes.md)
  -\> atomic vector (character / integer / double / logical)

- [json_array](https://pacbtz.github.io/jst/reference/json-classes.md)
  -\> unnamed `list` (elements recursively converted)

- [json_object](https://pacbtz.github.io/jst/reference/json-classes.md)
  -\> named `list` (member values recursively converted)

## Usage

``` r
# S3 method for class 'json'
as.list(x, ...)
```

## Arguments

- x:

  A [json](https://pacbtz.github.io/jst/reference/json-classes.md)
  object.

- ...:

  Unused.

## Value

An R value corresponding to the JSON type.

## Examples

``` r
as.list(json_object(a = 1, b = "hello", c = TRUE))
#> Registered S3 method overwritten by 'S7':
#>   method          from
#>   print.S7_object jst 
#> $a
#> [1] 1
#> 
#> $b
#> [1] "hello"
#> 
#> $c
#> [1] TRUE
#> 
as.list(json_array(1, "two", json_null()))
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [1] "two"
#> 
#> [[3]]
#> NULL
#> 
```
