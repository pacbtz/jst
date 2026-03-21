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

#' @export
print.json <- function(x, ...) {
  cat(.json_format(x, ...), "\n")
  invisible(x)
}

#' @export
print.S7_object <- function(x, ...) {
  if (S7::S7_inherits(x, json)) {
    cat(.json_format(x, ...), "\n")
    invisible(x)
  } else {
    NextMethod()
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
