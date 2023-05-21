
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
    ##   0  :  7a 8a fa fc 3b 0d b8 5e dd 4a 0e 61 cb 59 5e e9  |  z...;..^.J.a.Y^.
    ##  16  :  95 f1 87 24 77 82 bb d8 66 0a 3b 16 be 1a 26 c2  |  ...$w...f.;...&.
    ##  32  :  34 b3 dd 75 b7 f4 fc eb 36 6f c8 58 97 8d ab a5  |  4..u....6o.X....
    ##  48  :  40 a5 25 04 79 a5 9f 83 91 72 13 22 ae 10 bf 1b  |  @.%.y....r."....
    ##  64  :  00 5e 0b 45 14 e0 7b b7 1b f7 2b f2 e9 dd 33 f7  |  .^.E..{...+...3.
    ##  80  :  72 0a c0 4e d7 d4 c1 f8 2b 03 b9 30 b3 6e 3f 64  |  r..N....+..0.n?d
    ##  96  :  b0 b9 c0 35 46 d6 65 05 04 03 9b 46 7c 82 db 79  |  ...5F.e....F|..y
    ## 112  :  e4 e3 18 cb e2 d3 7a 0b 13 1b 6a ce d3 0d 22 68  |  ......z...j..."h

``` r
file.remove(tmp_plain)
```

    ## [1] TRUE

``` r
file.remove(tmp_enc)
```

    ## [1] TRUE
