
# Regular expression source code
register_misc_extension <- function(name) {
  ext_dir <- "src/vendor/extensions/"
  if (!dir.exists(ext_dir))
    dir.create(ext_dir, recursive = TRUE)

  text <- readLines(paste0(tmp_source_dir, "/ext/misc/", name, ".c"))
  text <- gsub(" +$", "", text)
  writeLines(text, paste0(ext_dir, name, ".c"))

  # TODO compile as shared library? see https://www.sqlite.org/loadext.html
  lines <- c(
    "#define SQLITE_CORE",
    "#include <R_ext/Visibility.h>",
    paste0("#define sqlite3_", name, "_init attribute_visible sqlite3_", name, "_init"),
    "",
    paste0('#include "vendor/extensions/', name, '.c"')
  )

  writeLines(lines, paste0("src/ext-", name, ".c"))
}


usethis::use_version("dev", FALSE)

# Identify latest version and download source tar from Github
html <- xml2::as_list(
  xml2::read_html("https://github.com/sqlcipher/sqlcipher/releases/latest"))[[1]]
ver <- regmatches(html$head$title[[1]],
                  regexpr("[0-9]+\\.[0-9]+\\.[0-9]+",
                          html$head$title[[1]]))

tmp_source_tar <- tempfile()
latest_code <- paste0("https://github.com/sqlcipher/sqlcipher/archive/refs/tags/v", ver, ".tar.gz")
download.file(latest_code, tmp_source_tar)

# Extract and make 'amalgamation' file
tmp_source_dir <- tempdir()
untar(tmp_source_tar, exdir = tmp_source_dir)

tmp_source_dir <- paste0(tmp_source_dir, "/sqlcipher-", ver)

system(paste0("cd ", tmp_source_dir, " && ./configure --enable-all && make sqlite3.c"))

# Copy main sources and headers
text <- readLines(paste0(tmp_source_dir, "/sqlite3.h"))
text <- gsub(" +$", "", text)
writeLines(text, paste0("src/vendor/sqlite3/sqlite3.h"))
tmp_sqlite_ver <- grepv("#define SQLITE_VERSION ", text)
sqlite_ver <- regmatches(tmp_sqlite_ver, regexpr("[0-9]+\\.[0-9]+\\.[0-9]+",tmp_sqlite_ver))
rm(tmp_sqlite_ver)

text <- readLines(paste0(tmp_source_dir, "/sqlite3.c"))
text <- gsub(" +$", "", text)
writeLines(text, paste0("src/vendor/sqlite3/sqlite3.c"))

# Copy extensions sources and headers
text <- readLines(paste0(tmp_source_dir, "/src/sqlite3ext.h"))
text <- gsub(" +$", "", text)
writeLines(text, paste0("src/vendor/extensions/sqlite3ext.h"))
rm(text)

register_misc_extension("regexp")
register_misc_extension("series")
register_misc_extension("csv")
register_misc_extension("uuid")

# Commit changes
if (any(grepl("^src/", gert::git_status()$file))) {
  # branch <- paste0("dev_bundled_source-", ver)
  # message("Changes detected, creating branch: ", branch)
  #
  # old_branch <- gert::git_branch()
  # message("Old branch: ", old_branch)
  #
  # gert::git_branch_create(branch)
  gert::git_add("src")

  commit_msg <- paste0("build: upgrade bundled SQLCipher to ", ver, " (SQLite ", sqlite_ver, ")")
  message("Commit message: ", commit_msg)
  gert::git_commit(commit_msg)

}

# Patch new sources and commit
for (f in dir("patch", full.names = TRUE)) {
  message("Applying ", f)
  stopifnot(system(paste0("patch -p1 -i ", f)) == 0)
}

if (any(grepl("^src/", gert::git_status()$file))) {

  gert::git_add("src")

  commit_msg <- paste0("fix: apply patches")
  message("Commit message: ", commit_msg)
  gert::git_commit(commit_msg)
}

gert::git_branch_checkout(old_branch)
gert::git_merge(branch)
