
test_that("it is posible to check encryption status", {

  key_1 <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
  key_2 <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"

  con <-  dbConnect(RSQLCipher::SQLCipher(), ":memory:")
  expect_false(databaseIsEncryptionOn(con))
  dbDisconnect(con)
  expect_warning(databaseIsEncryptionOn(con), "Couldn't get database encryption status")

  con <-  dbConnect(RSQLCipher::SQLCipher(), ":memory:", key = key_1)
  expect_true(databaseIsEncryptionOn(con))
  dbDisconnect(con)

  con <-  dbConnect(RSQLCipher::SQLCipher(), ":memory:", key = key_2)
  expect_true(databaseIsEncryptionOn(con))
  dbDisconnect(con)

  con <-  dbConnect(RSQLCipher::SQLCipher(), ":memory:", key = "my_password")
  expect_true(databaseIsEncryptionOn(con))
  dbDisconnect(con)
  expect_warning(databaseIsEncryptionOn(con), "Couldn't get database encryption status")

})
