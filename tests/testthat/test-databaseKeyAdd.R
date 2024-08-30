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


test_that("it is posible to add a password", {
  on.exit({
    dbDisconnect(con)
    dbDisconnect(con2)
  })

  key <- "new_pass"
  tmp_file <- tempfile()
  con <- dbConnect(SQLCipher(), tmp_file)
  dbWriteTable(con, "mtcars", mtcars)

  newDB <- databaseKeyAdd(con, key)
  expect_true(newDB$result)

  con2 <- dbConnect(SQLCipher(), newDB$file, key = key)
  expect_identical(dbListTables(con), dbListTables(con2))
})


test_that("fails with invalid key", {
  on.exit({
    dbDisconnect(con)
  })

  tmp_file <- tempfile()
  con <- dbConnect(SQLCipher(), tmp_file)
  dbWriteTable(con, "mtcars", mtcars)

  # wrong type
  key <- NULL
  expect_warning(newDB <- databaseKeyAdd(con, key),
                 "is not valid")
  expect_false(newDB$result)

  key <- NA
  expect_warning(newDB <- databaseKeyAdd(con, key),
                 "is not valid")
  expect_false(newDB$result)

  # right size, wrong type (not hex)
  key <- 1234
  expect_warning(newDB <- databaseKeyAdd(con, key),
                 "is not valid")
  expect_false(newDB$result)

})
