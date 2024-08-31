#' Database Key Management - Add Key
#'
#' Creates an encrypted copy of an existing database, using the provided key.
#' *THIS FUNCTION MAY TAKE LONG FOR BIG DATABASE FILES*
#'
#' @param conn  Connection to an existing (plain) database to be encrypted.
#' @param key   A character string containing one of the following:
#'  (i) a character string to be used as password. PBKDF2 is applied to generate
#' a key from the entered string, or
#'  (ii) a character string of size 64, containing 32 hex encoded characters to
#' be used directly as key for database encryption, or
#'  (iii) a character string of size 96, containing 32 hex encoded characters to
#' be used directly as key for database encryption and 16 hex encoded characters
#' to be used as salt.
#' @param file  Optional, path to the new encrypted database. A temporary file
#' will be generated if not provided.
#'
#' @usage NULL
#' @returns A named list with True/False and the file name of the encrypted
#' database
#'
#' @export
#' @examples
#'   key <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
#'   tmp_file <- tempfile()
#'   con <- dbConnect(RSQLCipher::SQLCipher(), tmp_file)
#'   dbWriteTable(con, "mtcars", mtcars)
#'
#'   newDB <- databaseKeyAdd(con, key)
#'   print(newDB)
#'   dbDisconnect(con)
#'
#'   con2 <- dbConnect(RSQLCipher::SQLCipher(), newDB$file, key = key)
#'   dbListTables(con2)
#'   dbDisconnect(con2)
#'
databaseKeyAdd <- function(conn, key, file = tempfile()) {

  type <- key_type(key)
  if (is.na(type)) {
    warning("Cannot set the database key. The 'key' provided is not valid.")
    return(invisible(list(result = FALSE, file = file)))
  } else if (type == "key") {
    key <- paste0("x'", key, "'")
  }

  tryCatch({
    dbExecute(conn,
              "ATTACH DATABASE :f AS encrypted KEY :k;",
              params = list(f = file, k = key))

    dbExecute(conn,
              "SELECT sqlcipher_export('encrypted');")

    dbExecute(conn,
              "DETACH DATABASE encrypted;")

    return(invisible(list(result = TRUE, file = file)))

    },
    condition = function(e) {
      warning("Couldn't set key for database: ", conditionMessage(e),
              call. = FALSE)
      return(invisible(list(result = FALSE, file = file)))
  })
}
