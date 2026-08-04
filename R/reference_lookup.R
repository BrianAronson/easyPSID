.find_reference_years <- function(variable) {
    variable <- as.character(variable)
    if (length(variable) != 1L) {
        stop("`variable` must contain exactly one PSID variable name.", call. = FALSE)
    }

    matches <- which(data$psid_all == variable, arr.ind = TRUE)
    if (nrow(matches) == 0L) {
        return(NULL)
    }

    reference_row <- data$psid_all[matches[1L, "row"], , drop = FALSE]
    names_by_year <- unlist(reference_row, use.names = TRUE)
    names_by_year <- names_by_year[!is.na(names_by_year) & nzchar(names_by_year)]

    data.frame(
        Year = as.integer(sub("^Y", "", names(names_by_year))),
        Name = unname(names_by_year),
        stringsAsFactors = FALSE,
        row.names = NULL
    )
}
