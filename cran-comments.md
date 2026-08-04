## Test environments

* win-builder, R-release 4.6.1
* win-builder, R-devel (2026-08-03 r90347)

## R CMD check results

There were no ERRORs, WARNINGs, or NOTEs.

## Changes in this version

This release updates the internal PSID cross-year index through the 2023 wave,
supports the current packaged-download file layout, preserves stable individual
identifiers during long reshaping, and fixes lookups for variables occurring in
only one wave. It also adds tests covering those behaviors.

## Downstream dependencies

There are currently no downstream dependencies for this package
