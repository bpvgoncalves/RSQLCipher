#' Database Encryption Status
#'
#' Checks encryption status of an existing database.
#'
#' @param conn  Connection to an existing database to be checked.
#'
#' @usage NULL
#' @returns TRUE if the database as encryption enabled, or FALSE otherwise.
#'
#' @export
#' @examples
#'   key <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
#'   tmp_file <- tempfile()
#'   con <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key)
#'
#'   databaseIsEncryptionOn(con)  # Expect TRUE
#'
#'   dbDisconnect(con)
#'
databaseIsEncryptionOn <- function(conn) {

  tryCatch({
    st <- dbGetQuery(conn, "PRAGMA cipher_status;")[[1]]
    return(st == "1")
  },
  condition = function(e) {
    warning("Couldn't get database encryption status: ", conditionMessage(e),
            call. = FALSE)
    return(FALSE)
  })
}
