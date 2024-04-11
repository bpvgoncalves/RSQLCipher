
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RSQLCipher

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

[![R-CMD-check](https://github.com/bpvgoncalves/RSQLCipher/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bpvgoncalves/RSQLCipher/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/bpvgoncalves/RSQLCipher/branch/main/graph/badge.svg)](https://app.codecov.io/gh/bpvgoncalves/RSQLCipher?branch=develop)
![GitHub R package version
(branch)](https://img.shields.io/github/r-package/v/bpvgoncalves/RSQLCipher/main?color=black&label=Github)
![GitHub](https://img.shields.io/github/license/bpvgoncalves/RSQLCipher?color=black&label=License)
<!-- badges: end -->

Embeds the SQLCipher database engine in R and provides an interface
compliant with the DBI package.
[SQLCipher](https://www.zetetic.net/sqlcipher/open-source/) is an open
source library that provides transparent and secure 256-bit AES
encryption of SQLite database files.
[SQLite](https://www.sqlite.org/index.html) is a public-domain,
single-user, very light-weight database engine that implements a decent
subset of the SQL 92 standard, including the core table creation,
updating, insertion, and selection operations, plus transaction
management.

This project started as a fork from the amazing
[RSQLite](https://rsqlite.r-dbi.org) package for which its authors
deserve full credit. It is intended to keep this package updated with
new updates to the RSQLite package to keep both as much compatible as
possible.

This package allows for the use of regular SQLite database files or
encrypted ones.

Currently, only the following differences exist between both drivers:

- `dbConnect()` with `RSQLCipher()` driver accepts the parameter `key`
  when creating a new encrypted database or opening a connection to a
  existing one.

- There are 3 RSQLCipher specific functions:

  - `databaseKeyAdd()`, to create an encrypted copy of an existing plain
    database.

  - `databaseKeyChange()`, to modify the key on an encrypted database.

  - `databaseKeyRemove()`, to create a decrypted copy of an encrypted
    database.

<!-- You can install the latest released version from CRAN with: -->
<!-- ```R -->
<!-- install.packages("RSQLCipher") -->
<!-- ``` -->

You can install the latest development version from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("bpvgoncalves/RSQLCipher")
```

Discussions associated with DBI and related database packages take place
on [R-SIG-DB](https://stat.ethz.ch/mailman/listinfo/r-sig-db). The
website [Databases using R](https://solutions.posit.co/connections/db/)
describes the tools and best practices in this ecosystem.

## Usage

This package has identical interface to RSQLite.

``` r
library(DBI)

# Create an two temporary RSQLCipher databases on disk.
# A regular database and an encrypted one.
tmp_plain <- tempfile()
con_plain <- dbConnect(RSQLCipher::SQLCipher(), 
                       tmp_plain)

tmp_enc <- tempfile()
con_enc <- dbConnect(RSQLCipher::SQLCipher(), 
                     tmp_enc, 
                     key = "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF") 

# Both databases behave the same on regular usage...
dbWriteTable(con_plain, "mtcars", mtcars)
dbWriteTable(con_enc, "mtcars", mtcars)

stopifnot(identical(dbListTables(con_plain), 
                    dbListTables(con_enc)))
stopifnot(identical(dbListFields(con_plain, "mtcars"), 
                    dbListFields(con_enc, "mtcars")))
stopifnot(identical(dbReadTable(con_plain, "mtcars"), 
                    dbReadTable(con_enc, "mtcars")))

dbDisconnect(con_plain)
dbDisconnect(con_enc)

# ... but the database files on disk are different
if ("hexView" %in% installed.packages()) {
  cat(">> Plain database\n")
  print(hexView::readRaw(tmp_plain, nbytes = 128))
  cat(">> Encrypted database\n")
  print(hexView::readRaw(tmp_enc, nbytes = 128))
} else {
  cat(">> Plain database\n")
  print(suppressWarnings(readLines(tmp_plain)[1:10]))
  cat(">> Encrypted database\n")
  print(suppressWarnings(readLines(tmp_enc)[1:10]))
}
```

    ## >> Plain database
    ##   0  :  53 51 4c 69 74 65 20 66 6f 72 6d 61 74 20 33 00  |  SQLite format 3.
    ##  16  :  10 00 01 01 00 40 20 20 00 00 00 01 00 00 00 02  |  .....@  ........
    ##  32  :  00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 04  |  ................
    ##  48  :  00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00  |  ................
    ##  64  :  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |  ................
    ##  80  :  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01  |  ................
    ##  96  :  00 2e 72 a2 0d 00 00 00 01 0f 31 00 0f 31 00 00  |  ..r.......1..1..
    ## 112  :  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |  ................ 
    ## >> Encrypted database
    ##   0  :  f5 0c ab 3d 1f ef dd 74 e9 8d 8c 9b 0d e6 5c 2c  |  ...=...t......\,
    ##  16  :  0a 2b 10 57 8a 5c af 57 43 a2 cb b9 af bb ef 8c  |  .+.W.\.WC.......
    ##  32  :  3c 8b ae 72 d7 75 e6 4c ff 1e ba d8 41 f5 e1 4b  |  <..r.u.L....A..K
    ##  48  :  f3 68 f3 db 81 3c 7b 49 49 8d e4 d4 22 a4 21 c4  |  .h...<{II...".!.
    ##  64  :  a1 f3 4e ff 89 31 56 a7 90 de 49 da 20 8e 6b 22  |  ..N..1V...I. .k"
    ##  80  :  a2 e6 51 b3 f8 9a d5 b5 de 03 13 51 05 93 c2 2d  |  ..Q........Q...-
    ##  96  :  9a 6c ed 60 82 bc e2 4e 5e f1 e6 82 f3 2d ba 1e  |  .l.`...N^....-..
    ## 112  :  53 c4 f9 ac da 5e 72 fe e6 6e dd 97 59 42 0d 13  |  S....^r..n..YB..

``` r
file.remove(tmp_plain)
```

    ## [1] TRUE

``` r
file.remove(tmp_enc)
```

    ## [1] TRUE
