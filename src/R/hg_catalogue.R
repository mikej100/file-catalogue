library(openxlsx2)
library(dplyr)
library(purrr)
library(readr)
library(stringr)

# example find command to generate file analysed by the script. 
# $ find  /project/higgslab -type f,l -iregex '.*fastq.*' -fprintf higgs_fastq3 '%T+\t%p\t%l\t%s\t%y\n' 

find_raw <- read_tsv(
    '../higgs_fastq3',
    col_names = c("modified", "fpath", "symlink", "bytes", "type")
    )
err_raw <- read_tsv(
    '../higgs_fast_err',
    col_names = "message"
    )
err <- err_raw |>
    mutate(error = str_extract(message, '[^:]+$')) |>
    mutate(owner = str_extract(message, '(?<=higgslab/)[^/]+')) |>
    relocate(message, .after = last_col() )
    # distinct(error, owner, .keep_all=TRUE)


allowed_endings <- c(
    ".fastq",
    ".fastq.gz",
    ".fq",
    ".fq.gz"
)
# Create regex pattern for the allowed endings
# a bit messy to escape.
regex_pattern <- allowed_endings |>
    map(\(e) str_replace_all(e, '\\.', '\\\\\\.')) |>
    map(\(e) str_glue(e, "$") ) |>
    reduce(\(a,x) str_glue(a, x, .sep='|'))
regex_pattern

fq_files <- find_raw |>
    filter( str_detect(fpath, regex_pattern)) |>
    distinct(fpath, .keep_all = TRUE) |>
    mutate(owner = str_extract(fpath, '(?<=higgslab/)[^/]+')) |>
    mutate(MB = bytes / 1024^2) |>
    select(!c(bytes)) |>
    relocate(owner, .before = fpath) 

wb <- wb_workbook()
wb$add_worksheet("fastq files")
wb$add_worksheet("find errors")

wb$add_data(sheet=1, fq_files)
wb$add_data(sheet=2, err)

wb_save(wb, file="fastq_files.xlsx", overwrite=TRUE)
