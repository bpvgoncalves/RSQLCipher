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

  dbExecute(conn, sprintf("PRAGMA key = \"x'%s'\";", old_key))
  if (is.character(new_key)) {
    if (nchar(new_key) == 64) {
      dbExecute(conn, sprintf("PRAGMA rekey = \"x'%s'\";", new_key))
    } else {
      warning("Cannot change database key. The 'new_key' provided has invalid length.")
      invisible(FALSE)
    }
  } else {
    warning("Cannot change database key. The 'new_key' provided has invalid type.")
    invisible(FALSE)
  }

  invisible(TRUE)
}
