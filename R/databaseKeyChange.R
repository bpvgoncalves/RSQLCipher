#' databaseKeyChange
#'
#' Changes the key for an encrypted database.
#'
#' @param conn     database Connection
#' @param old_key  Old database key, a character string of size 64, containing
#'   32 hex encoded characters currently used as key for the database.
#' encryption.
#' @param new_key  New database key, a character string of size 64, containing
#'   32 hex encoded characters to be used as new key for the database.
#'
#' @usage NULL
#' @returns True if successful or False otherwise#'
#' @export
#' @examples
#'   key_1 <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
#'   key_2 <- "ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789"
#'   tmp_file <- tempfile()
#'   con <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1)
#'
#'   databaseKeyChange(con, key_1, key_2)
#'   dbDisconnect(con)
#'
#'   con2 <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_2)
#'
databaseKeyChange <- function(conn, old_key = NULL, new_key = NULL) {

  if (!is.hex(old_key)) {
    warning("Cannot change database key. The 'old_key' provided has invalid type.")
    return(invisible(FALSE))
  }

  if (!is.hex(new_key)) {
    warning("Cannot change database key. The 'new_key' provided has invalid type.")
    return(invisible(FALSE))
  }

  old_key <- gsub(" ", "", old_key, fixed = TRUE) # eliminate potential spaces to eval len
  if (nchar(old_key) != 64) {
    warning("Cannot change database key. The 'old_key' provided has invalid length.")
    return(invisible(FALSE))
  }

  new_key <- gsub(" ", "", new_key, fixed = TRUE) # eliminate potential spaces to eval len
  if (nchar(new_key) != 64) {
    warning("Cannot change database key. The 'new_key' provided has invalid length.")
    return(invisible(FALSE))
  }

  dbExecute(conn, sprintf("PRAGMA key = \"x'%s'\";", old_key))
  dbExecute(conn, sprintf("PRAGMA rekey = \"x'%s'\";", new_key))
  invisible(TRUE)
}


#' dbChangeKey
#' `r lifecycle::badge('deprecated')`
#'
#' Changes the key for an encrypted database.
#'
#' @param conn     database Connection
#' @param old_key  Old database key, a character string of size 64, containing
#'   32 hex encoded characters currently used as key for the database.
#' encryption.
#' @param new_key  New database key, a character string of size 64, containing
#'   32 hex encoded characters to be used as new key for the database.
#' @export
#' @seealso [databaseKeyChange()]
dbChangeKey <- function(conn, old_key = NULL, new_key = NULL) {
  lifecycle::deprecate_soft("1.0.0", "dbChangeKey()", "databaseKeyChange()")
  databaseKeyChange(conn, old_key, new_key)
}
