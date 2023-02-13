#' @rdname SQLCipher
#' @usage NULL
dbConnect_SQLiteConnection <- function(drv, ...) {
  if (drv@dbname %in% c("", ":memory:", "file::memory:")) {
    stop("Can't clone a temporary database", call. = FALSE)
  }

  dbConnect(SQLCipher(), drv@dbname,
    vfs = drv@vfs, flags = drv@flags,
    loadable.extensions = drv@loadable.extensions
  )
}
#' @rdname SQLCipher
#' @export
setMethod("dbConnect", "SQLiteConnection", dbConnect_SQLiteConnection)
