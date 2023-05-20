test_that("fails on invalid new key", {
  on.exit(unlink(tmp_file))

  key_1 <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
  tmp_file <- tempfile()
  dt <- as.data.frame(c("fld1", "fld2"))
  con <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1)
  dbCreateTable(con, "tbltest", dt)

  # fails on invalid new key
  expect_warning(dbChangeKey(con, key_1, "ABCDEF0123456789ABCDEF0123456789"), "invalid length")
  expect_warning(dbChangeKey(con, key_1, 123456), "invalid type")
  expect_warning(dbChangeKey(con, key_1, NA), "invalid type")
  expect_warning(dbChangeKey(con, key_1, NULL), "invalid type")
  dbDisconnect(con)

  # it is still possible to connect with 'key_1'
  con2 <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1)
  expect_s4_class(con2, "SQLiteConnection")
  tbl <- dbListTables(con2)
  expect_length(tbl, 1)
  expect_equal(tbl, "tbltest")
  dbDisconnect(con2)
})


test_that("it is posible to change the database key", {
  on.exit(unlink(tmp_file))

  key_1 <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
  key_2 <- "ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789"

  tmp_file <- tempfile()
  dt <- as.data.frame(c("fld1", "fld2"))
  con <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_1)
  dbCreateTable(con, "tbltest", dt)

  dbChangeKey(con, key_1, key_2)
  dbDisconnect(con)

  con2 <- dbConnect(RSQLCipher::SQLCipher(), tmp_file, key = key_2)
  expect_s4_class(con2, "SQLiteConnection")
  tbl <- dbListTables(con2)
  expect_length(tbl, 1)
  expect_equal(tbl, "tbltest")
  dbDisconnect(con2)
})
