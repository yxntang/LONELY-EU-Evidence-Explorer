fluidPage(
  theme = shinythemes::shinytheme("flatly"),
  tags$head(
    tags$style(HTML("
      body {
        background: #f5f7f8;
        color: #24343b;
        font-size: 16px;
      }
      .container-fluid { max-width: 1500px; }
      .app-title {
        margin: 20px 0 16px;
        font-size: 30px;
        font-weight: 700;
      }
      .sidebar-section {
        border-top: 1px solid #d5dee2;
        padding-top: 16px;
        margin-top: 10px;
      }
      .sidebar-section h4 {
        margin: 0 0 10px;
        color: #244454;
        font-size: 16px;
        font-weight: 700;
      }
      .sidebar-note,
      .section-note {
        color: #53636b;
        line-height: 1.55;
      }
      .sidebar-note { margin-top: 14px; }
      .tab-content {
        background: #ffffff;
        border: 1px solid #d5dee2;
        border-top: 0;
        padding: 26px 28px 34px;
      }
      .nav-tabs > li > a { font-weight: 600; }
      .nav-tabs > li > a[data-value='loneliness'],
      .nav-tabs > li > a[data-value='associations'] {
        background: #e8f4f6;
        border-color: #b9d5dc;
        color: #1f5362;
        font-weight: 800;
      }
      .nav-tabs > li.active > a[data-value='loneliness'],
      .nav-tabs > li.active > a[data-value='associations'] {
        background: #ffffff;
        border-top: 4px solid #328294;
        color: #1f5362;
      }
      .sidebar-links {
        margin-top: 10px;
        padding-left: 18px;
      }
      .sidebar-links li { margin-bottom: 6px; }
      .sidebar-links a {
        color: #1f6d7d;
        font-weight: 700;
      }
      .intro-panel {
        background: #eef6f7;
        border-left: 4px solid #328294;
        padding: 22px 24px;
        margin-bottom: 36px;
      }
      .intro-panel h3 { margin-top: 0; }
      .intro-panel p {
        line-height: 1.6;
        margin-top: 14px;
      }
      .intro-panel p:last-child { margin-bottom: 0; }
      .section-heading {
        margin: 8px 0 6px;
        font-size: 27px;
        line-height: 1.25;
      }
      .section-lead {
        max-width: 920px;
        margin-bottom: 22px;
        color: #455861;
        line-height: 1.6;
      }
      .question-block {
        border-left: 3px solid #a8c7ce;
        padding: 4px 0 4px 18px;
        margin: 34px 0;
        max-width: 980px;
      }
      .question-block h3 { margin: 0 0 8px; }
      .steps-list {
        max-width: 900px;
        padding-left: 24px;
      }
      .steps-list li {
        margin-bottom: 13px;
        padding-left: 4px;
      }
      .metric-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(170px, 1fr));
        gap: 12px;
        margin: 20px 0 28px;
      }
      .metric-card {
        background: #ffffff;
        border: 1px solid #d5dee2;
        border-radius: 6px;
        padding: 15px 16px;
        min-height: 92px;
      }
      .metric-value {
        color: #234653;
        font-size: 25px;
        font-weight: 700;
        line-height: 1.15;
        overflow-wrap: anywhere;
      }
      .metric-label {
        color: #5b6a71;
        font-size: 13px;
        margin-top: 7px;
        line-height: 1.3;
      }
      .score-highlight {
        background: #eef6f7;
        border-left: 5px solid #328294;
        margin: 22px 0 26px;
        max-width: 620px;
        padding: 22px 26px;
      }
      .score-highlight-value {
        color: #1f5362;
        font-size: 52px;
        font-weight: 700;
        line-height: 1;
      }
      .score-highlight-label {
        color: #24343b;
        font-size: 19px;
        font-weight: 700;
        margin-top: 8px;
      }
      .score-highlight-note {
        color: #53636b;
        line-height: 1.45;
        margin: 12px 0 0;
      }
      .benchmark-grid {
        max-width: 820px;
      }
      .info-panel {
        background: #f3f7f8;
        border-left: 4px solid #6f9ca6;
        padding: 16px 18px;
        margin: 20px 0 30px;
        max-width: 1040px;
      }
      .plain-info {
        background: #f7fafb;
      }
      .info-panel p:last-child { margin-bottom: 0; }
      .sentence-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
        gap: 18px;
        margin: 32px 0 36px;
      }
      .sentence-card {
        background: #ffffff;
        border: 1px solid #d5dee2;
        border-radius: 6px;
        padding: 18px 20px;
      }
      .sentence-card h4 {
        color: #244454;
        margin: 0 0 8px;
      }
      .sentence-card p {
        color: #455861;
        line-height: 1.55;
        margin-bottom: 0;
      }
      .control-panel {
        background: #f7f9fa;
        border: 1px solid #d5dee2;
        border-radius: 6px;
        padding: 18px 20px 8px;
        margin: 14px 0 22px;
      }
      .control-panel .form-group { max-width: 520px; }
      .control-panel .radio-inline { margin-right: 14px; }
      .section-filter {
        border-bottom: 1px solid #d5dee2;
        margin: 4px 0 20px;
        max-width: 720px;
        padding: 4px 0 12px;
      }
      .section-filter .form-group { margin-bottom: 4px; }
      .figure-panel {
        border: 1px solid #d5dee2;
        border-radius: 6px;
        padding: 16px 16px 8px;
        margin: 18px 0 12px;
        overflow: hidden;
      }
      .figure-panel h4 {
        margin: 0 0 8px;
        font-size: 19px;
      }
      .figure-note {
        background: #f7f9fa;
        border-left: 3px solid #8caeb6;
        color: #455861;
        line-height: 1.55;
        margin: 12px 0 26px;
        padding: 12px 14px;
      }
      .summary-table-section { margin: 10px 0 34px; }
      .country-count-section {
        border-top: 1px solid #d5dee2;
        margin: 24px 0 34px;
        padding-top: 20px;
      }
      .data-section {
        border-top: 4px solid #328294;
        margin-top: 90px;
        padding-top: 34px;
      }
      .data-section h3 {
        color: #244454;
        font-size: 24px;
        margin-top: 0;
      }
      .dataTables_wrapper { font-size: 14px; }
      table.dataTable thead th { white-space: normal; }
      .dt-top-scroll {
        height: 18px;
        margin: 8px 0 6px;
        overflow-x: auto;
        overflow-y: hidden;
      }
      .dt-top-scroll-inner { height: 1px; }
      .dt-scroll-body-top-controlled { scrollbar-width: none; }
      .dt-scroll-body-top-controlled::-webkit-scrollbar { height: 0; }
      .notice-panel {
        background: #fffdf5;
        border-left: 4px solid #d6a943;
        padding: 14px 16px;
        margin: 22px 0;
        max-width: 1040px;
      }
      .notice-panel p:last-child { margin-bottom: 0; }
      .action-row {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        margin-top: 14px;
      }
      .action-row .btn { white-space: normal; }
      .about-section {
        border-top: 1px solid #d5dee2;
        margin-top: 28px;
        padding-top: 22px;
        max-width: 1040px;
      }
      .about-section:first-of-type {
        border-top: 0;
        margin-top: 10px;
        padding-top: 0;
      }
      .simple-list {
        max-width: 980px;
        padding-left: 22px;
      }
      .simple-list li {
        margin-bottom: 10px;
        line-height: 1.55;
      }
      .funding-layout {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 28px;
        margin-top: 18px;
      }
      .welcome-funding {
        border-top: 1px solid #d5dee2;
        margin-top: 42px;
        padding-top: 28px;
      }
      .project-logo {
        display: block;
        height: auto;
        max-width: 240px;
        width: 100%;
      }
      .eu-logo {
        display: block;
        height: auto;
        max-width: 220px;
        width: 100%;
      }
      .app-footer {
        border-top: 1px solid #d5dee2;
        color: #5d6c73;
        font-size: 13px;
        margin: 28px 15px 18px;
        padding: 16px 0 0;
        text-align: center;
      }
      @media (max-width: 1050px) {
        .metric-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
      }
      @media (max-width: 767px) {
        .app-title { font-size: 25px; }
        .tab-content { padding: 20px 15px 26px; }
        .metric-grid { grid-template-columns: 1fr; }
        .score-highlight { max-width: none; padding: 20px; }
        .score-highlight-value { font-size: 44px; }
        .section-heading { font-size: 23px; }
        .data-section { margin-top: 64px; padding-top: 28px; }
        .funding-layout { align-items: flex-start; flex-direction: column; }
        .project-logo, .eu-logo { max-width: 210px; }
      }
    "))
  ),

  titlePanel(
    windowTitle = "LONELY-EU Evidence Explorer",
    title = tags$h1("LONELY-EU Evidence Explorer", class = "app-title")
  ),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      div(
        id = "filters",
        div(
          class = "sidebar-section",
          tags$h4("Choose countries"),
          uiOutput("country_filter_ui"),
          tags$p(
            "Additional subgroup comparisons are available in:",
            class = "sidebar-note"
          ),
          tags$ul(
            class = "sidebar-links",
            tags$li(tags$a(
              href = "#",
              onclick = "$('.nav-tabs a[data-value=\"loneliness\"]').tab('show'); return false;",
              "Loneliness Levels"
            )),
            tags$li(tags$a(
              href = "#",
              onclick = "$('.nav-tabs a[data-value=\"associations\"]').tab('show'); return false;",
              "Socioeconomic Links"
            ))
          )
        )
      ),
      actionButton("resetFilters", "Reset country selection", icon = icon("refresh")),
      shinyjs::useShinyjs()
    ),

    mainPanel(
      width = 9,
      tabsetPanel(
        id = "evidence_section",
        type = "tabs",
        tabPanel(
          "Welcome",
          value = "welcome",
          div(
            class = "intro-panel",
            tags$h3("Welcome to the LONELY-EU Evidence Explorer"),
            tags$p("This explorer addresses two questions:")
          ),
          div(
            class = "question-block",
            tags$h3("Question 1: Loneliness levels"),
            tags$p(
              "How lonely were people across the selected countries? Here, you can compare reported loneliness levels across countries and study groups."
            )
          ),
          div(
            class = "question-block",
            tags$h3("Question 2: Socioeconomic links"),
            tags$p(
              "To what extent is loneliness related to socioeconomic indicators? Here, you can examine different indicators and compare the available associations across study groups."
            )
          ),
          tags$h3("How to use the explorer"),
          tags$ol(
            class = "steps-list",
            tags$li("Start with all countries selected, or choose one or more countries from the filter on the left."),
            tags$li("Open Loneliness Levels to explore reported loneliness scores."),
            tags$li("Open Socioeconomic Links to explore associations between loneliness and socioeconomic indicators."),
            tags$li("Use the comparison controls within each section to examine differences across sample characteristics.")
          ),
          div(
            class = "sentence-grid",
            tags$div(
              class = "sentence-card",
              tags$h4("What this explorer can help with"),
              tags$p("It can help you compare reported loneliness scores across selected countries and study groups, and see where evidence exists for socioeconomic indicators.")
            ),
            tags$div(
              class = "sentence-card",
              tags$h4("What this explorer cannot tell you"),
              tags$p("It does not provide individual-level analysis, clinical advice, causal proof, or direct policy recommendations. It should be read as an evidence summary and evidence map.")
            ),
            tags$div(
              class = "sentence-card",
              tags$h4("Need individual-level datasets?"),
              tags$p(
                "For information about available European loneliness datasets and opportunities for individual-level analyses, visit the ",
                tags$a(
                  href = app_config$wp3_url,
                  target = "_blank",
                  rel = "noopener noreferrer",
                  "EU Loneliness Explorer"
                ),
                "."
              )
            )
          ),
          div(
            class = "welcome-funding",
            tags$h3("Funding"),
            tags$p(
              paste0(
                "This evidence explorer was developed as part of Work Package 4 of the LONELY-EU project, funded by the European Union under Grant Agreement No. ",
                app_config$grant_number,
                "."
              )
            ),
            div(
              class = "funding-layout",
              tags$img(src = "lonely-eu-logo.png", alt = "LONELY-EU", class = "project-logo"),
              tags$img(src = "funded-by-eu.png", alt = "Funded by the European Union", class = "eu-logo")
            )
          )
        ),

        tabPanel(
          "Loneliness Levels",
          value = "loneliness",
          tags$h2("How lonely were people across the selected countries?", class = "section-heading"),
          div(
            class = "section-filter",
            checkboxInput(
              "loneliness_representative_only",
              "Show representative samples only",
              value = FALSE
            )
          ),
          uiOutput("loneliness_average_highlight") %>% shinycssloaders::withSpinner(),
          tags$h3("Benchmark across all countries"),
          tags$p(
            "These values compare the selected countries with the full set of countries currently included in the database.",
            class = "section-note"
          ),
          uiOutput("loneliness_benchmark") %>% shinycssloaders::withSpinner(),
          uiOutput("loneliness_interpretation_note") %>% shinycssloaders::withSpinner(),
          tags$h3("Evidence behind this average score"),
          tags$p(
            "The summary above is based on the currently selected evidence:",
            class = "section-note"
          ),
          uiOutput("loneliness_sample_overview") %>% shinycssloaders::withSpinner(),
          tags$h3("Compare loneliness scores across different groups"),
          tags$p(
            "Choose a sample characteristic below.",
            class = "section-note"
          ),
          div(
            class = "control-panel",
            selectInput(
              "loneliness_compare_group",
              "Compare by sample characteristic",
              choices = c(
                "Age of the study sample" = "metaUI__filter_Public_age_group",
                "Sample gender composition" = "metaUI__filter_Gender_composition",
                "How participants were recruited" = "metaUI__filter_Recruitment",
                "European region" = "metaUI__filter_European_region",
                "Country" = "metaUI__filter_Country"
              ),
              selected = "metaUI__filter_Public_age_group"
            ),
            conditionalPanel(
              "input.loneliness_compare_group == 'metaUI__filter_Gender_composition'",
              tags$p(
                "Mostly female samples contain more than 60% female participants; mostly male samples contain less than 40%; and mixed-gender samples contain 40% to 60%. These groups describe study samples and do not estimate individual gender differences in loneliness.",
                class = "section-note"
              )
            )
          ),
          div(
            class = "figure-panel",
            tags$h4("Reported loneliness scores by the selected comparison"),
            uiOutput("loneliness_compare_plot_ui")
          ),
          div(
            class = "figure-note",
            tags$b("How to read this figure: "),
            "Each dot is one reported loneliness estimate. The box covers the middle 50% of scores in that group, the line inside the box is the median, and the whiskers show the usual range. A wider spread of dots indicates greater variation in the reported scores."
          ),
          div(
            class = "summary-table-section",
            tags$h4("Comparison summary"),
            DT::dataTableOutput("loneliness_compare_table")
          ),
          div(
            class = "country-count-section",
            tags$h4("Number of scores by country"),
            tags$p(
              "This shows how much evidence is available for each selected country.",
              class = "section-note"
            ),
            plotOutput("loneliness_country_count_plot", height = "420px")
          ),
          div(
            class = "data-section",
            tags$h3("Detailed study information"),
            tags$p(
              "The table below shows paper- and study-level information for the reported loneliness scores. Scroll horizontally to view all available fields.",
              class = "section-note"
            ),
            DT::dataTableOutput("loneliness_levels_table")
          )
        ),

        tabPanel(
          "Socioeconomic Links",
          value = "associations",
          tags$h2("To what extent is loneliness related to socioeconomic indicators?", class = "section-heading"),
          tags$p(
            "This section summarises reported associations between loneliness and socioeconomic indicators.",
            class = "section-lead"
          ),
          div(
            class = "section-filter",
            checkboxInput(
              "association_representative_only",
              "Show representative samples only",
              value = FALSE
            )
          ),
          div(
            class = "control-panel",
            fluidRow(
              column(6, uiOutput("ses_category_filter_ui")),
              column(6, uiOutput("ses_indicator_filter_ui"))
            )
          ),
          uiOutput("association_overview") %>% shinycssloaders::withSpinner(),
          uiOutput("association_plain_summary") %>% shinycssloaders::withSpinner(),
          tags$h3("Compare loneliness associations across different groups"),
          tags$p(
            "Choose a sample characteristic below.",
            class = "section-note"
          ),
          div(
            class = "control-panel",
            selectInput(
              "association_compare_group",
              "Compare by sample characteristic",
              choices = c(
                "Age of the study sample" = "metaUI__filter_Age of study sample",
                "Sample gender composition" = "metaUI__filter_Sample gender composition",
                "How participants were recruited" = "metaUI__filter_How participants were recruited",
                "European region" = "metaUI__filter_European region",
                "Country" = "metaUI__filter_Country"
              ),
              selected = "metaUI__filter_Age of study sample"
            ),
            conditionalPanel(
              "input.association_compare_group == 'metaUI__filter_Sample gender composition'",
              tags$p(
                "These groups describe the gender composition of each study sample; they do not estimate individual gender differences in loneliness.",
                class = "section-note"
              )
            )
          ),
          div(
            class = "figure-panel",
            uiOutput("association_compare_plot_ui")
          ),
          div(
            class = "figure-note",
            tags$b("How to read this figure: "),
            "Each dot is one reported association. Values to the left of the dashed zero line are negative correlations, while values to the right are positive correlations. Where enough results are available, the box covers the middle 50% and the line inside it is the median. Separate panels represent different indicators."
          ),
          div(
            class = "notice-panel",
            tags$b("Please interpret these comparisons cautiously."),
            tags$p(
              "Some indicators and groups are represented by only a small number of associations. Correlation does not establish causation."
            )
          ),
          div(
            class = "summary-table-section",
            tags$h4("Comparison summary"),
            DT::dataTableOutput("association_compare_table")
          ),
          div(
            class = "country-count-section",
            tags$h4("Number of associations by country"),
            tags$p(
              "This shows how much association evidence is available for each selected country and socioeconomic indicator selection.",
              class = "section-note"
            ),
            plotOutput("association_country_count_plot", height = "420px")
          ),
          div(
            class = "data-section",
            tags$h3("Detailed study information"),
            tags$p(
              "The table below shows paper- and study-level information for the reported associations. Scroll horizontally to view all available fields.",
              class = "section-note"
            ),
            DT::dataTableOutput("sample_table")
          )
        ),

        tabPanel(
          "Use & Limitations",
          value = "limitations",
          div(
            class = "about-section",
            tags$h3("How this explorer can be used"),
            tags$ul(
              class = "simple-list",
              tags$li("To compare the loneliness level reported in one study with the broader set of study estimates included here."),
              tags$li("To identify where evidence is concentrated and where evidence is scarce."),
              tags$li("To explore whether reported loneliness scores or loneliness-socioeconomic links look different across countries and sample characteristics."),
              tags$li("To support discussion, teaching, research planning, and evidence mapping.")
            )
          ),
          div(
            class = "about-section",
            tags$h3("Important limitations"),
            tags$ul(
              class = "simple-list",
              tags$li("The database is still being expanded, so the current evidence is incomplete."),
              tags$li("The app summarises published study-level results and does not contain individual participant data."),
              tags$li("The app cannot test intersectional risk patterns, such as how age, gender, income, and country combine within individuals. For individual-level dataset exploration, use the EU Loneliness Explorer linked on the Welcome page."),
              tags$li("Correlations do not establish causation."),
              tags$li("The database does not currently code detailed evidence on measurement invariance, factor structure, or other psychometric properties of each loneliness instrument. Reliability is available where reported, but many studies do not test whether the same measure works equivalently across groups. This limits how strongly cross-group comparisons should be interpreted."),
              tags$li("Differences across groups may reflect real differences, but they may also reflect differences in study design, measurement tools, or reporting practices."),
              tags$li("The app provides evidence summaries, not clinical advice, individual recommendations, or direct policy prescriptions.")
            )
          ),
          div(
            class = "about-section",
            tags$h3("Why results may look inconsistent"),
            tags$p(
              "Some inconsistency is expected. Studies can differ in who they sampled, which loneliness measure they used, how socioeconomic indicators were coded, and which statistical result they reported. The explorer is designed to make this heterogeneity visible rather than hide it."
            )
          )
        ),

        tabPanel(
          "Technical Details",
          value = "technical",
          div(
            class = "about-section",
            tags$h3("Loneliness score calculation"),
            tags$p(
              "When a study reports the possible range of its loneliness measure, the reported mean is rescaled to a 0-100 POMP score."
            ),
            tags$p(
              "Formula: ",
              tags$b("100 x (reported mean - scale minimum) / (scale maximum - scale minimum).")
            ),
            tags$p(
              "A score of 0 means the lowest possible loneliness score on that study's scale. A score of 100 means the highest possible loneliness score. Where the original scale direction indicates that higher raw scores mean less loneliness, the displayed score is reversed so that higher displayed values consistently indicate more loneliness."
            )
          ),
          div(
            class = "about-section",
            tags$h3("Association display"),
            tags$p(
              "The Socioeconomic Links section currently displays reported Pearson correlations. Values below zero indicate negative correlations and values above zero indicate positive correlations, but indicator coding should be checked before making substantive conclusions about direction."
            )
          ),
          div(
            class = "about-section",
            tags$h3("Methodological documentation"),
            tags$p(
              "Full methodological documentation, including the preregistered search protocol, inclusion criteria, data extraction procedures, and variable definitions, is provided in the accompanying technical report hosted on OSF."
            ),
            if (is.na(app_config$osf_url)) {
              tags$p(tags$b("OSF link forthcoming."), class = "section-note")
            } else {
              tags$a(
                href = app_config$osf_url,
                target = "_blank",
                rel = "noopener noreferrer",
                class = "btn btn-primary",
                icon("external-link"),
                "Open the OSF technical report"
              )
            }
          )
        ),

        tabPanel(
          "About & Documentation",
          value = "about",
          div(
            class = "about-section",
            tags$h3("Current data coverage"),
            tags$p(
              "The explorer currently presents data retrieved from research published in 2023 and 2024. It does not contain individual participant data. The research team is expanding coverage to earlier publication years, and we welcome suggestions of potentially eligible studies."
            )
          ),
          div(
            class = "about-section",
            tags$h3("Citation notice"),
            tags$p(
              "If you use this app or the underlying database in a publication, report, presentation, or other public output, please cite the OSF technical report."
            )
          ),
          div(
            class = "about-section",
            tags$h3("Report an error or suggest a study"),
            tags$p(
              tags$b(app_config$contact_name), tags$br(),
              tags$a(href = paste0("mailto:", app_config$contact_email), app_config$contact_email)
            ),
            tags$p(
              "Although the data have been carefully checked, errors or omissions may remain. Please contact us if you identify a possible error or know of a potentially eligible study. All submissions are reviewed by the research team before the database is updated."
            ),
            div(
              class = "action-row",
              tags$a(
                href = app_config$report_error_mailto,
                class = "btn btn-primary",
                icon("envelope"),
                "Report an error"
              ),
              tags$a(
                href = app_config$suggest_study_mailto,
                class = "btn btn-default",
                icon("plus"),
                "Suggest a study"
              )
            )
          )
        )
      )
    )
  ),
  tags$footer(
    class = "app-footer",
    "LONELY-EU Evidence Explorer | Work Package 4"
  )
)
