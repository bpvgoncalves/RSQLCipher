#' databaseKeyAdd
#'
#' Creates a copy of an existing database and encrypts it using the key.
#' *THIS FUNCTION MAY TAKE LONG FOR BIG DATABASE FILES*
#'
#' @param conn  Connection to existing database
#' @param key   New key to encrypt the database, a character string of size 64, containing 32
#' hex-encoded characters to be used as new key for the database.
#' @param file  Optional, path to the new encrypted database. a temporary file will be generated if
#' not provided.
#'
#' @usage NULL
#' @returns A named list with True/False and the file name of the encrypted database
#' @export
#' @examples
#'   key <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
#'   tmp_file <- tempfile()
#'   con <- dbConnect(RSQLCipher::SQLCipher(), tmp_file)
#'   dbWriteTable(con, "mtcars", mtcars)
#'
#'   newDB <- databaseKeyAdd(con, key)
#'   print(newDB)
#'
#'   con2 <- dbConnect(RSQLCipher::SQLCipher(), newDB$file) #, key = key)
#'   dbListTables(con2)
#'
databaseKeyAdd <- function(conn, key, file = tempfile()) {

  if (!is.hex(key)) {
    warning("Cannot set the database key. The 'key' provided has invalid type.")
    return(invisible(list(result = FALSE, file = file)))
  }

  key <- gsub(" ", "", key, fixed = TRUE) # eliminate potential spaces to eval len
  if (nchar(key) != 64) {
    warning("Cannot set the database key. The 'key' provided has invalid length.")
    return(invisible(list(result = FALSE, file = file)))
  }

  # tryCatch(
  #   dbExecute(conn, sprintf("PRAGMA key = \"x'%s'\";", key)),
  #   error = function(e) {
  #     warning("Couldn't set key for database: ", conditionMessage(e), "\n",
  #             "Use `key` = NULL to turn off this warning.",
  #             call. = FALSE
  #     )
  #   }
  # )

  new_conn <- dbConnect(SQLCipher(), file) #, key = key)
  connection_copy_database(conn@ptr, new_conn@ptr)
  return(invisible(list(result = TRUE, file = file)))
}
