test_that("family variables are renamed through the 2023 index", {
    input_directory <- file.path(tempdir(), "easypsid-family-input")
    output_directory <- file.path(tempdir(), "easypsid-family-output")
    dir.create(input_directory, recursive = TRUE, showWarnings = FALSE)

    family_data <- data.frame(
        ER78001 = 1,
        ER78002 = 100,
        project_specific = 3
    )
    saveRDS(family_data, file.path(input_directory, "FAM2021.rds"))

    expect_message(
        rename_fam_vars(input_directory, output_directory),
        "FAM2021.rds renamed"
    )
    renamed <- readRDS(file.path(output_directory, "FAM2021.rds"))

    expect_equal(names(renamed), c("V21601", "V3", "project_specific"))
})

test_that("family renaming reports missing and unsupported inputs", {
    empty_directory <- file.path(tempdir(), "easypsid-empty-family-input")
    dir.create(empty_directory, recursive = TRUE, showWarnings = FALSE)

    expect_error(
        rename_fam_vars(empty_directory, tempdir()),
        "No Family File"
    )

    future_directory <- file.path(tempdir(), "easypsid-future-family-input")
    dir.create(future_directory, recursive = TRUE, showWarnings = FALSE)
    saveRDS(data.frame(ER86001 = 1), file.path(future_directory, "FAM2025.rds"))

    expect_error(
        rename_fam_vars(future_directory, tempdir()),
        "not present in the internal PSID index"
    )
})
