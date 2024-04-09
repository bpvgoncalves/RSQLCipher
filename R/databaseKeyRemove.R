#' databaseKeyRemove
#'
#' Creates an unencrypted/plain copy of an existing encrypted database.
#' *THIS FUNCTION MAY TAKE LONG FOR BIG DATABASE FILES*
#'
#' @param conn  Connection to an existing encrypted database to be decrypted.
#' @param file  Optional, path to the new decrypted database. A temporary file will be generated if
#' not provided.
#'
#' @usage NULL
#' @returns A named list with True/False and the file name of the plain database
#' @export
#' @examples
#'   key <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
#'   tmp_file <- tempfile()
#'   con <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key)
#'   dbWriteTable(con, "mtcars", mtcars)
#'
#'   newDB <- databaseKeyRemove(con)
#'   print(newDB)
#'   dbDisconnect(con)
#'
#'   con2 <- dbConnect(RSQLCipher::SQLCipher(), newDB$file)
#'   dbListTables(con2)
#'   dbDisconnect(con2)
#'
databaseKeyRemove<- function(conn, file = tempfile()) {

  tryCatch({

    dbExecute(conn,
              "ATTACH DATABASE :f AS plain KEY '';",
              params = list(f = file))

    dbExecute(conn,
              "SELECT sqlcipher_export('plain');")

    dbExecute(conn,
              "DETACH DATABASE plain;")

    return(invisible(list(result = TRUE, file = file)))

  },
  condition = function(e) {
    warning("Couldn't remove key for database: ", conditionMessage(e),
            call. = FALSE)
    return(invisible(list(result = FALSE, file = file)))
  })
}
