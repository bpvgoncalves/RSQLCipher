
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RSQLCipher

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

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
    ##   0  :  31 49 1a 02 42 4c fc 11 63 77 c8 e5 4f 5d 2b 2b  |  1I..BL..cw..O]++
    ##  16  :  b4 bc c6 aa 3d f5 2d 88 ac 8f 88 35 0d a5 08 03  |  ....=.-....5....
    ##  32  :  66 df 1f a4 60 8a 69 1d 41 11 b4 23 d0 6d 63 9d  |  f...`.i.A..#.mc.
    ##  48  :  24 48 9b 80 56 f0 e1 ef f9 39 3d 59 9d 8d 9b f0  |  $H..V....9=Y....
    ##  64  :  3b 1b ed be 46 f1 3b 28 c9 e3 d1 a1 e9 69 4d 49  |  ;...F.;(.....iMI
    ##  80  :  8d 16 d8 58 6e db 8f 1a 7b be d0 0e 1b da 7d 08  |  ...Xn...{.....}.
    ##  96  :  fb 81 20 0a ef 85 7e 0d db c2 e6 9b 2a eb 86 a9  |  .. ...~.....*...
    ## 112  :  0e aa a0 26 00 ae 07 e9 16 4c be d1 3e 71 9a a4  |  ...&.....L..>q..

``` r
file.remove(tmp_plain)
```

    ## [1] TRUE

``` r
file.remove(tmp_enc)
```

    ## [1] TRUE
