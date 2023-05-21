#' dbChangeKey
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
#' @export
dbChangeKey <- function(conn, old_key = NULL, new_key = NULL) {

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
