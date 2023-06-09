#' A sample sqlite database
#'
#' This database is bundled with the package, and contains all data frames
#' in the datasets package.
#'
#' @export
#' @examples
#' library(DBI)
#' db <- RSQLCipher::datasetsDb()
#' dbListTables(db)
#'
#' dbReadTable(db, "CO2")
#' dbGetQuery(db, "SELECT * FROM CO2 WHERE conc < 100")
#'
#' dbDisconnect(db)
datasetsDb <- function() {
  dbConnect(SQLCipher(), system.file("db", "datasets.sqlite", package = "RSQLCipher"),
    flags = SQLITE_RO
  )
}
