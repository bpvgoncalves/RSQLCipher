test_that("it is posible to add a key", {
  on.exit({
    dbDisconnect(con)
    dbDisconnect(con2)
  })

  key <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
  tmp_file <- tempfile()
  con <- dbConnect(SQLCipher(), tmp_file)
  dbWriteTable(con, "mtcars", mtcars)

  newDB <- databaseKeyAdd(con, key)
  expect_true(newDB$result)

  con2 <- dbConnect(SQLCipher(), newDB$file, key = key)
  expect_identical(dbListTables(con), dbListTables(con2))

})
