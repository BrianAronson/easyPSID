# easyPSID 0.1.3

- Updated the internal PSID cross-year index from the official workbook through
  the 2023 wave.
- Fixed `find_name()` and `find_years()` for variables that occur in only one
  wave, including `ER30002`.
- Preserved `ER30001` and `ER30002` across waves when reshaping the cross-year
  individual file.
- Added tests for current-wave lookups, stable individual identifiers, and
  family-file renaming.
- Clarified that `convert_to_rds()` expects the ASCII `.txt` and Stata `.do`
  files distributed in PSID packaged-data downloads, not Stata `.dta` files.
- Updated `convert_to_rds()` for current packaged downloads by pairing every
  data file with its identically named import script and ignoring the separate
  `_formats.do` value-label scripts.
# easyPSID 0.1.2

- Added support for 2019 Family Files and the 2019 cross-year Individual File.

# easyPSID 0.1.1

- Added support for 2017 Family and Individual Files.
- Lost support for the 2015 Individual File.
