#' @rdname SQLiteConnection-class
#' @usage NULL
dbDataType_SQLiteConnection <- function(dbObj, obj, ...) {
  dbDataType(SQLCipher(), obj, extended_types = dbObj@extended_types, ...)
}
#' @rdname SQLiteConnection-class
#' @export
setMethod("dbDataType", "SQLiteConnection", dbDataType_SQLiteConnection)
