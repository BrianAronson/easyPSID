test_that("the internal public index reaches the 2023 wave", {
    reference_data <- get("data", envir = asNamespace("easyPSID"))

    expect_equal(tail(names(reference_data$psid_all), 3L), c("Y2019", "Y2021", "Y2023"))
    expect_true("ER78001" %in% reference_data$psid_all$Y2021)
    expect_true("ER82001" %in% reference_data$psid_all$Y2023)
})

test_that("stable person identifiers are retained in every wave", {
    reference_data <- get("data", envir = asNamespace("easyPSID"))

    for (variable in c("ER30001", "ER30002")) {
        identifier_row <- which(
            reference_data$psid_ind == variable,
            arr.ind = TRUE
        )[1L, "row"]
        expect_true(all(reference_data$psid_ind[identifier_row, ] == variable))
    }
})

test_that("new variables have descriptions", {
    description <- find_description("ER82001")

    expect_equal(description$Variable, "ER82001")
    expect_false(is.na(description$Description))
    expect_true(nzchar(description$Description))
})
