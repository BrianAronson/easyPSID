#' Find years of PSID variable
#' @description Finds the years and corresponding variable names for any longitudinal PSID variable in the PSID Family Files and Individual file.
#' @param variable Variable name to look up
#' @param var_names Report names for longitudinal PSID variable across years (default=TRUE)
#' @keywords PSID
#' @export
#' @examples find_years(variable="V3",var_names=FALSE)


find_years <- function(variable, var_names = TRUE) {
    variable <- as.character(variable)
    years <- .find_reference_years(variable)

    if (is.null(years)) {
        return(variable)
    }
    if (isTRUE(var_names)) {
        return(years)
    }
    years$Year
}
