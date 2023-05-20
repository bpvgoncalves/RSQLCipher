test_that("can connect to included datasets db", {
  db <- RSQLCipher::datasetsDb()
  expect_s4_class(db, "SQLiteConnection")

  tbl <- dbListTables(db)
  expect_type(tbl, "character")
  expect_length(tbl, 42)
})
