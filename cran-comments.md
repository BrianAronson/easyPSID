## Test environments

* local Windows 11, R 4.3.1 (preliminary check)
* win-builder, R-release 4.6.0 (pending)
* win-builder, R-devel 4.7.0 (pending)

## R CMD check results

The preliminary local check completed with 0 errors, 1 warning, and 2 notes.
The warning and notes were caused by the local toolchain: `LaF` was built under
R 4.3.3 while the check used R 4.3.1, the system time could not be verified,
and `tidy` was unavailable for optional HTML validation.

This section will be replaced with the current R-release and R-devel results
before submission.

## Changes in this version

This release updates the internal PSID cross-year index through the 2023 wave,
supports the current packaged-download file layout, preserves stable individual
identifiers during long reshaping, and fixes lookups for variables occurring in
only one wave. It also adds tests covering those behaviors.

## Downstream dependencies

There are currently no downstream dependencies for this package
