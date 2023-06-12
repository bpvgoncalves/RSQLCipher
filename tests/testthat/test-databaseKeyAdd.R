test_that("it is posible to add a key", {


  key <- "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
  tmp_file <- tempfile()
  con <- RSQLCipher::dbConnect(RSQLCipher::SQLCipher(), tmp_file)
  RSQLCipher::dbWriteTable(con, "mtcars", mtcars)

  newDB <- RSQLCipher::databaseKeyAdd(con, key)
  expect_true(newDB$result)

  con2 <- RSQLCipher::dbConnect(RSQLCipher::SQLCipher(), tmp_file) #, key = key)
  expect_identical(dbListTables(con), dbListTables(con2))

})
