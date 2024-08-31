#' Database Key Management - Change Key
#'
#' Changes the key for an encrypted database.
#' IMPORTANT: Currently it is not possible to change keys from different types,
#' i.e., if the original key is a password the new key MUST be a password and
#' if the original key is an hex key, the new key MUST be a hex key as well.
#'
#' @param conn     database Connection
#' @param old_key  The string currently used as key.
#' @param new_key  A string to be used as new key, be one of:
#'  (i) a character string to be used as password. PBKDF2 is applied to generate
#' a key from the entered string, or
#'  (ii) a character string of size 64, containing 32 hex encoded characters to
#' be used directly as key for database encryption, or
#'  (iii) a character string of size 96, containing 32 hex encoded characters to
#' be used directly as key for database encryption and 16 hex encoded characters
#' to be used as salt.
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

  old_type <- key_type(old_key)
  if (is.na(old_type)) {
    warning("Cannot change database key. The 'old_key' provided is not valid.")
    return(invisible(FALSE))
  }

  new_type <- key_type(new_key)
  if (is.na(new_type)) {
    warning("Cannot change database key. The 'new_key' provided is not valid.")
    return(invisible(FALSE))
  }

  # if (old_type != new_type) {
  #   warning("Cannot change database key.
  #           The 'old_key' and 'new_key' have different types.")
  #   return(invisible(FALSE))
  # }

  # old_key <- gsub(" ", "", old_key, fixed = TRUE) # eliminate potential spaces to eval len
  # if (nchar(old_key) != 64) {
  #   warning("Cannot change database key. The 'old_key' provided has invalid length.")
  #   return(invisible(FALSE))
  # }
  #
  # new_key <- gsub(" ", "", new_key, fixed = TRUE) # eliminate potential spaces to eval len
  # if (nchar(new_key) != 64) {
  #   warning("Cannot change database key. The 'new_key' provided has invalid length.")
  #   return(invisible(FALSE))
  # }

  if (old_type == "key") {
    dbExecute(conn, sprintf("PRAGMA key = \"x'%s'\";", old_key))
  } else {
    dbExecute(conn, sprintf("PRAGMA key = '%s';", old_key))
  }
  if (new_type == "key") {
    dbExecute(conn, sprintf("PRAGMA rekey = \"x'%s'\";", new_key))
  } else {
    dbExecute(conn, sprintf("PRAGMA rekey = '%s';", new_key))
  }
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
