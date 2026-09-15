
test_that("it is posible to check encryption status", {
  on.exit(
    try({
      suppressWarnings(dbDisconnect(con))
      unlink(tmp_db, TRUE)
    }))

  key_1 <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
  key_2 <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"

  tmp_db <- tempfile()

  con <-  dbConnect(RSQLCipher::SQLCipher(), tmp_db)
  expect_false(databaseIsEncryptionOn(con))
  dbDisconnect(con)
  expect_warning(databaseIsEncryptionOn(con), "Couldn't get database encryption status")
  unlink(tmp_db)

  con <-  dbConnect(RSQLCipher::SQLCipher(), tmp_db, key = key_1)
  expect_true(databaseIsEncryptionOn(con))
  dbDisconnect(con)
  unlink(tmp_db)

  con <-  dbConnect(RSQLCipher::SQLCipher(), tmp_db, key = key_2)
  expect_true(databaseIsEncryptionOn(con))
  dbDisconnect(con)
  unlink(tmp_db)

  con <-  dbConnect(RSQLCipher::SQLCipher(), tmp_db, key = "my_password")
  expect_true(databaseIsEncryptionOn(con))
  dbDisconnect(con)
  expect_warning(databaseIsEncryptionOn(con), "Couldn't get database encryption status")
  unlink(tmp_db)

})
