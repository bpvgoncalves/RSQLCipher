
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
    ##   0  :  a5 3c f8 62 a6 ec c2 68 28 a0 72 1b f0 43 e1 26  |  .<.b...h(.r..C.&
    ##  16  :  f7 ed 79 c5 7e 39 e5 cf c7 80 8f b6 c8 5b 09 ba  |  ..y.~9.......[..
    ##  32  :  d5 a6 96 6c f6 ec 3f 05 db 2f 4f 5e fb 18 6f 37  |  ...l..?../O^..o7
    ##  48  :  80 9a 46 f7 a1 c9 a5 86 e2 f8 2a 0b 18 1c 30 e2  |  ..F.......*...0.
    ##  64  :  cf 6b 25 85 f4 55 7d 1e 72 8c 7b ba 6b d3 fc 23  |  .k%..U}.r.{.k..#
    ##  80  :  3b 79 05 9e 40 4f 05 d2 20 18 aa 19 75 82 ec fc  |  ;y..@O.. ...u...
    ##  96  :  e6 85 34 d2 c2 2d ea 9c d7 97 46 5b 9c bb 96 ec  |  ..4..-....F[....
    ## 112  :  c6 db 80 38 02 12 f3 14 04 29 7d 59 a8 3d d3 aa  |  ...8.....)}Y.=..

``` r
file.remove(tmp_plain)
```

    ## [1] TRUE

``` r
file.remove(tmp_enc)
```

    ## [1] TRUE
