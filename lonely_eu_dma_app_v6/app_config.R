app_config <- list(
  contact_name = "Dr. Yixin Tang",
  contact_email = "yixin.tang@rub.de",
  osf_url = NA_character_,
  wp3_url = "https://lonelinessineurope.eu/eu-loneliness-explorer",
  grant_number = "101177225",
  project_name = "LONELY-EU",
  work_package = "Work Package 4"
)

make_mailto <- function(subject, body) {
  paste0(
    "mailto:", app_config$contact_email,
    "?subject=", utils::URLencode(subject, reserved = TRUE),
    "&body=", utils::URLencode(body, reserved = TRUE)
  )
}

app_config$report_error_mailto <- make_mailto(
  "LONELY-EU Evidence Explorer - Report an error",
  paste(
    "Page or section:",
    "Study or indicator:",
    "What appears incorrect:",
    "Suggested correction:",
    "Supporting source or link:",
    sep = "\n\n"
  )
)

app_config$suggest_study_mailto <- make_mailto(
  "LONELY-EU Evidence Explorer - Suggest a study",
  paste(
    "Study title:",
    "Authors:",
    "Publication year:",
    "DOI or URL:",
    "Why it may be eligible:",
    "Additional comments:",
    sep = "\n\n"
  )
)
