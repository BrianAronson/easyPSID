index_url <- "https://psidonline.isr.umich.edu/help/xyr/psid.xlsx"
index_file <- Sys.getenv("EASYPSID_INDEX_PATH", unset = "")
description_seed_file <- Sys.getenv(
    "EASYPSID_DESCRIPTION_SEED",
    unset = file.path("R", "sysdata.rda")
)

if (!requireNamespace("readxl", quietly = TRUE)) {
    stop("Install the `readxl` package before rebuilding the reference data.")
}

if (!nzchar(index_file)) {
    index_file <- tempfile(fileext = ".xlsx")
    download_result <- try(
        download.file(index_url, index_file, mode = "wb", quiet = FALSE),
        silent = TRUE
    )
    if (inherits(download_result, "try-error")) {
        stop(
            paste0(
                "The PSID site blocked the automatic workbook download. Download ",
                index_url, " in a browser and set EASYPSID_INDEX_PATH to that file."
            ),
            call. = FALSE
        )
    }
}

if (!file.exists(index_file)) {
    stop("The file named by EASYPSID_INDEX_PATH does not exist.", call. = FALSE)
}

index <- readxl::read_excel(
    index_file,
    sheet = "MATRIX",
    col_types = "text",
    .name_repair = "minimal"
)
index <- as.data.frame(index, stringsAsFactors = FALSE)

year_columns <- grep("^Y[0-9]{4}$", names(index), value = TRUE)
required_columns <- c("TYPE", "TEXT", "Y1968", "Y2023")
missing_columns <- setdiff(required_columns, names(index))
if (length(missing_columns) > 0L) {
    stop(
        "The PSID workbook is missing expected columns: ",
        paste(missing_columns, collapse = ", "),
        call. = FALSE
    )
}

as_reference_table <- function(rows) {
    reference <- index[rows, year_columns, drop = FALSE]
    reference[] <- lapply(reference, function(column) {
        column[is.na(column)] <- ""
        as.character(column)
    })
    row.names(reference) <- NULL
    reference
}

psid_ind <- as_reference_table(index$TYPE == "INDIVIDUAL")
psid_fam <- as_reference_table(index$TYPE == "FAMILY PUBLIC")

repeat_stable_identifier <- function(reference, variable) {
    matches <- which(reference == variable, arr.ind = TRUE)
    matching_rows <- unique(matches[, "row"])
    if (length(matching_rows) != 1L) {
        stop(
            "Expected exactly one cross-year index row for `",
            variable,
            "`.",
            call. = FALSE
        )
    }
    reference[matching_rows, ] <- variable
    reference
}

psid_all <- rbind(psid_ind, psid_fam)
row.names(psid_all) <- NULL

# These two values identify a person, not a wave-specific observation. Repeating
# them in the individual reshape index lets rename_ind_vars preserve the
# identifiers on every long-format row. psid_all retains the source-faithful
# single occurrence used by find_years().
psid_ind <- repeat_stable_identifier(psid_ind, "ER30001")
psid_ind <- repeat_stable_identifier(psid_ind, "ER30002")

duplicate_counts <- vapply(psid_all, function(column) {
    values <- column[nzchar(column)]
    sum(duplicated(values))
}, integer(1))
if (any(duplicate_counts > 0L)) {
    stop(
        "The PSID workbook contains duplicate variable names within: ",
        paste(names(duplicate_counts)[duplicate_counts > 0L], collapse = ", "),
        call. = FALSE
    )
}

index_description <- function(text) {
    if (is.na(text) || !nzchar(text)) {
        return(NA_character_)
    }
    parts <- strsplit(text, "\n", fixed = TRUE)[[1L]]
    parts <- trimws(sub("^[0-9]+>", "", parts))
    paste(parts[nzchar(parts)], collapse = " > ")
}

descriptions <- lapply(seq_len(nrow(index)), function(row_index) {
    if (!index$TYPE[row_index] %in% c("INDIVIDUAL", "FAMILY PUBLIC")) {
        return(NULL)
    }
    variables <- unlist(index[row_index, year_columns, drop = FALSE], use.names = FALSE)
    variables <- unique(variables[!is.na(variables) & nzchar(variables)])
    if (length(variables) == 0L) {
        return(NULL)
    }
    data.frame(
        Variable = variables,
        Description = index_description(index$TEXT[row_index]),
        stringsAsFactors = FALSE
    )
})
index_descriptions <- do.call(rbind, descriptions)
index_descriptions <- index_descriptions[
    !duplicated(index_descriptions$Variable),
    ,
    drop = FALSE
]
row.names(index_descriptions) <- NULL

psid_desc <- index_descriptions
if (file.exists(description_seed_file)) {
    seed <- new.env(parent = emptyenv())
    load(description_seed_file, envir = seed)
    if (exists("data", envir = seed, inherits = FALSE) &&
        is.data.frame(seed$data$psid_desc)) {
        psid_desc <- data.frame(
            Variable = as.character(seed$data$psid_desc$Variable),
            Description = as.character(seed$data$psid_desc$Description),
            stringsAsFactors = FALSE
        )
        new_descriptions <- index_descriptions[
            !index_descriptions$Variable %in% psid_desc$Variable,
            ,
            drop = FALSE
        ]
        psid_desc <- rbind(psid_desc, new_descriptions)
        row.names(psid_desc) <- NULL
    }
}

data <- list(
    psid_all = psid_all,
    psid_desc = psid_desc,
    psid_fam = psid_fam,
    psid_ind = psid_ind
)

save(data, file = file.path("R", "sysdata.rda"), compress = "xz", version = 2)
message(
    "Saved PSID reference data through ",
    sub("^Y", "", tail(year_columns, 1L)),
    "."
)
