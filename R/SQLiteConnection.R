#' Class SQLiteConnection (and methods)
#'
#' SQLiteConnection objects are created by passing [SQLCipher()] as first
#' argument to [DBI::dbConnect()].
#' They are a superclass of the [DBI::DBIConnection-class] class.
#' The "Usage" section lists the class methods overridden by \pkg{RSQLite}.
#'
#' @seealso
#' The corresponding generic functions
#' [DBI::dbSendQuery()], [DBI::dbGetQuery()],
#' [DBI::dbSendStatement()], [DBI::dbExecute()],
#' [DBI::dbExistsTable()], [DBI::dbListTables()], [DBI::dbListFields()],
#' [DBI::dbRemoveTable()], and [DBI::sqlData()].
#'
#' @keywords internal
#' @export
setClass("SQLiteConnection",
  contains = "DBIConnection",
  slots = list(
    ptr = "externalptr",
    dbname = "character",
    loadable.extensions = "logical",
    flags = "integer",
    vfs = "character",
    ref = "environment",
    bigint = "character",
    extended_types = "logical",
    key = "character"
  )
)

# format()
#' @export
#' @rdname SQLiteConnection-class
format.SQLiteConnection <- function(x, ...) {
  if (dbIsValid(x)) {
    details <- paste(
      c(
        if (x@dbname != "") x@dbname else "(temporary)",
        if (x@loadable.extensions) "(with extensions)"
      ),
      collapse = " "
    )
  } else {
    details <- "DISCONNECTED"
  }

  paste0("<SQLiteConnection> ", details)
}

as_table <- function(schema, table) {
  args <- c(schema = schema, table = table)
  # Also omits NA args
  args <- args[!is.na(args) & args != ""]
  do.call(Id, as.list(args))
}

#' Configure what SQLite should do when the database is locked
#'
#' @description
#' When a transaction cannot lock the database, because it is already
#' locked by another one, SQLite by default throws an error:
#' `database is locked`. This behavior is usually not appropriate when
#' concurrent access is needed, typically when multiple processes write to
#' the same database.
#'
#' `sqliteSetBusyHandler()` lets you set a timeout or a handler for these
#' events. When setting a timeout, SQLite will try the transaction multiple
#' times within this timeout. To set a timeout, pass an integer scalar to
#' `sqliteSetBusyHandler()`.
#'
#' Another way to set a timeout is to use a `PRAGMA`, e.g. the SQL query
#' ```sql
#' PRAGMA busy_timeout=3000
#' ```
#' sets the busy timeout to three seconds.
#'
#' @details
#' Note that SQLite currently does _not_ schedule concurrent transactions
#' fairly. If multiple transactions are waiting on the same database,
#' any one of them can be granted access next. Moreover, SQLite does not
#' currently ensure that access is granted as soon as the database is
#' available. Make sure that you set the busy timeout to a high enough
#' value for applications with high concurrency and many writes.
#'
#' If the `handler` argument is a function, then it is used as a callback
#' function. When the database is locked, this will be called with a single
#' integer, which is the number of calls for same locking event. The
#' callback function must return an integer scalar. If it returns `0L`,
#' then no additional attempts are made to access the database, and
#' an error is thrown. Otherwise another attempt is made to access the
#' database and the cycle repeats.
#'
#' Handler callbacks are useful for debugging concurrent behavior, or to
#' implement a more sophisticated busy algorithm. The latter is currently
#' considered experimental in RSQLite. If the callback function fails, then
#' RSQLite will print a warning, and the transaction is aborted with a
#' "database is locked" error.
#'
#' Note that every database connection has its own busy timeout or handler
#' function.
#'
#' Calling `sqliteSetBusyHandler()` on a connection that is not connected
#' is an error.
#'
#' @param dbObj A [SQLiteConnection-class] object.
#' @param handler Specifies what to do when the database is locked by
#' another transaction. It can be:
#' * `NULL`: fail immediately,
#' * an integer scalar: this is a timeout in milliseconds that corresponds
#'   to `PRAGMA busy_timeout`,
#' * an R function: this function is called with one argument, see details
#'   below.
#' @return Invisible `NULL`.
#'
#' @seealso <https://www.sqlite.org/c3ref/busy_handler.html>
#' @export
sqliteSetBusyHandler <- function(dbObj, handler) {
  stopifnot(
    inherits(dbObj, "SQLiteConnection"),
    is.null(handler) ||
      is.function(handler) ||
      (is.numeric(handler) && length(handler) == 1 && !is.na(handler))
  )
  if (is.numeric(handler)) {
    raw_handler <- as.integer(handler)
  } else if (is.function(handler)) {
    raw_handler <- function(...) {
      tryCatch(
        handler(...),
        interrupt = function(e) {
          0L
        },
        error = function(e) {
          0L
        }
      )
    }
  } else {
    raw_handler <- handler
  }

  set_busy_handler(dbObj@ptr, raw_handler)
}
