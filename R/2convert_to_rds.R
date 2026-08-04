#' Convert all PSID files from .txt format to .rds format
#' @description Converts all PSID fixed width format .txt files in a selected directory into .rds format. This function expects the ASCII .txt file and matching Stata .do definition file contained in each PSID packaged-data .zip download. It does not read Stata .dta files. All files must retain the names they had when first unzipped.
#' @param in_direc Directory containing unzipped PSID .txt and .do files
#' @param out_direc Directory to place PSID .rds files into
#' @keywords PSID
#' @export
#' @importFrom stringr str_extract str_match str_match_all
#' @importFrom LaF laf_open_fwf
#' @examples
#' convert_to_rds(
#'     in_direc=system.file("extdata","unzip_dir", package = "easyPSID"),
#'     out_direc=tempdir()
#' )

convert_to_rds <- function(in_direc, out_direc) {
    txt_files <- list.files(
        path = in_direc,
        pattern = "\\.txt$",
        full.names = TRUE,
        ignore.case = TRUE
    )
    if (length(txt_files) == 0L) {
        stop("No fixed-width .txt files were found in `in_direc`.", call. = FALSE)
    }

    do_files <- list.files(
        path = in_direc,
        pattern = "\\.do$",
        full.names = TRUE,
        ignore.case = TRUE
    )
    do_stems <- tolower(tools::file_path_sans_ext(basename(do_files)))
    dir.create(out_direc, recursive = TRUE, showWarnings = FALSE)

    for (txt_file in txt_files) {
        txt_name <- basename(txt_file)
        txt_stem <- tools::file_path_sans_ext(txt_name)
        matching_do_files <- do_files[do_stems == tolower(txt_stem)]
        if (length(matching_do_files) != 1L) {
            stop(
                paste0(
                    "Expected exactly one matching .do file for `", txt_name,
                    "`, but found ", length(matching_do_files), "."
                ),
                call. = FALSE
            )
        }

        stata_code <- readLines(matching_do_files, warn = FALSE)
        infix_line <- grep("^\\s*infix\\b", stata_code, ignore.case = TRUE)[1L]
        using_lines <- grep("^\\s*using\\b", stata_code, ignore.case = TRUE)
        using_line <- using_lines[using_lines > infix_line][1L]
        if (is.na(infix_line) || is.na(using_line)) {
            stop(
                paste0("Could not locate the infix definition in `", basename(matching_do_files), "`."),
                call. = FALSE
            )
        }

        infix_code <- paste(stata_code[(infix_line + 1L):(using_line - 1L)], collapse = " ")
        field_pattern <- paste0(
            "(?:\\b(?:byte|int|long|float|double|str[0-9]+)\\s+)?",
            "([A-Za-z][A-Za-z0-9_]*)\\s+([0-9]+)\\s*-\\s*([0-9]+)"
        )
        fields <- str_match_all(infix_code, field_pattern)[[1L]]
        if (nrow(fields) == 0L) {
            stop(
                paste0("No fixed-width fields were found in `", basename(matching_do_files), "`."),
                call. = FALSE
            )
        }

        variable_names <- fields[, 2L]
        columns <- as.integer(fields[, 4L]) - as.integer(fields[, 3L]) + 1L

        label_pattern <- paste0(
            "^\\s*label\\s+variable\\s+([A-Za-z][A-Za-z0-9_]*)\\s+",
            "\"(.*)\"\\s*;?\\s*$"
        )
        label_fields <- str_match(stata_code, label_pattern)
        label_fields <- label_fields[!is.na(label_fields[, 2L]), , drop = FALSE]
        labels_by_name <- stats::setNames(
            trimws(label_fields[, 3L]),
            label_fields[, 2L]
        )
        variable_labels <- unname(labels_by_name[variable_names])

        converted_data <- laf_open_fwf(
            txt_file,
            column_widths = columns,
            column_types = rep("double", length(columns))
        )
        converted_data <- converted_data[, ]
        names(converted_data) <- variable_names
        attr(converted_data, "var.labels") <- variable_labels

        file_year <- str_extract(txt_name, "[0-9]+")
        file_type <- toupper(substr(txt_name, 1L, 3L))
        output_name <- paste0(file_type, file_year, ".rds")
        saveRDS(converted_data, file = file.path(out_direc, output_name))
        message(output_name, " converted")
    }
}

