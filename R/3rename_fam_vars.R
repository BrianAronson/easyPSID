#' Rename longitudinal Family File variables
#' @description Renames all longitudinal variables in every PSID Family File of a given directory, such that variables are labeled with the variable name used when the variable was first made available in the PSID. For example, the "Release Number" variable was first recorded in the PSID dataset in 1968 as variable "V1" but its name in the 1969 family file is "V441". This program changes the "Release Number" variable name to "V1" in 1968 and all subsequent waves.
#' @param in_direc Directory of PSID .rds files to rename
#' @param out_direc Directory for renamed PSID .rds files to be saves to. Warning: If no directory specified, this function will overwrite the Family Files in the current directory.
#' @keywords PSID
#' @export
#' @examples
#' rename_fam_vars(
#'     in_direc=system.file("extdata","rds_dir", package = "easyPSID"),
#'     out_direc=tempdir()
#' )

rename_fam_vars <- function(in_direc, out_direc) {
    file_names <- list.files(
        path = in_direc,
        pattern = "^FAM.*\\.rds$",
        full.names = TRUE
    )
    if (length(file_names) == 0L) {
        stop("No Family File .rds files were found in `in_direc`.", call. = FALSE)
    }

    dir.create(out_direc, recursive = TRUE, showWarnings = FALSE)
    supported_years <- sub("^Y", "", names(data$psid_all))

    for (file_name in file_names) {
        short_name <- basename(file_name)
        file_year <- gsub("\\D+", "", short_name)
        year_column <- match(file_year, supported_years)
        if (is.na(year_column)) {
            stop(
                paste0(
                    "The year in `", short_name, "` is not present in the internal ",
                    "PSID index. Supported years are ",
                    paste(supported_years, collapse = ", "), "."
                ),
                call. = FALSE
            )
        }

        family_data <- readRDS(file_name)
        renamed_variables <- names(family_data)

        for (variable_index in seq_along(renamed_variables)) {
            matching_rows <- which(
                data$psid_all[[year_column]] == renamed_variables[variable_index]
            )
            if (length(matching_rows) == 0L) {
                next
            }

            names_by_year <- unlist(
                data$psid_all[matching_rows[1L], , drop = FALSE],
                use.names = FALSE
            )
            names_by_year <- names_by_year[!is.na(names_by_year) & nzchar(names_by_year)]
            renamed_variables[variable_index] <- names_by_year[1L]
        }

        names(family_data) <- renamed_variables
        saveRDS(family_data, file = file.path(out_direc, short_name))
        message(short_name, " renamed")
    }
}
