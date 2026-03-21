#' JSON value types
#'
#' @description
#' S7 classes for representing all JSON value types. The `json` class is the
#' abstract base; each JSON value type has a dedicated sub-class:
#'
#' | Class | JSON type | Constructor example |
#' |---|---|---|
#' | `json_null` | `null` | `json_null()` |
#' | `json_boolean` | `true` / `false` | `json_boolean(TRUE)` |
#' | `json_number` | number | `json_number(3.14)` |
#' | `json_string` | string | `json_string("hi")` |
#' | `json_vector` | typed array | `json_vector(1:20)`, `json_vector(c("a","b"))` |
#' | `json_array` | mixed array | `json_array(1, "two", json_null())` |
#' | `json_object` | object | `json_object(x = 1, y = "a")` |
#'
#' Use [to_json()] to coerce ordinary R values to the appropriate JSON type.
#' All JSON objects have `format()` and `print()` methods that produce valid
#' JSON text.
#'
#' @param value The R value to store (logical, numeric, or character scalar/vector).
#' @param ... Named or unnamed arguments passed to the constructor.
#'
#' @examples
#' json_null()
#' json_boolean(TRUE)
#' json_number(42)
#' json_string("hello")
#'
#' # json_vector: typed homogeneous array — stores the raw R vector
#' json_vector(1:20)
#' json_vector(c(1.5, 2.5, 3.5))
#' json_vector(c("apple", "banana", "cherry"))
#'
#' # json_array: mixed-type array — each element can differ
#' json_array(1, "two", TRUE, json_null())
#'
#' # json_object requires named arguments
#' json_object(x = 1, y = "hello", z = TRUE)
#' json_object(items = json_array(1:3), count = 3L)
#'
#' @name json-classes
NULL

# ---- Base class -------------------------------------------------------------

#' @rdname json-classes
#' @export
json <- S7::new_class("json")

# ---- json_null --------------------------------------------------------------

#' @rdname json-classes
#' @export
json_null <- S7::new_class(
  "json_null",
  parent = json
)

# ---- json_boolean -----------------------------------------------------------

#' @rdname json-classes
#' @export
json_boolean <- S7::new_class(
  "json_boolean",
  parent = json,
  properties = list(
    value  = S7::new_property(S7::class_logical, default = FALSE),
    length = S7::new_property(S7::class_integer)
  ),
  constructor = function(value = FALSE) {
    if (!is.logical(value) || length(value) != 1L || is.na(value)) {
      stop("`value` must be a non-NA scalar logical")
    }
    S7::new_object(json(), value = value, length = 1L)
  }
)

# ---- json_number ------------------------------------------------------------

#' @rdname json-classes
#' @export
json_number <- S7::new_class(
  "json_number",
  parent = json,
  properties = list(
    value  = S7::new_property(S7::class_numeric, default = 0),
    length = S7::new_property(S7::class_integer)
  ),
  constructor = function(value = 0) {
    value <- as.numeric(value)
    if (length(value) != 1L) {
      stop("`value` must be a scalar numeric")
    }
    if (is.nan(value) || is.infinite(value)) {
      stop("`value` must be finite (NaN and Inf are not valid JSON numbers)")
    }
    S7::new_object(json(), value = value, length = 1L)
  }
)

# ---- json_string ------------------------------------------------------------

#' @rdname json-classes
#' @export
json_string <- S7::new_class(
  "json_string",
  parent = json,
  properties = list(
    value  = S7::new_property(S7::class_character, default = ""),
    length = S7::new_property(S7::class_integer)
  ),
  constructor = function(value = "") {
    value <- as.character(value)
    if (length(value) != 1L) {
      stop("`value` must be a scalar character string")
    }
    S7::new_object(json(), value = value, length = 1L)
  }
)

# ---- json_vector ------------------------------------------------------------

#' @rdname json-classes
#' @export
json_vector <- S7::new_class(
  "json_vector",
  parent = json,
  properties = list(
    value  = S7::new_property(S7::class_any),
    type   = S7::new_property(S7::class_character),
    length = S7::new_property(S7::class_integer)
  ),
  constructor = function(value) {
    if (!is.character(value) && !is.integer(value) &&
        !is.double(value) && !is.logical(value)) {
      stop("`value` must be a character, integer, double, or logical vector")
    }
    if (length(value) == 0L) {
      stop("`value` must be a non-empty vector")
    }
    type <- if (is.character(value)) "string"
            else if (is.integer(value)) "integer"
            else if (is.double(value)) "double"
            else "logical"
    S7::new_object(json(), value = value, type = type, length = length(value))
  }
)

# ---- json_array -------------------------------------------------------------

#' @rdname json-classes
#' @export
json_array <- S7::new_class(
  "json_array",
  parent = json,
  properties = list(
    elements = S7::new_property(S7::class_list, default = list()),
    length   = S7::new_property(S7::class_integer)
  ),
  constructor = function(...) {
    args <- list(...)
    # Single atomic vector (e.g. 1:20 or c("a","b")) -> one element per item
    elements <- if (length(args) == 1L && is.atomic(args[[1L]])) {
      as.list(args[[1L]])
    } else {
      args
    }
    S7::new_object(json(), elements = elements, length = length(elements))
  }
)

# ---- json_object ------------------------------------------------------------

#' @rdname json-classes
#' @export
json_object <- S7::new_class(
  "json_object",
  parent = json,
  properties = list(
    members = S7::new_property(S7::class_list, default = list()),
    length  = S7::new_property(S7::class_integer)
  ),
  constructor = function(...) {
    args <- list(...)
    if (length(args) > 0L) {
      nms <- names(args)
      if (is.null(nms) || any(!nzchar(nms))) {
        stop("All arguments to `json_object()` must be named")
      }
    }
    S7::new_object(json(), members = args, length = length(args))
  }
)

# ---- Serialization ----------------------------------------------------------

## Escape a character string for inclusion inside JSON double-quotes.
.json_escape <- function(s) {
  s <- gsub("\\\\", "\\\\\\\\", s, fixed = FALSE) # \ -> \\
  s <- gsub('"',    '\\"',      s, fixed = TRUE)   # " -> \"
  s <- gsub("\n",   "\\n",      s, fixed = TRUE)   # newline
  s <- gsub("\r",   "\\r",      s, fixed = TRUE)   # CR
  s <- gsub("\t",   "\\t",      s, fixed = TRUE)   # tab
  s
}

## Convert an arbitrary R value (or json object) to a JSON string.
.r_to_json_str <- function(x) {
  if (inherits(x, "json") || S7::S7_inherits(x, json)) return(format(x))
  if (is.null(x))          return("null")
  if (is.logical(x)) {
    strs <- ifelse(x, "true", "false")
    if (length(x) == 1L) return(strs)
    return(paste0("[", paste(strs, collapse = ", "), "]"))
  }
  if (is.numeric(x) || is.integer(x)) {
    strs <- format(as.numeric(x), scientific = FALSE, trim = TRUE)
    if (length(x) == 1L) return(strs)
    return(paste0("[", paste(strs, collapse = ", "), "]"))
  }
  if (is.character(x)) {
    quoted <- paste0('"', .json_escape(x), '"')
    if (length(x) == 1L) return(quoted)
    return(paste0("[", paste(quoted, collapse = ", "), "]"))
  }
  if (is.list(x)) {
    if (!is.null(names(x))) {
      pairs <- mapply(
        function(k, v) paste0('"', .json_escape(k), '": ', .r_to_json_str(v)),
        names(x), x,
        SIMPLIFY = TRUE, USE.NAMES = FALSE
      )
      return(paste0("{", paste(pairs, collapse = ", "), "}"))
    } else {
      elems <- vapply(x, .r_to_json_str, character(1L))
      return(paste0("[", paste(elems, collapse = ", "), "]"))
    }
  }
  stop(
    "Cannot convert object of class <",
    paste(class(x), collapse = "/"),
    "> to JSON"
  )
}

## Internal S7 generic — one method per concrete json sub-class.
.json_format <- S7::new_generic(".json_format", "x")

S7::method(.json_format, json_null) <- function(x, ...) {
  "null"
}

S7::method(.json_format, json_boolean) <- function(x, ...) {
  if (x@value) "true" else "false"
}

S7::method(.json_format, json_number) <- function(x, ...) {
  format(x@value, scientific = FALSE, trim = TRUE)
}

S7::method(.json_format, json_string) <- function(x, ...) {
  paste0('"', .json_escape(x@value), '"')
}

S7::method(.json_format, json_vector) <- function(x, ...) {
  v <- x@value
  elems <- if (is.character(v)) {
    paste0('"', .json_escape(v), '"')
  } else if (is.logical(v)) {
    ifelse(v, "true", "false")
  } else {
    format(v, scientific = FALSE, trim = TRUE)
  }
  paste0("[", paste(elems, collapse = ", "), "]")
}

S7::method(.json_format, json_array) <- function(x, ...) {
  elems <- vapply(x@elements, .r_to_json_str, character(1L))
  paste0("[", paste(elems, collapse = ", "), "]")
}

S7::method(.json_format, json_object) <- function(x, ...) {
  if (length(x@members) == 0L) return("{}")
  pairs <- mapply(
    function(k, v) paste0('"', .json_escape(k), '": ', .r_to_json_str(v)),
    names(x@members), x@members,
    SIMPLIFY = TRUE, USE.NAMES = FALSE
  )
  paste0("{", paste(pairs, collapse = ", "), "}")
}

#' @export
format.json <- function(x, ...) .json_format(x, ...)

#' @export
format.S7_object <- function(x, ...) {
  if (S7::S7_inherits(x, json)) .json_format(x, ...) else NextMethod()
}

# ---- Pretty printing --------------------------------------------------------

## Build a one-line or indented representation of a plain R value stored
## inside json_array / json_object elements.
.json_pretty_r <- function(x, indent, depth, vector_max) {
  if (inherits(x, "json") || S7::S7_inherits(x, json))
    return(.json_pretty_impl(x, indent, depth, vector_max))
  .r_to_json_str(x)
}

## Recursive pretty-printer for json objects.
.json_pretty_impl <- function(x, indent, depth, vector_max) {
  pad  <- strrep(" ", indent * depth)
  pad1 <- strrep(" ", indent * (depth + 1L))

  if (S7::S7_inherits(x, json_null))    return("null")
  if (S7::S7_inherits(x, json_boolean)) return(if (x@value) "true" else "false")
  if (S7::S7_inherits(x, json_number))  return(format(x@value, scientific = FALSE, trim = TRUE))
  if (S7::S7_inherits(x, json_string))  return(paste0('"', .json_escape(x@value), '"'))

  if (S7::S7_inherits(x, json_vector)) {
    v      <- x@value
    n      <- length(v)
    shown  <- min(n, vector_max)
    elems  <- if (is.character(v)) {
      paste0('"', .json_escape(v[seq_len(shown)]), '"')
    } else if (is.logical(v)) {
      ifelse(v[seq_len(shown)], "true", "false")
    } else {
      format(v[seq_len(shown)], scientific = FALSE, trim = TRUE)
    }
    suffix <- if (n > shown) paste0(", ... (", n - shown, " more)") else ""
    return(paste0("[", paste(elems, collapse = ", "), suffix, "]"))
  }

  if (S7::S7_inherits(x, json_array)) {
    elems <- x@elements
    if (length(elems) == 0L) return("[]")
    inner <- vapply(elems, function(e) {
      paste0(pad1, .json_pretty_r(e, indent, depth + 1L, vector_max))
    }, character(1L))
    return(paste0("[\n", paste(inner, collapse = ",\n"), "\n", pad, "]"))
  }

  if (S7::S7_inherits(x, json_object)) {
    ms <- x@members
    if (length(ms) == 0L) return("{}")
    inner <- mapply(function(k, v) {
      paste0(pad1, '"', .json_escape(k), '": ',
             .json_pretty_r(v, indent, depth + 1L, vector_max))
    }, names(ms), ms, SIMPLIFY = TRUE, USE.NAMES = FALSE)
    return(paste0("{\n", paste(inner, collapse = ",\n"), "\n", pad, "}"))
  }

  format(x)
}

#' Pretty-print a JSON object
#'
#' Produces an indented, human-readable JSON string suitable for display.
#' Arrays produced by [json_vector] are always rendered on a single line; if
#' the vector contains more than `vector_max` elements the remainder is
#' replaced with `... (N more)`.  The global default for `vector_max` can be
#' set via `options(jst.vector_max = <n>)`.
#'
#' @param x A [json] object.
#' @param indent Number of spaces per indentation level (default `2`).
#' @param vector_max Maximum number of elements to show for [json_vector]
#'   before truncating.  Defaults to `getOption("jst.vector_max", 10L)`.
#' @return A single character string (invisibly from `print`).
#' @export
json_pretty <- function(x,
                        indent     = 2L,
                        vector_max = getOption("jst.vector_max", 10L)) {
  .json_pretty_impl(x, indent = indent, depth = 0L, vector_max = vector_max)
}

## Build the one-line header shown at the top of every print output.
.json_header <- function(x) {
  cls  <- sub("^.*::", "", class(x)[[1L]])
  info <- if (S7::S7_inherits(x, json_null)) {
    ""
  } else if (S7::S7_inherits(x, json_vector)) {
    paste0(" [length:", x@length, ", type:", x@type, "]")
  } else {
    paste0(" [length:", x@length, "]")
  }
  paste0("<", cls, info, ">")
}

#' @export
print.json <- function(x, ...,
                       indent     = 2L,
                       vector_max = getOption("jst.vector_max", 10L),
                       max_lines  = getOption("jst.max_lines",  20L)) {
  cat(.json_header(x), "\n")
  pretty <- json_pretty(x, indent = indent, vector_max = vector_max)
  lines  <- strsplit(pretty, "\n", fixed = TRUE)[[1L]]
  if (length(lines) > max_lines) {
    lines <- c(lines[seq_len(max_lines)],
               paste0("... (", length(lines) - max_lines, " more lines)"))
  }
  cat(paste(lines, collapse = "\n"), "\n")
  invisible(x)
}

#' @export
print.S7_object <- function(x, ...) {
  if (S7::S7_inherits(x, json)) print.json(x, ...) else NextMethod()
}

# ---- Apply ------------------------------------------------------------------

#' Apply a function over elements of a JSON array or object
#'
#' Applies `f` to each element of a [json_array] or each member value of a
#' [json_object] and returns a new JSON object of the same type with the
#' transformed values.  Works like [base::lapply] but preserves the JSON
#' container type.
#'
#' @param x A [json_array] or [json_object].
#' @param f A function.  For [json_array] it receives each element; for
#'   [json_object] it receives each member value.  The return value must be
#'   something accepted by the respective constructor — a plain R scalar,
#'   vector, list, `NULL`, or a [json] object.
#' @param ... Additional arguments passed to `f`.
#' @return A [json_array] or [json_object] (same class as `x`) whose
#'   elements/members are the results of calling `f`.
#' @export
#' @examples
#' # Scale every number in an object
#' obj <- json_object(a = 1, b = 2, c = 3)
#' json_lapply(obj, function(v) v * 2)
#'
#' # Wrap plain values as typed json objects
#' arr <- json_array(1, "hello", TRUE)
#' json_lapply(arr, to_json)
json_lapply <- function(x, f, ...) {
  if (S7::S7_inherits(x, json_object)) {
    new_members <- lapply(x@members, f, ...)
    do.call(json_object, new_members)
  } else if (S7::S7_inherits(x, json_array)) {
    new_elements <- lapply(x@elements, f, ...)
    do.call(json_array, new_elements)
  } else {
    stop("`x` must be a json_array or json_object")
  }
}

# ---- Coercion ---------------------------------------------------------------

#' Coerce R values to JSON
#'
#' Converts common R types to the appropriate [json] sub-class:
#' * `NULL`       -> [json_null]
#' * `logical(1)` -> [json_boolean]; longer logical -> [json_array]
#' * `numeric(1)` / `integer(1)` -> [json_number]; longer -> [json_vector]
#' * `character(1)` -> [json_string]; longer -> [json_vector]
#' * named `list` -> [json_object]; unnamed `list` -> [json_array]
#' * Any [json] value is returned unchanged.
#'
#' @param x An R object.
#' @param ... Unused.
#' @return A [json] object.
#' @export
#' @examples
#' to_json(NULL)
#' to_json(TRUE)
#' to_json(1:5)
#' to_json(list(a = 1, b = "x"))
to_json <- function(x, ...) UseMethod("to_json")

#' @export
to_json.NULL <- function(x, ...) json_null()

#' @export
to_json.logical <- function(x, ...) {
  if (length(x) == 1L) json_boolean(x) else json_vector(x)
}

#' @export
to_json.integer <- function(x, ...) {
  if (length(x) == 1L) json_number(x) else json_vector(x)
}

#' @export
to_json.numeric <- function(x, ...) {
  if (length(x) == 1L) json_number(x) else json_vector(x)
}

#' @export
to_json.character <- function(x, ...) {
  if (length(x) == 1L) json_string(x) else json_vector(x)
}

#' @export
to_json.list <- function(x, ...) {
  if (!is.null(names(x))) do.call(json_object, x) else do.call(json_array, x)
}

#' @export
to_json.json <- function(x, ...) x

#' @export
to_json.S7_object <- function(x, ...) {
  if (S7::S7_inherits(x, json)) x else stop("no to_json method for this S7 object")
}
