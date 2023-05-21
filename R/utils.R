vlapply <- function(X, FUN, ..., USE.NAMES = TRUE) {
  vapply(X = X, FUN = FUN, FUN.VALUE = logical(1L), ..., USE.NAMES = USE.NAMES)
}

vcapply <- function(X, FUN, ..., USE.NAMES = TRUE) {
  vapply(X = X, FUN = FUN, FUN.VALUE = character(1L), ..., USE.NAMES = USE.NAMES)
}

stopc <- function(...) {
  stop(..., call. = FALSE, domain = NA)
}

warningc <- function(...) {
  warning(..., call. = FALSE, domain = NA)
}

# memoise is used in .onLoad()
warning_once <- warningc

is.hex <- function(x) {
  if(!is.character(x)) {
    return(FALSE)
  } else {
    x <- gsub(" ", "", x, fixed = TRUE) # eliminate potential spaces to eval len
    return((nchar(x) %% 2 == 0) && (!grepl("[^0-9A-Fa-f]", x)))
  }
}
