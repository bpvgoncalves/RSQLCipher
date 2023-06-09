% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datasetsDb.R
\name{datasetsDb}
\alias{datasetsDb}
\title{A sample sqlite database}
\usage{
datasetsDb()
}
\description{
This database is bundled with the package, and contains all data frames
in the datasets package.
}
\examples{
library(DBI)
db <- RSQLCipher::datasetsDb()
dbListTables(db)

dbReadTable(db, "CO2")
dbGetQuery(db, "SELECT * FROM CO2 WHERE conc < 100")

dbDisconnect(db)
}
