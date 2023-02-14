#' @rdname SQLCipher
#' @usage NULL
dbDisconnect_SQLiteConnection <- function(conn, ...) {
  connection_release(conn@ptr)
  invisible(TRUE)
}
#' @rdname SQLCipher
#' @export
setMethod("dbDisconnect", "SQLiteConnection", dbDisconnect_SQLiteConnection)
