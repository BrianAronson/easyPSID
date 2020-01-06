# easyPSID README.md

## Overview

The easyPSID package is designed to simplify the task of reading the Panel Study of Income Dynamics (PSID) into R and preparing the data for analysis. 

Although the PSID is one of the most comprehensive longitudinal datasets for examining health and life course patterns among American families, preparing the PSID for analysis can be a difficult task. The PSID comes with no scripts for being read into R, and every wave of each PSID longitudinal variable has a unique name. For example, variables in the 1968 PSID Family File are named “V1” through “V440” whereas variables within the 1969 PSID Family File are named “V441” through “V1017,” even though the 1969 Family File variables match those in the 1968 Family File. These aspects of the PSID can pose difficulties for R users who want to conduct longitudinal analyses in the PSID. Fortunately, the easyPSID package is designed to make working with the PSID as easy as possible.

## Example

After users have downloaded several waves of the PSID Packaged Data Family Files from https://simba.isr.umich.edu/, a common first use of the easyPSID package is to unzip each wave of the family files, convert them to .rds format, rename all longitudinal variables to consistent names across years, and save these resulting renamed datasets to .rds format with the following code (after amending for directory names). For example:

    library(easyPSID)
    unzip_all_files(
        in_direc="C:/PSID/Zip Files",
        out_direc="C:/PSID/Unzipped Files",
    )
    convert_to_rds(
        in_direc="C:/PSID/Unzipped Files",
        out_direc="C:/PSID/rds Files",
    )
    rename_fam_vars(
        in_direc="C:/PSID/rds Files",
        out_direc="C:/PSID/renamed Files",
    )

## Installation

This package can be directly installed via CRAN with:

    install.packages("easyPSID")
    
Alternatively, newest versions of this package can be installed with:

    devtools::install_github("BrianAronson/easyPSID")

However, prior to working with the easyPSID package, users will need to have already downloaded packaged PSID data for the years that they wish to work with from https://simba.isr.umich.edu/. PSID's packaged data can only be accessed by loading this URL and navigating through the following tabs: Data=> Packaged Data=> Main and Supplemental Studies. The current functions only work with the PSID's family files and cross-sectional individual file. For reference, once downloaded, the family files typically have a naming structure like "fam1968.zip", "fam1969.zip", etc. and the individual cross section will be named something like "ind2015er.zip".

##Function Overview

More detailed vignettes for this package are in development, but below is a brief outline of each function in this package:

- **unzip\_all\_files**: Unzips all files in the supplie directory.
- **convert\_to\_rds**: Read PSID fixed width files into R and saves output in .rds format.
- **rename\_fam\_vars**: Renames all variables in longitudinal family files to their names when they were first available in the dataset.
- **rename\_ind\_vars**: Renames all variables in longitudinal family files to their names when they were first available in the dataset.
- **create\_custom\_panel**: Creates a longitudinal dataset with provided family files consisting of a custom set of  variables selected by the user.
- **create\_extract**: Creates a longitudinal dataset with provided family files consisting of the dataset's N most commonly reoccurring variables.
- **convert\_from\_rdata**: Converts PSID .rds files to files compatible with STAT, SAS, or SPSS.
- **find\_name**: Returns the new name (via the rename\_fam\_vars and rename\_ind\_vars functions) of a specified variable.
- **find\_years**: Returns each year that a given variable is available in the PSID, and its names during those years.
- **find\_description**: Returns the description of a given variable in the PSID with the variable labels provided by the PSID.
