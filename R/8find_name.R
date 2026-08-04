#' Lookup new longitudinal variables names
#' @description Finds the new name of any longitudinal variable in the PSID Family Files or Individual files following implementation of the rename_fam_vars and rename_ind_vars functions.
#' @param variable Variable to look up
#' @param var_year Report year when renamed variable first entered the PSID dataset (default=TRUE)
#' @keywords PSID
#' @export
#' @examples find_name(variable="V1244",var_year=FALSE)


find_name <- function(variable, var_year = TRUE) {
    variable <- as.character(variable)
    years <- .find_reference_years(variable)

    if (is.null(years)) {
        return(variable)
    }
    if (isTRUE(var_year)) {
        return(years[1L, , drop = FALSE])
    }
    years$Name[1L]
}
