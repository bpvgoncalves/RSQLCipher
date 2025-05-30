#' Add useful extension functions
#'
#' Several extension functions are included in the \pkg{RSQLite} package.
#' When enabled via `initExtension()`, these extension functions can be used in
#' SQL queries.
#' Extensions must be enabled separately for each connection.
#'
#' The `"math"` extension functions are written by Liam Healy and made available
#' through the SQLite website (\url{https://www.sqlite.org/src/ext/contrib}).
#' This package contains a slightly modified version of the original code.
#' See the section "Available functions in the math extension" for details.
#'
#' The `"regexp"` extension provides a regular-expression matcher for POSIX
#' extended regular expressions,
#' as available through the SQLite source code repository
#' (\url{https://sqlite.org/src/file?filename=ext/misc/regexp.c}).
#' SQLite will then implement the `A regexp B` operator,
#' where `A` is the string to be matched and `B` is the regular expression.
#'
#' The `"series"` extension loads the table-valued function `generate_series()`,
#' as available through the SQLite source code repository
#' (\url{https://sqlite.org/src/file?filename=ext/misc/series.c}).
#'
#' The `"csv"` extension loads the function `csv()` that can be used to create
#' virtual tables,
#' as available through the SQLite source code repository
#' (\url{https://sqlite.org/src/file?filename=ext/misc/csv.c}).
#'
#' The `"uuid"` extension loads the functions `uuid()`, `uuid_str(X)` and
#' `uuid_blob(X)` that can be used to create universally unique identifiers,
#' as available through the SQLite source code repository
#' (\url{https://sqlite.org/src/file?filename=ext/misc/uuid.c}).
#'
#' @section Available functions in the math extension:
#'
#' \describe{
#' \item{Math functions}{acos, acosh, asin, asinh, atan, atan2, atanh, atn2,
#'   ceil, cos, cosh, cot, coth, degrees, difference, exp, floor, log, log10,
#'   pi, power, radians, sign, sin, sinh, sqrt, square, tan, tanh}
#' \item{String functions}{charindex, leftstr, ltrim, padc, padl, padr, proper,
#'   replace, replicate, reverse, rightstr, rtrim, strfilter, trim}
#' \item{Aggregate functions}{stdev, variance, mode, median, lower_quartile,
#'   upper_quartile}
#' }
#'
#' @param db A \code{\linkS4class{SQLiteConnection}} object to load these extensions into.
#' @param extension The extension to load.
#'
#' @export
#' @examples
#' library(DBI)
#' db <- RSQLCipher::datasetsDb()
#'
#' # math
#' RSQLCipher::initExtension(db)
#' dbGetQuery(db, "SELECT stdev(mpg) FROM mtcars")
#' sd(mtcars$mpg)
#'
#' # regexp
#' RSQLCipher::initExtension(db, "regexp")
#' dbGetQuery(db, "SELECT * FROM mtcars WHERE carb REGEXP '[12]'")
#'
#' # series
#' RSQLCipher::initExtension(db, "series")
#' dbGetQuery(db, "SELECT value FROM generate_series(0, 20, 5);")
#'
#' dbDisconnect(db)
#'
#' # csv
#' db <- dbConnect(RSQLCipher::SQLCipher())
#' RSQLCipher::initExtension(db, "csv")
#' # use the filename argument to mount CSV files from disk
#' sql <- paste0(
#'   "CREATE VIRTUAL TABLE tbl USING ",
#'   "csv(data='1,2', schema='CREATE TABLE x(a INT, b INT)')"
#' )
#' dbExecute(db, sql)
#' dbGetQuery(db, "SELECT * FROM tbl")
#'
#' # uuid
#' db <- dbConnect(RSQLCipher::SQLCipher())
#' RSQLCipher::initExtension(db, "uuid")
#' dbGetQuery(db, "SELECT uuid();")
#' dbDisconnect(db)
initExtension <- function(db, extension = c("math", "regexp", "series", "csv", "uuid")) {
  extension <- match.arg(extension)

  if (!db@loadable.extensions) {
    stop("Loadable extensions are not enabled for this db connection",
      call. = FALSE
    )
  }

  extension_load(db@ptr, get_lib_path(), paste0("sqlite3_", extension, "_init"))

  invisible(TRUE)
}

get_lib_path <- function() {
  lib_path <- getLoadedDLLs()[["RSQLCipher"]][["path"]]
  enc2utf8(lib_path)
}
