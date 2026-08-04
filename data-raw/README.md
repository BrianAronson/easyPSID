# Internal PSID reference data

`R/sysdata.rda` is derived from the official PSID cross-year index workbook:

<https://psidonline.isr.umich.edu/help/xyr/psid.xlsx>

From the package root, rebuild it with:

```r
Sys.setenv(EASYPSID_INDEX_PATH = "path/to/psid.xlsx")
source("data-raw/build_reference_data.R")
```

The script attempts a direct download when `EASYPSID_INDEX_PATH` is unset. The
PSID site's connection-security check may reject unattended downloads; in that
case, download the linked workbook in a browser and provide its local path.

The old package did not retain a reproducible source for its short variable
labels. During a normal refresh, the script keeps existing labels and adds
previously unseen variables using the official index's hierarchical text. Set
`EASYPSID_DESCRIPTION_SEED` to another released `sysdata.rda` file when the
working copy should not be used as that seed.

`FAMILY RESTRICTED` rows are intentionally excluded. `ER30001` and `ER30002`
are repeated across the individual reference table because they jointly identify
a person across waves and must survive the long-format reshape.
