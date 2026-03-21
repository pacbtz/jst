#' @keywords internal
"_PACKAGE"

.onAttach <- function(libname, pkgname) {
  # S7 registers its own print.S7_object (which calls str()) after jst loads,
  # overwriting jst's version. Re-register jst's method last so json objects
  # auto-print as JSON strings rather than str() output.
  registerS3method("print", "S7_object", print.S7_object, envir = asNamespace(pkgname))
}
