#' @rdname SQLiteConnection-class
#' @usage NULL
sqlData_SQLiteConnection <- function(con, value,
                                     row.names = pkgconfig::get_config("RSQLCipher::row.names.query", FALSE),
                                     ...) {
  value <- sql_data(value, row.names)
  value <- quote_string(value, con)

  value
}
#' @rdname SQLiteConnection-class
#' @export
setMethod("sqlData", "SQLiteConnection", sqlData_SQLiteConnection)
