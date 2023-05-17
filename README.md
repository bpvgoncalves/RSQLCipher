
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RSQLCipher

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

[![R-CMD-check](https://github.com/bpvgoncalves/RSQLCipher/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bpvgoncalves/RSQLCipher/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/bpvgoncalves/RSQLCipher/branch/main/graph/badge.svg)](https://app.codecov.io/gh/bpvgoncalves/RSQLCipher?branch=main)
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
    ##  96  :  00 2e 66 ea 0d 00 00 00 01 0f 31 00 0f 31 00 00  |  ..f.......1..1..
    ## 112  :  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |  ................ 
    ## >> Encrypted database
    ##   0  :  99 e9 7c 2a c5 80 d7 4b 69 aa e1 2a 00 f5 ef 81  |  ..|*...Ki..*....
    ##  16  :  a2 66 d7 13 7c 8f 90 13 bf 1d 24 54 93 0c 8f 72  |  .f..|.....$T...r
    ##  32  :  6a d3 ef 13 e3 c0 e0 db 43 4d 3c 4e e3 a2 78 c0  |  j.......CM<N..x.
    ##  48  :  19 d3 d3 6b bc 3f 97 90 2f 86 c5 39 64 84 a1 55  |  ...k.?../..9d..U
    ##  64  :  bd 2c 19 46 b7 61 9c bb 1c 33 75 6e 55 12 d2 62  |  .,.F.a...3unU..b
    ##  80  :  1d 93 68 ef 0f b8 cc c3 59 a7 ad 96 4f cc 1e 6d  |  ..h.....Y...O..m
    ##  96  :  b9 dc 3a 2f f3 d6 f0 ac 8a 09 9a ef 5a 4c f9 28  |  ..:/........ZL.(
    ## 112  :  98 2c 5c 1d 97 3a 9e 88 6d 7a e0 8a 7c a5 dc 57  |  .,\..:..mz..|..W

``` r
file.remove(tmp_plain)
```

    ## [1] TRUE

``` r
file.remove(tmp_enc)
```

    ## [1] TRUE
