test_that("it is posible to remove a key", {
  on.exit({
    dbDisconnect(con)
    dbDisconnect(con2)
  })

  key <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
  tmp_file <- tempfile()
  con <- dbConnect(SQLCipher(), tmp_file, key = key)
  dbWriteTable(con, "mtcars", mtcars)

  newDB <- databaseKeyRemove(con)
  expect_true(newDB$result)

  con2 <- dbConnect(SQLCipher(), newDB$file)
  expect_identical(dbListTables(con), dbListTables(con2))

})


test_that("it is posible to remove a password", {
  on.exit({
    dbDisconnect(con)
    dbDisconnect(con2)
  })

  key <- "MY_super_SECURE_password"
  tmp_file <- tempfile()
  con <- dbConnect(SQLCipher(), tmp_file, key = key)
  dbWriteTable(con, "mtcars", mtcars)

  newDB <- databaseKeyRemove(con)
  expect_true(newDB$result)

  con2 <- dbConnect(SQLCipher(), newDB$file)
  expect_identical(dbListTables(con), dbListTables(con2))

})
