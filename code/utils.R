# utils.R
# Small helpers to write tables as GitHub-flavored markdown.

write_md_table <- function(df, path, align_first = "l") {
  df[] <- lapply(df, as.character)
  header <- paste0("| ", paste(names(df), collapse = " | "), " |")
  rule   <- paste0("|", paste(c(if (align_first == "l") ":---" else "---:",
                                rep("---:", ncol(df) - 1)), collapse = "|"), "|")
  body   <- apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |"))
  writeLines(c(header, rule, body), path, useBytes = TRUE)
}

# fixest::etable() returns a data frame whose first column holds the row labels
# and whose separator rows are made of dashes or underscores; drop those rows.
etable_to_md <- function(tab, path) {
  names(tab)[1] <- " "
  names(tab) <- sub("^model (\\d+)$", "(\\1)", names(tab))
  is_rule <- apply(tab, 1, function(r) all(grepl("^[-_ ]*$", r)))
  tab <- tab[!is_rule & tab[[1]] != "Dependent Var.:", , drop = FALSE]
  tab[] <- lapply(tab, function(x) sub("^-+$", "", x))
  tab[[1]] <- sub(":$", "", tab[[1]])
  write_md_table(tab, path)
}
