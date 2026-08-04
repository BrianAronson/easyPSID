test_that("conversion pairs data with its import script and ignores format scripts", {
    input_directory <- file.path(tempdir(), "easypsid-convert-input")
    output_directory <- file.path(tempdir(), "easypsid-convert-output")
    dir.create(input_directory, recursive = TRUE, showWarnings = FALSE)
    dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)

    writeLines(
        c(
            "infix",
            "    ER82001 1 - 1    long ER82002 2 - 6",
            "using FAM2023ER.txt",
            "label variable ER82001 \"Release number\"",
            "label variable ER82002 \"Family interview number\""
        ),
        file.path(input_directory, "FAM2023ER.do")
    )
    writeLines(
        "label define ER82001L 1 \"Release one\"",
        file.path(input_directory, "FAM2023ER_formats.do")
    )
    writeLines(c("100001", "200002"), file.path(input_directory, "FAM2023ER.txt"))

    convert_to_rds(input_directory, output_directory)
    converted_data <- readRDS(file.path(output_directory, "FAM2023.rds"))

    expect_equal(names(converted_data), c("ER82001", "ER82002"))
    expect_equal(nrow(converted_data), 2L)
    expect_equal(
        attr(converted_data, "var.labels"),
        c("Release number", "Family interview number")
    )
})

test_that("conversion reports a missing matching import script", {
    input_directory <- file.path(tempdir(), "easypsid-missing-do-input")
    output_directory <- file.path(tempdir(), "easypsid-missing-do-output")
    dir.create(input_directory, recursive = TRUE, showWarnings = FALSE)
    writeLines("100001", file.path(input_directory, "FAM2023ER.txt"))

    expect_error(
        convert_to_rds(input_directory, output_directory),
        "matching .do file"
    )
})
