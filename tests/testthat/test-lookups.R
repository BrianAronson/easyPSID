test_that("current family variables resolve across waves", {
    release_numbers <- find_years("ER78001")

    expect_equal(tail(release_numbers$Year, 3L), c(2019, 2021, 2023))
    expect_equal(
        tail(release_numbers$Name, 3L),
        c("ER72001", "ER78001", "ER82001")
    )
    expect_equal(find_name("ER82001", var_year = FALSE), "V21601")
})

test_that("single-wave variables do not cause lookup errors", {
    person_number <- find_years("ER30002")

    expect_equal(person_number$Year, 1968)
    expect_equal(person_number$Name, "ER30002")
    expect_equal(find_name("ER30002", var_year = FALSE), "ER30002")
})

test_that("unknown variables retain their original names", {
    expect_equal(find_years("NOT_A_PSID_VARIABLE"), "NOT_A_PSID_VARIABLE")
    expect_equal(find_name("NOT_A_PSID_VARIABLE"), "NOT_A_PSID_VARIABLE")
})

test_that("lookup functions reject multiple variables", {
    expect_error(
        find_years(c("ER78001", "ER82001")),
        "exactly one PSID variable"
    )
})
