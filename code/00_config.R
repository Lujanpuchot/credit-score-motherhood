# 00_config.R
# Paths shared by all scripts. Run everything from the repository root.
#
# The SCE microdata are not distributed with the repository (see data/README.md).
# By default they are expected in data/raw; set SCE_DATA_DIR to read them from
# somewhere else.

DIR_RAW     <- Sys.getenv("SCE_DATA_DIR", unset = file.path("data", "raw"))
DIR_DERIVED <- file.path("data", "derived")
DIR_TABLES  <- file.path("output", "tables")
DIR_FIGURES <- file.path("output", "figures")

for (d in c(DIR_DERIVED, DIR_TABLES, DIR_FIGURES)) {
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
}

FILES_RAW <- c(
  core_2013 = "SCE-Public-Microdata-Complete-2013-2016.xlsx",
  core_2017 = "SCE-Public-Microdata-Complete 2017-2019.xlsx",
  credit    = "SCE-Credit-Access-complete_microdata.xlsx"
)

missing_files <- FILES_RAW[!file.exists(file.path(DIR_RAW, FILES_RAW))]
if (length(missing_files) > 0) {
  stop("Raw files not found in ", DIR_RAW, ":\n  ", paste(missing_files, collapse = "\n  "),
       "\nSee data/README.md.")
}
