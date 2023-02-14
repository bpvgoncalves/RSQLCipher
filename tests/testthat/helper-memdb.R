memory_db <- function() {
  DBI::dbConnect(SQLCipher(), ":memory:")
}
