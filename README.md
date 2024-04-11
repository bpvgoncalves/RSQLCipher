
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

RSQLCipher embeds the SQLCipher database engine in R and provides an
interface compliant with the DBI package.
[SQLCipher](https://www.zetetic.net/sqlcipher/open-source/) is an
open-source library that provides transparent and secure 256-bit AES
encryption of SQLite database files.
[SQLite](https://www.sqlite.org/index.html) is a public-domain,
single-user, very light-weight database engine that implements a decent
subset of the SQL 92 standard, including the core table creation,
updating, insertion, and selection operations, plus transaction
management.

This project started as a fork of the amazing
[RSQLite](https://rsqlite.r-dbi.org) package, for which its authors
deserve full credit. It is intended to keep this package updated with
new updates to the RSQLite package to keep both as compatible as
possible.

This package allows for the use of regular SQLite database files or
encrypted ones.

Currently, only the following differences exist between both drivers:

- `dbConnect()` with `RSQLCipher()` driver accepts the parameter `key`
  when creating a new encrypted database or opening a connection to an
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
    ##   0  :  3c 51 78 4c fb 3d 0e 79 a8 6e cd f0 d7 2b 34 1c  |  <QxL.=.y.n...+4.
    ##  16  :  c4 d0 99 f4 ee 37 20 00 f3 ef c3 d0 9d 33 81 0a  |  .....7 ......3..
    ##  32  :  04 47 f0 25 85 9a 90 a9 a9 38 6a ad 04 37 02 2d  |  .G.%.....8j..7.-
    ##  48  :  a0 4a 10 b2 63 62 0b 3e 62 ab 6e 31 9c a8 ae 67  |  .J..cb.>b.n1...g
    ##  64  :  f0 8c 74 90 eb 43 89 9b 31 2b a5 9e 46 f7 ef 7e  |  ..t..C..1+..F..~
    ##  80  :  4c 16 0b 67 c1 81 5e 29 64 92 3a 68 85 a8 33 ba  |  L..g..^)d.:h..3.
    ##  96  :  af d1 79 ab 26 90 a4 fa 1d 49 97 d7 ab 9c 1a 62  |  ..y.&....I.....b
    ## 112  :  21 c6 c9 44 ea ec 94 c5 71 6d c8 08 e7 1c b8 0b  |  !..D....qm......

``` r
file.remove(tmp_plain)
```

    ## [1] TRUE

``` r
file.remove(tmp_enc)
```

    ## [1] TRUE
