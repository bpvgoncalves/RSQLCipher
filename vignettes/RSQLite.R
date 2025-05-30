## ---- echo = FALSE------------------------------------------------------------
knitr::opts_chunk$set(comment = "#>", collapse = TRUE)

## -----------------------------------------------------------------------------
library(DBI)

## -----------------------------------------------------------------------------
mydb <- dbConnect(RSQLCipher::SQLCipher(), "my-db.sqlite")
dbDisconnect(mydb)

## ----echo = FALSE-------------------------------------------------------------
unlink("my-db.sqlite")

## -----------------------------------------------------------------------------
mydb <- dbConnect(RSQLCipher::SQLCipher(), "")
dbDisconnect(mydb)

## -----------------------------------------------------------------------------
mydb <- dbConnect(RSQLCipher::SQLCipher(), "")
dbWriteTable(mydb, "mtcars", mtcars)
dbWriteTable(mydb, "iris", iris)
dbListTables(mydb)

## -----------------------------------------------------------------------------
dbGetQuery(mydb, 'SELECT * FROM mtcars LIMIT 5')

## -----------------------------------------------------------------------------
dbGetQuery(mydb, 'SELECT * FROM iris WHERE "Sepal.Length" < 4.6')

## -----------------------------------------------------------------------------
dbGetQuery(mydb, 'SELECT * FROM iris WHERE "Sepal.Length" < :x',
  params = list(x = 4.6))

## -----------------------------------------------------------------------------
rs <- dbSendQuery(mydb, 'SELECT * FROM mtcars')
while (!dbHasCompleted(rs)) {
  df <- dbFetch(rs, n = 10)
  print(nrow(df))
}
dbClearResult(rs)

## -----------------------------------------------------------------------------
rs <- dbSendQuery(mydb, 'SELECT * FROM iris WHERE "Sepal.Length" < :x')
dbBind(rs, params = list(x = 4.5))
nrow(dbFetch(rs))
dbBind(rs, params = list(x = 4))
nrow(dbFetch(rs))
dbClearResult(rs)

## -----------------------------------------------------------------------------
rs <- dbSendQuery(mydb, 'SELECT * FROM iris WHERE "Sepal.Length" = :x')
dbBind(rs, params = list(x = seq(4, 4.4, by = 0.1)))
nrow(dbFetch(rs))
dbClearResult(rs)

## -----------------------------------------------------------------------------
dbExecute(mydb, 'DELETE FROM iris WHERE "Sepal.Length" < 4')
rs <- dbSendStatement(mydb, 'DELETE FROM iris WHERE "Sepal.Length" < :x')
dbBind(rs, params = list(x = 4.5))
dbGetRowsAffected(rs)
dbClearResult(rs)

