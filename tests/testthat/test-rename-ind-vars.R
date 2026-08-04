test_that("individual reshaping preserves stable person identifiers", {
    reference_data <- get("data", envir = asNamespace("easyPSID"))
    relationship_row <- which(
        reference_data$psid_ind == "ER30003",
        arr.ind = TRUE
    )[1L, "row"]
    response_variables <- unique(unlist(
        reference_data$psid_ind[relationship_row, , drop = FALSE],
        use.names = FALSE
    ))
    response_variables <- response_variables[nzchar(response_variables)]

    individual_data <- as.data.frame(
        setNames(rep(list(1), length(response_variables)), response_variables),
        check.names = FALSE
    )
    individual_data$ER30001 <- 123
    individual_data$ER30002 <- 4

    input_directory <- file.path(tempdir(), "easypsid-individual-input")
    output_directory <- file.path(tempdir(), "easypsid-individual-output")
    dir.create(input_directory, recursive = TRUE, showWarnings = FALSE)
    saveRDS(individual_data, file.path(input_directory, "IND2023.rds"))

    expect_message(
        rename_ind_vars(
            in_direc = input_directory,
            out_direc = output_directory,
            cust_vars = "ER30002"
        ),
        "100%"
    )

    reshaped <- readRDS(file.path(
        output_directory,
        "IND2023 - Long Format.rds"
    ))
    expect_true(all(reshaped$ER30001 == 123))
    expect_true(all(reshaped$ER30002 == 4))
    expect_equal(reshaped$fam_id_68, reshaped$ER30001)
})
