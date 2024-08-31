test_that("fails on invalid new key", {
  on.exit(unlink(tmp_file))

  key_1 <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
  tmp_file <- tempfile()
  dt <- as.data.frame(c("fld1", "fld2"))
  con <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1)
  dbCreateTable(con, "tbltest", dt)

  # fails on invalid new key
  expect_warning(databaseKeyChange(con, key_1, 123456), "is not valid")
  expect_warning(databaseKeyChange(con, key_1, NA), "is not valid")
  expect_warning(databaseKeyChange(con, key_1, NULL), "is not valid")
  dbDisconnect(con)

  # it is still possible to connect with 'key_1'
  con2 <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1)
  expect_s4_class(con2, "SQLiteConnection")
  tbl <- dbListTables(con2)
  expect_length(tbl, 1)
  expect_equal(tbl, "tbltest")
  dbDisconnect(con2)
})


test_that("fails on invalid old key", {
  on.exit(unlink(tmp_file))

  key_1 <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
  key_2 <- "ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789"
  tmp_file <- tempfile()
  dt <- as.data.frame(c("fld1", "fld2"))
  con <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1)
  dbCreateTable(con, "tbltest", dt)

  # fails on invalid new key
  expect_warning(databaseKeyChange(con, 123456, key_2), "is not valid")
  expect_warning(databaseKeyChange(con, NA, key_2), "is not valid")
  expect_warning(databaseKeyChange(con, NULL, key_2), "is not valid")
  dbDisconnect(con)

  # it is still possible to connect with 'key_1'
  con2 <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1)
  expect_s4_class(con2, "SQLiteConnection")
  tbl <- dbListTables(con2)
  expect_length(tbl, 1)
  expect_equal(tbl, "tbltest")
  dbDisconnect(con2)
})


test_that("it is posible to change the database key -> key", {
  on.exit(unlink(tmp_file))

  key_1 <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
  key_2 <- "ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789"

  tmp_file <- tempfile()
  dt <- as.data.frame(c("fld1", "fld2"))
  con <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1)
  dbCreateTable(con, "tbltest", dt)

  expect_true(databaseKeyChange(con, key_1, key_2))
  dbDisconnect(con)

  # New key must work
  con2 <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_2)
  expect_s4_class(con2, "SQLiteConnection")
  tbl <- dbListTables(con2)
  expect_length(tbl, 1)
  expect_equal(tbl, "tbltest")
  dbDisconnect(con2)

  # Old key must not work
  expect_warning(con3 <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1))
  expect_s4_class(con3, "SQLiteConnection")
  expect_error(tbl <- dbListTables(con3))
  dbDisconnect(con3)
})


test_that("it is posible to change the database key -> pass", {
  on.exit(unlink(tmp_file))

  key_1 <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
  key_2 <- "my_new_password"

  tmp_file <- tempfile()
  dt <- as.data.frame(c("fld1", "fld2"))
  con <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1)
  dbCreateTable(con, "tbltest", dt)

  expect_true(databaseKeyChange(con, key_1, key_2))
  dbDisconnect(con)

  # New key must work
  con2 <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_2)
  expect_s4_class(con2, "SQLiteConnection")
  tbl <- dbListTables(con2)
  expect_length(tbl, 1)
  expect_equal(tbl, "tbltest")
  dbDisconnect(con2)

  # Old key must not work
  expect_warning(con3 <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1))
  expect_s4_class(con3, "SQLiteConnection")
  expect_error(tbl <- dbListTables(con3))
  dbDisconnect(con3)
})


test_that("it is posible to change the database pass -> key", {
  on.exit(unlink(tmp_file))

  key_1 <- "my_old_password"
  key_2 <- "ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789"

  tmp_file <- tempfile()
  dt <- as.data.frame(c("fld1", "fld2"))
  con <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1)
  dbCreateTable(con, "tbltest", dt)

  expect_true(databaseKeyChange(con, key_1, key_2))
  dbDisconnect(con)

  # New key must work
  con2 <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_2)
  expect_s4_class(con2, "SQLiteConnection")
  tbl <- dbListTables(con2)
  expect_length(tbl, 1)
  expect_equal(tbl, "tbltest")
  dbDisconnect(con2)

  # Old key must not work
  expect_warning(con3 <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1))
  expect_s4_class(con3, "SQLiteConnection")
  expect_error(tbl <- dbListTables(con3))
  dbDisconnect(con3)
})


test_that("it is posible to change the database pass -> pass", {
  on.exit(unlink(tmp_file))

  key_1 <- "my_old_password..."
  key_2 <- "...and my new password"

  tmp_file <- tempfile()
  dt <- as.data.frame(c("fld1", "fld2"))
  con <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1)
  dbCreateTable(con, "tbltest", dt)

  expect_true(databaseKeyChange(con, key_1, key_2))
  dbDisconnect(con)

  # New key must work
  con2 <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_2)
  expect_s4_class(con2, "SQLiteConnection")
  tbl <- dbListTables(con2)
  expect_length(tbl, 1)
  expect_equal(tbl, "tbltest")
  dbDisconnect(con2)

  # Old key must not work
  expect_warning(con3 <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1))
  expect_s4_class(con3, "SQLiteConnection")
  expect_error(tbl <- dbListTables(con3))
  dbDisconnect(con3)
})
