# easyPSID

## Overview

[CRAN package](https://CRAN.R-project.org/package=easyPSID) designed to simplify the task of reading the Panel Study of Income Dynamics (PSID) into R and preparing the data for analysis. Although the PSID is one of the most comprehensive longitudinal datasets for examining health and life course patterns among American families, preparing the PSID for analysis can be a difficult task. The PSID comes with no scripts for being read into R, and every wave of each PSID longitudinal variable has a unique name. For example, variables in the 1968 PSID Family File are named `V1-V440` whereas variables within the 1969 PSID Family File are named `V441-V1017`, even though most variables in the 1969 Family Files match those in the 1968 Family File. These aspects of the PSID pose difficulties for R users who want to conduct longitudinal analyses in the PSID. easyPSID simplifies these tasks and several others.

## Example

After downloading multiple waves of the PSID Packaged Data Family Files from https://simba.isr.umich.edu/, a common use of easyPSID is to unzip each wave of the family files, convert them to .rds format, rename all longitudinal variables to consistent names across years, and save the resulting renamed datasets to .rds format. The development version's cross-year reference currently covers the 1968-2023 waves. This can be done as follows (assuming the PSID files were saved into `C:/PSID/Zip Files`):

    library(easyPSID)
    unzip_all_files(
        in_direc="C:/PSID/Zip Files",
        out_direc="C:/PSID/Unzipped Files"
    )
    convert_to_rds(
        in_direc="C:/PSID/Unzipped Files",
        out_direc="C:/PSID/rds Files"
    )
    rename_fam_vars(
        in_direc="C:/PSID/rds Files",
        out_direc="C:/PSID/renamed Files"
    )

`convert_to_rds()` expects the fixed-width ASCII `.txt` file and matching Stata
`.do` definition file included in each PSID packaged-data ZIP. It does not read
Stata `.dta` files. If you already have a `.dta` file, import it with a Stata
reader such as `haven::read_dta()`, preserve the original PSID variable names,
and save the resulting data frame with `saveRDS()` before calling a renaming
function.

## Installation

This package can be directly installed via CRAN with `install.packages("easyPSID")`. Alternatively, newest versions of this package can be installed with `devtools::install_github("BrianAronson/easyPSID")`

Prior to working with the easyPSID package, users will need to download packaged PSID data for the family files and cross-sectional individual file from https://simba.isr.umich.edu/.

The small files bundled under `inst/extdata` are excerpts used to exercise the
package examples. Users must register with PSID and acquire full public-release
data directly from PSID.

## Function Overview

Below is a brief outline of each function in this package:

- **unzip\_all\_files**
    - Unzips all files in the supplied directory.
- **convert\_to\_rds**
    - Read PSID fixed width files into R and saves output in .rds format.
- **rename\_fam\_vars**
    - Renames all variables in longitudinal family files to their names when they were first available in the dataset.
- **rename\_ind\_vars**
    - Reshapes the cross-year Individual File to long format and gives recurring variables their earliest names while retaining `ER30001` and `ER30002` as stable person identifiers.
- **create\_custom\_panel**
    - Creates a longitudinal dataset with provided family files consisting of a custom set of  variables selected by the user.
- **create\_extract**
    - Creates a longitudinal dataset with provided family files consisting of the dataset's N most commonly reoccurring variables.
- **convert\_from\_rdata**
    - Converts PSID .rds files to files compatible with STAT, SAS, or SPSS.
- **find\_name**
    - Returns the new name (via the rename\_fam\_vars and rename\_ind\_vars functions) of a specified variable.
- **find\_years**
    - Returns each year that a given variable is available in the PSID, and its names during those years.
- **find\_description**
    - Returns the description of a given variable in the PSID with the variable labels provided by the PSID.
