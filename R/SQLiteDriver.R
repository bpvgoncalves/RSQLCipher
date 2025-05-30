#' @useDynLib RSQLCipher, .registration = TRUE
#' @importFrom bit64 integer64 is.integer64
#' @importFrom blob blob
NULL

#' Class SQLiteDriver (and methods)
#'
#' SQLiteDriver objects are created by [SQLCipher()], and used to select the
#' correct method in [DBI::dbConnect()].
#' They are a superclass of the [DBI::DBIDriver-class] class,
#' and used purely for dispatch.
#' The "Usage" section lists the class methods overridden by \pkg{RSQLCipher}.
#' The [DBI::dbUnloadDriver()] method is a null-op.
#'
#' @keywords internal
#' @export
setClass("SQLiteDriver",
  contains = "DBIDriver"
)

# Set during installation time for the correct library
PACKAGE_VERSION <- utils::packageVersion(utils::packageName())
