# run_all.R
# Runs the whole thing from the repository root, in order.
#
# The four raw files go in data/raw, or SCE_DATA_DIR points at them; see
# data/README.md. Everything under data/derived and output is rebuilt.

source("code/01_build_sample.R")
source("code/02_analysis_sample.R")
source("code/03_descriptives.R")
source("code/04_regressions.R")
source("code/05_mechanism.R")
source("code/06_credit_constraints.R")
source("code/07_information.R")
