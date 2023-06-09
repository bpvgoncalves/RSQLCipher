% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/copy.R
\name{sqliteCopyDatabase}
\alias{sqliteCopyDatabase}
\title{Copy a SQLite database}
\usage{
sqliteCopyDatabase(from, to)
}
\arguments{
\item{from}{A \code{SQLiteConnection} object. The main database in
\code{from} will be copied to \code{to}.}

\item{to}{A \code{SQLiteConnection} object pointing to an empty database.}
}
\description{
Copies a database connection to a file or to another database
connection.  It can be used to save an in-memory database (created using
\code{dbname = ":memory:"} or
\code{dbname = "file::memory:"}) to a file or to create an in-memory database
a copy of another database.
}
\examples{
library(DBI)
# Copy the built in databaseDb() to an in-memory database
con <- dbConnect(RSQLCipher::SQLCipher(), ":memory:")
dbListTables(con)

db <- RSQLCipher::datasetsDb()
RSQLCipher::sqliteCopyDatabase(db, con)
dbDisconnect(db)
dbListTables(con)

dbDisconnect(con)
}
\references{
\url{https://www.sqlite.org/backup.html}
}
\author{
Seth Falcon
}
