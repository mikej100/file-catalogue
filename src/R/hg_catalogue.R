library(openxlsx2)
library(dplyr)
library(purrr)
library(readr)
library(stringr)

# example find command to generate file analysed by the script. 
# $ find  /project/higgslab -type f,l -iregex '.*fastq.*' -fprintf higgs_fastq3 '%T+\t%p\t%l\t%s\t%y\n' 

workspace_dir <- 'workspace/prod'
input_file <- file.path(workspace_dir, "raw_output",  'mjenning_fastq')
output_dir <- file.path(workspace_dir, "excel")
excel_file <- file.path(output_dir, "all_filetypes.xlsx")
dir.create(output_dir, showWarnings = FALSE)


#1 err_raw <- read_tsv(
#1     '../higgs_fast_err',
#1     col_names = "message"
#1     )
#1 err <- err_raw |>
#1     mutate(error = str_extract(message, '[^:]+$')) |>
#1     mutate(owner = str_extract(message, '(?<=higgslab/)[^/]+')) |>
#1     relocate(message, .after = last_col() )
#1     # distinct(error, owner, .keep_all=TRUE)


file_types <- list(
    fastq = list(
        raw_filename = "fastq.txt",
        endings = c(
            ".fastq",
            ".fastq.gz",
            ".fq",
            ".fq.gz"
        )
    ),
    bam = list(
        raw_filename = "bam_details.txt",
        endings = c(
            ".bam",
            ".bam.bai"
        )
    ),
    sam = list(
        raw_filename = "sam_details.txt",
        endings = c(
            ".sam",
            ".sam.bai"
        )
    ),
    bw_bed = list(
        raw_filename = "bw_bed_details.txt",
        endings = c(
            ".bw",
            ".bed"
        )
    )
)


file_type_names <- names(file_types)

# Just run for selected file types
# for testing< sleect just the naes fastq and bam from filetype names

file_type_names  = c("fastq", "bam")




# Create regex pattern for the allowed endings
# a bit messy to escape.

file_type <- file_type_names[2]
process_file_type <- function(file_type) {
    input_file <- file.path(workspace_dir, "raw_output", file_types[[file_type]]$raw_filename)
    find_raw <- read_tsv(
        input_file,
        col_names = c("modified", "fpath", "symlink", "bytes", "type"),
        col_types = "cccdc",
        show_col_types = FALSE
        )

    endings <- file_types[[file_type]]$endings
    regex_pattern <- endings |>
        map(\(e) str_replace_all(e, '\\.', '\\\\\\.')) |>
        map(\(e) str_glue(e, "$") ) |>
        reduce(\(a,x) str_glue(a, x, .sep='|'))

    type_files <- find_raw |>
        filter( str_detect(fpath, regex_pattern)) |>
        distinct(fpath, .keep_all = TRUE) |>
        mutate(owner = str_extract(fpath, '(?<=higgslab/)[^/]+')) |>
        mutate(GB = bytes / 1024^3) |>
        select(!c(bytes)) |>
        mutate(file_type = file_type )  |>
        relocate(owner, .before = fpath) 

    return(type_files)
}

# Combine all file type dataframes by processing each type and binding rows
types_files <- file_type_names |>
    map(process_file_type) |>
    reduce(bind_rows, .init = tibble())


wb <- wb_workbook()
wb$add_worksheet("file_list")
# wb$add_worksheet("find errors")

wb$add_data(sheet=1, types_files)
wb$add_data(sheet=2, err)

wb_save(wb, file=excel_file, overwrite=TRUE)
