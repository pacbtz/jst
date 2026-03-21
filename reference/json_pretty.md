# Pretty-print a JSON object

Produces an indented, human-readable JSON string suitable for display.
Arrays produced by
[json_vector](https://pacbtz.github.io/jst/reference/json-classes.md)
are always rendered on a single line; if the vector contains more than
`vector_max` elements the remainder is replaced with `... (N more)`. The
global default for `vector_max` can be set via
`options(jst.vector_max = <n>)`.

## Usage

``` r
json_pretty(x, indent = 2L, vector_max = getOption("jst.vector_max", 10L))
```

## Arguments

- x:

  A [json](https://pacbtz.github.io/jst/reference/json-classes.md)
  object.

- indent:

  Number of spaces per indentation level (default `2`).

- vector_max:

  Maximum number of elements to show for
  [json_vector](https://pacbtz.github.io/jst/reference/json-classes.md)
  before truncating. Defaults to `getOption("jst.vector_max", 10L)`.

## Value

A single character string (invisibly from `print`).
