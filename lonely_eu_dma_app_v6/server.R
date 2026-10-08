function(input, output, session) {

  metric_card <- function(value, label) {
    tags$div(
      class = "metric-card",
      tags$div(value, class = "metric-value"),
      tags$div(label, class = "metric-label")
    )
  }

  format_count <- function(x) {
    if (length(x) == 0 || is.na(x) || !is.finite(x)) {
      return("Not available")
    }
    format(round(x), big.mark = ",", scientific = FALSE, trim = TRUE)
  }

  top_scroll_callback <- DT::JS(
    "var container = $(table.table().container());",
    "var scrollBody = container.find('div.dataTables_scrollBody');",
    "if (scrollBody.length && !container.find('.dt-top-scroll').length) {",
    "  var topScroll = $('<div class=\"dt-top-scroll\"><div class=\"dt-top-scroll-inner\"></div></div>');",
    "  container.find('div.dataTables_scroll').before(topScroll);",
    "  scrollBody.addClass('dt-scroll-body-top-controlled');",
    "  var updateTopWidth = function() {",
    "    topScroll.children().width(scrollBody[0].scrollWidth);",
    "  };",
    "  topScroll.on('scroll', function() { scrollBody.scrollLeft(topScroll.scrollLeft()); });",
    "  scrollBody.on('scroll', function() { topScroll.scrollLeft(scrollBody.scrollLeft()); });",
    "  table.on('draw.dt column-sizing.dt', updateTopWidth);",
    "  setTimeout(updateTopWidth, 0);",
    "}"
  )

  missing_group_labels <- c(
    "", "(Missing)", "Missing", "Not specified",
    "Age not reported", "Gender composition not reported"
  )

  manual_group_order <- function(group_col) {
    switch(
      group_col,
      "metaUI__filter_Public_age_group" =
        c("Under 18", "18-29", "30-44", "45-59", "60-74", "75+"),
      "metaUI__filter_Age of study sample" =
        c("Under 18", "18-29", "30-44", "45-59", "60-74", "75+"),
      "metaUI__filter_Gender_composition" =
        c("Mostly male sample", "Mixed-gender sample", "Mostly female sample"),
      "metaUI__filter_Sample gender composition" =
        c("Mostly male sample", "Mixed-gender sample", "Mostly female sample"),
      "metaUI__filter_Recruitment" =
        c("Representative sample", "Convenience or community sample", "Other sample"),
      "metaUI__filter_How participants were recruited" =
        c("Representative sample", "Convenience or community sample", "Other sample"),
      "metaUI__filter_European_region" =
        c("Northern Europe", "Western Europe", "Southern Europe", "Central and Eastern Europe", "Multiple countries"),
      "metaUI__filter_European region" =
        c("Northern Europe", "Western Europe", "Southern Europe", "Central and Eastern Europe", "Multiple countries"),
      NULL
    )
  }

  category_manual_order <- c(
    "Socioeconomic status (SES)",
    "Minority status",
    "Structural indicators of social connection",
    "Functional indicators of social connection",
    "Social/Civic Outcomes"
  )

  indicator_manual_order <- list(
    "Socioeconomic status (SES)" = c(
      "Education", "Income", "Housing", "Employment",
      "Subjective socioeconomic status (SES)"
    ),
    "Minority status" = c("Racial/ethnic", "Gender/sexual", "Religious"),
    "Structural indicators of social connection" = c(
      "Household", "Partnership/marital status", "Family composition",
      "Social network", "Social embeddedness"
    ),
    "Functional indicators of social connection" = c(
      "Frequent interactions with family members",
      "Frequent interactions with friends", "Everyday sociability",
      "Social support"
    ),
    "Social/Civic Outcomes" = c(
      "Political engagement", "Volunteering", "Trust and distrust"
    )
  )

  order_with_manual <- function(values, manual_order) {
    values <- unique(as.character(values))
    c(
      manual_order[manual_order %in% values],
      sort(setdiff(values, manual_order))
    )
  }

  all_country_choices <- function() {
    association_countries <- as.character(metaUI__df[["metaUI__filter_Country"]])
    level_countries <- if ("metaUI__filter_Country" %in% names(loneliness_levels_df)) {
      as.character(loneliness_levels_df[["metaUI__filter_Country"]])
    } else {
      character()
    }

    choices <- sort(unique(c(association_countries, level_countries)))
    choices <- choices[
      !is.na(choices) &
        !choices %in% c("", "(Missing)", "Missing", "Not reported") &
        nchar(choices) <= 40 &
        !stringr::str_detect(choices, "[|=]")
    ]
    choices
  }

  output$country_filter_ui <- renderUI({
    choices <- all_country_choices()
    shinyWidgets::pickerInput(
      "metaUI__filter_Country",
      NULL,
      choices = choices,
      selected = choices,
      multiple = TRUE,
      options = list(
        `actions-box` = TRUE,
        `selected-text-format` = "count > 2",
        `count-selected-text` = "{0} countries selected",
        `live-search` = TRUE
      )
    )
  })

  observeEvent(input$resetFilters, {
    shinyWidgets::updatePickerInput(
      session = session,
      inputId = "metaUI__filter_Country",
      selected = all_country_choices()
    )
  })

  # Apply the country filter across both evidence sections.
  df_filtered <- reactive({
    df_reactive()
  })

  df_reactive <- reactive({
    df <- metaUI__df
    selected <- input[["metaUI__filter_Country"]]
    if (!is.null(selected) && !setequal(selected, all_country_choices())) {
      df <- df[df[["metaUI__filter_Country"]] %in% selected, ]
    }
    if (isTRUE(input$association_representative_only)) {
      df <- df[
        df[["metaUI__filter_How participants were recruited"]] %in% "Representative sample",
      ]
    }
    df
  })

  valid_ses_categories <- function(df) {
    category <- as.character(df[["metaUI__filter_SES category"]])
    indicator <- as.character(df[["metaUI__filter_SES indicator"]])
    usable <-
      !is.na(category) &
      !category %in% c("", "(Missing)", "Missing", "Demographic") &
      !is.na(indicator) &
      !indicator %in% c("", "(Missing)", "Missing")
    order_with_manual(category[usable], category_manual_order)
  }

  output$ses_category_filter_ui <- renderUI({
    choices <- valid_ses_categories(df_filtered())

    validate(
      need(length(choices) > 0, "No socioeconomic indicator categories are available for the selected countries.")
    )

    selectInput(
      "ses_category_filter",
      "1. Choose a socioeconomic indicator category",
      choices = choices,
      selected = choices[1]
    )
  })

  output$ses_indicator_filter_ui <- renderUI({
    df <- df_filtered()
    category <- input$ses_category_filter

    if (!is.null(category)) {
      df <- df %>%
        dplyr::filter(as.character(.data[["metaUI__filter_SES category"]]) == category)
    }

    choices <- unique(as.character(df[["metaUI__filter_SES indicator"]]))
    choices <- choices[!is.na(choices) & !choices %in% c("", "(Missing)", "Missing")]
    manual_order <- indicator_manual_order[[category]]
    if (is.null(manual_order)) manual_order <- character()
    choices <- order_with_manual(choices, manual_order)

    shinyWidgets::pickerInput(
      "ses_indicator_filter",
      "2. Choose specific socioeconomic indicator(s)",
      choices = choices,
      selected = choices,
      multiple = TRUE,
      options = list(
        `actions-box` = TRUE,
        `selected-text-format` = "count > 1",
        `count-selected-text` = "{0} indicators selected"
      )
    )
  })

  association_category_df <- reactive({
    df <- df_filtered()
    choices <- valid_ses_categories(df)

    if (length(choices) == 0) {
      return(df[0, ])
    }

    category <- input$ses_category_filter
    if (is.null(category) || !category %in% choices) {
      category <- choices[1]
    }

    df <- df %>%
      dplyr::filter(
        as.character(.data[["metaUI__filter_SES category"]]) == category,
        !is.na(.data[["metaUI__effect_size"]]),
        !is.na(.data[["metaUI__filter_SES indicator"]]),
        !as.character(.data[["metaUI__filter_SES indicator"]]) %in%
          c("", "(Missing)", "Missing")
      )

    indicators <- input$ses_indicator_filter
    if (!is.null(indicators) && length(indicators) > 0) {
      df <- df %>%
        dplyr::filter(as.character(.data[["metaUI__filter_SES indicator"]]) %in% indicators)
    }

    df
  })

  loneliness_levels_reactive <- reactive({
    df <- loneliness_levels_df

    selected <- input[["metaUI__filter_Country"]]
    if (
      "metaUI__filter_Country" %in% names(df) &&
        !is.null(selected) &&
        !setequal(selected, all_country_choices())
    ) {
      df <- df[df[["metaUI__filter_Country"]] %in% selected, ]
    }
    if (isTRUE(input$loneliness_representative_only)) {
      df <- df[
        df[["metaUI__filter_Recruitment"]] %in% "Representative sample",
      ]
    }
    df
  })

  loneliness_levels_all_countries_reactive <- reactive({
    df <- loneliness_levels_df
    if (isTRUE(input$loneliness_representative_only)) {
      df <- df[
        df[["metaUI__filter_Recruitment"]] %in% "Representative sample",
      ]
    }
    df
  })

  loneliness_level_value <- reactive({
    df <- loneliness_levels_reactive()
    if ("loneliness_pomp" %in% names(df) && sum(!is.na(df$loneliness_pomp)) >= 5) {
      list(
        column = "loneliness_pomp",
        label = "Loneliness score rescaled to 0-100"
      )
    } else {
      list(
        column = "Loneliness_M",
        label = "Reported mean loneliness score"
      )
    }
  })

  output$loneliness_average_highlight <- renderUI({
    df <- loneliness_levels_reactive()
    value <- loneliness_level_value()
    average_score <- if (nrow(df) > 0 && any(!is.na(df[[value$column]]))) {
      sprintf("%.2f", mean(df[[value$column]], na.rm = TRUE))
    } else {
      "Not available"
    }

    tags$div(
      class = "score-highlight",
      tags$div(average_score, class = "score-highlight-value"),
      tags$div("Average loneliness score in selected countries", class = "score-highlight-label"),
      tags$p(
        tags$span("This simple average is calculated from the study estimates currently shown after filtering. "),
        tags$a(
          href = "#",
          onclick = "$('.nav-tabs a[data-value=\"technical\"]').tab('show'); return false;",
          "See Technical Details for how the score is calculated."
        ),
        class = "score-highlight-note"
      )
    )
  })

  output$loneliness_benchmark <- renderUI({
    selected_df <- loneliness_levels_reactive()
    df <- loneliness_levels_all_countries_reactive()
    value <- loneliness_level_value()
    selected_scores <- selected_df[[value$column]]
    selected_scores <- selected_scores[!is.na(selected_scores)]
    scores <- df[[value$column]]
    scores <- scores[!is.na(scores)]

    if (length(scores) == 0) {
      return(tags$p("No benchmark is available for the current selection.", class = "section-note"))
    }

    selected_avg <- if (length(selected_scores) > 0) mean(selected_scores, na.rm = TRUE) else NA_real_
    avg <- mean(scores, na.rm = TRUE)

    country_avgs <- df %>%
      dplyr::filter(
        !is.na(.data[[value$column]]),
        !is.na(.data[["metaUI__filter_Country"]]),
        !.data[["metaUI__filter_Country"]] %in% c("", "(Missing)", "Missing")
      ) %>%
      dplyr::group_by(.data[["metaUI__filter_Country"]]) %>%
      dplyr::summarise(country_average = mean(.data[[value$column]], na.rm = TRUE), .groups = "drop")
    median_country_score <- if (nrow(country_avgs) > 0) {
      stats::median(country_avgs$country_average, na.rm = TRUE)
    } else {
      NA_real_
    }
    relative_position <- if (!is.na(selected_avg) && nrow(country_avgs) > 0) {
      paste0(
        "Higher than about ",
        round(mean(country_avgs$country_average < selected_avg) * 100),
        "% of country averages"
      )
    } else {
      "Not available"
    }

    tags$div(
      class = "metric-grid benchmark-grid",
      metric_card(sprintf("%.2f", avg), "Average across all EU countries"),
      metric_card(sprintf("%.2f", median_country_score), "Median country score"),
      metric_card(relative_position, "Selected countries compared with all countries")
    )
  })

  output$loneliness_interpretation_note <- renderUI({
    selected_df <- loneliness_levels_reactive()
    df <- loneliness_levels_all_countries_reactive()
    value <- loneliness_level_value()
    selected_scores <- selected_df[[value$column]]
    selected_scores <- selected_scores[!is.na(selected_scores)]
    scores <- df[[value$column]]
    scores <- scores[!is.na(scores)]

    if (length(scores) == 0 || length(selected_scores) == 0) return(NULL)

    avg <- mean(scores, na.rm = TRUE)
    selected_avg <- mean(selected_scores, na.rm = TRUE)

    tags$div(
      class = "info-panel plain-info",
      tags$b("How to read this benchmark"),
      tags$p(
        paste0(
          "The selected countries have an average score of ",
          sprintf("%.2f", selected_avg),
          ". Across all countries in the current database, the average is ",
          sprintf("%.2f", avg),
          ". These scores are useful for relative comparison, not as clinical thresholds or official prevalence estimates."
        )
      )
    )
  })

  output$loneliness_sample_overview <- renderUI({
    df <- loneliness_levels_reactive()

    countries <- as.character(df[["metaUI__filter_Country"]])
    countries <- countries[!is.na(countries) & !countries %in% c("", "(Missing)")]
    sample_count <- if ("Study_sample_ID" %in% names(df)) {
      dplyr::n_distinct(df$Study_sample_ID, na.rm = TRUE)
    } else {
      nrow(df)
    }
    sample_sizes <- if ("Study_sample_ID" %in% names(df)) {
      df %>%
        dplyr::filter(!is.na(Study_sample_ID), !is.na(metaUI__N)) %>%
        dplyr::group_by(Study_sample_ID) %>%
        dplyr::summarise(metaUI__N = max(metaUI__N, na.rm = TRUE), .groups = "drop")
    } else {
      df %>% dplyr::select(metaUI__N)
    }

    tags$div(
      class = "metric-grid",
      metric_card(format_count(nrow(df)), "Number of scores"),
      metric_card(format_count(sample_count), "Study samples"),
      metric_card(format_count(dplyr::n_distinct(countries)), "Countries represented"),
      metric_card(format_count(sum(sample_sizes$metaUI__N, na.rm = TRUE)), "Combined reported sample size")
    )
  })

  loneliness_compare_plot_height <- reactive({
    df <- loneliness_levels_reactive()
    group_col <- input$loneliness_compare_group
    if (is.null(group_col) || !group_col %in% names(df)) return(500)
    groups <- as.character(df[[group_col]])
    group_count <- length(unique(groups[
      !is.na(groups) & !groups %in% missing_group_labels
    ]))
    max(500, min(1100, 120 + 38 * group_count))
  })

  output$loneliness_compare_plot_ui <- renderUI({
    plotly::plotlyOutput(
      "loneliness_compare_plot",
      height = paste0(loneliness_compare_plot_height(), "px")
    ) %>% shinycssloaders::withSpinner()
  })

  output$loneliness_levels_table <- DT::renderDataTable({
    df <- loneliness_levels_reactive()

    out <- df %>%
      dplyr::select(dplyr::any_of(c(
        "Title", "Author", "Year_of_publication",
        "metaUI__filter_Country", "metaUI__filter_European_region", "metaUI__N",
        "metaUI__filter_Recruitment",
        "mean_age", "Age_Min", "Age_Max", "female_prop",
        "metaUI__filter_Public_age_group", "metaUI__filter_Gender_composition",
        "metaUI__filter_Loneliness_measure", "metaUI__filter_Loneliness_type",
        "Number_of_items", "Direction_of_measure",
        "Theoretical_range_of_the_scale", "Loneliness_M", "Loneliness_SD",
        "loneliness_pomp", "Reliability", "Time_point", "Time_unit",
        "Time_interval"
      ))) %>%
      dplyr::mutate(female_percent = female_prop * 100) %>%
      dplyr::select(-dplyr::any_of("female_prop")) %>%
      dplyr::rename(
        `Paper title` = dplyr::any_of("Title"),
        Authors = dplyr::any_of("Author"),
        `Publication year` = dplyr::any_of("Year_of_publication"),
        Country = dplyr::any_of("metaUI__filter_Country"),
        `European region` = dplyr::any_of("metaUI__filter_European_region"),
        `Sample size` = dplyr::any_of("metaUI__N"),
        `How participants were recruited` = dplyr::any_of("metaUI__filter_Recruitment"),
        `Mean age` = dplyr::any_of("mean_age"),
        `Minimum age` = dplyr::any_of("Age_Min"),
        `Maximum age` = dplyr::any_of("Age_Max"),
        `Female participants (%)` = dplyr::any_of("female_percent"),
        `Age of study sample` = dplyr::any_of("metaUI__filter_Public_age_group"),
        `Gender composition` = dplyr::any_of("metaUI__filter_Gender_composition"),
        `Loneliness measure` = dplyr::any_of("metaUI__filter_Loneliness_measure"),
        `Loneliness type` = dplyr::any_of("metaUI__filter_Loneliness_type"),
        `Number of items` = dplyr::any_of("Number_of_items"),
        `Direction of measure` = dplyr::any_of("Direction_of_measure"),
        `Reported mean` = dplyr::any_of("Loneliness_M"),
        `Loneliness SD` = dplyr::any_of("Loneliness_SD"),
        `Loneliness score, 0-100` = dplyr::any_of("loneliness_pomp"),
        `Scale range` = dplyr::any_of("Theoretical_range_of_the_scale"),
        Reliability = dplyr::any_of("Reliability"),
        `Time point` = dplyr::any_of("Time_point"),
        `Time unit` = dplyr::any_of("Time_unit"),
        `Time interval` = dplyr::any_of("Time_interval")
      ) %>%
      dplyr::relocate(`Female participants (%)`, .after = `Maximum age`) %>%
      dplyr::mutate(
        dplyr::across(
          where(is.character),
          ~ dplyr::if_else(
            is.na(.x) | .x %in% c("", "(Missing)", "Missing"),
            "Not reported",
            .x
          )
        )
      )

    DT::datatable(
      out,
      rownames = FALSE,
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        scrollCollapse = TRUE,
        autoWidth = TRUE
      ),
      callback = top_scroll_callback
    ) %>%
      DT::formatRound(columns = intersect("Sample size", names(out)), digits = 0, mark = ",") %>%
      DT::formatRound(
        columns = intersect(c(
          "Mean age", "Minimum age", "Maximum age", "Female participants (%)",
          "Reported mean", "Loneliness SD", "Loneliness score, 0-100"
        ), names(out)),
        digits = 2
      )
  })

  output$loneliness_compare_table <- DT::renderDataTable({
    df <- loneliness_levels_reactive()
    value <- loneliness_level_value()
    group_col <- input$loneliness_compare_group

    validate(
      need(group_col %in% names(df), "This grouping is not available in the loneliness levels data.")
    )

    out <- df %>%
      dplyr::filter(!is.na(.data[[value$column]]), !is.na(.data[[group_col]])) %>%
      dplyr::mutate(Group = as.character(.data[[group_col]])) %>%
      dplyr::filter(!Group %in% missing_group_labels) %>%
      dplyr::group_by(Group) %>%
      dplyr::summarise(
        `Number of scores` = dplyr::n(),
        `Average score` = mean(.data[[value$column]], na.rm = TRUE),
        Median = median(.data[[value$column]], na.rm = TRUE),
        Minimum = min(.data[[value$column]], na.rm = TRUE),
        Maximum = max(.data[[value$column]], na.rm = TRUE),
        .groups = "drop"
      )

    group_levels <- manual_group_order(group_col)
    if (!is.null(group_levels)) {
      out <- out %>%
        dplyr::mutate(Group = factor(
          Group,
          levels = group_levels
        )) %>%
        dplyr::arrange(Group)
    } else if (group_col == "Number_of_items") {
      out <- out %>% dplyr::arrange(as.numeric(as.character(Group)))
    } else {
      out <- out %>% dplyr::arrange(dplyr::desc(`Number of scores`))
    }

    DT::datatable(out, rownames = FALSE, options = list(pageLength = 8, dom = "tip", autoWidth = TRUE)) %>%
      DT::formatRound(columns = c("Average score", "Median", "Minimum", "Maximum"), digits = 2)
  })

  output$loneliness_compare_plot <- plotly::renderPlotly({
    df <- loneliness_levels_reactive()
    value <- loneliness_level_value()
    group_col <- input$loneliness_compare_group

    validate(
      need(group_col %in% names(df), "This grouping is not available in the loneliness levels data.")
    )

    plot_df <- df %>%
      dplyr::filter(!is.na(.data[[value$column]]), !is.na(.data[[group_col]])) %>%
      dplyr::mutate(Group = as.character(.data[[group_col]])) %>%
      dplyr::filter(!Group %in% missing_group_labels)

    validate(
      need(nrow(plot_df) > 0, "No usable loneliness scores are available for this comparison.")
    )

    group_order <- manual_group_order(group_col)
    if (!is.null(group_order)) {
      group_order <- group_order[group_order %in% unique(plot_df$Group)]
    } else if (group_col == "Number_of_items") {
      group_order <- sort(unique(as.numeric(plot_df$Group)))
      group_order <- as.character(group_order[!is.na(group_order)])
    } else {
      group_order <- plot_df %>%
        dplyr::group_by(Group) %>%
        dplyr::summarise(mean_score = mean(.data[[value$column]], na.rm = TRUE), .groups = "drop") %>%
        dplyr::arrange(mean_score) %>%
        dplyr::pull(Group)
    }

    p <- ggplot2::ggplot(
      plot_df,
      ggplot2::aes(
        x = factor(Group, levels = group_order),
        y = .data[[value$column]],
        text = paste0(
          "Group: ", Group,
          "<br>Study: ", dplyr::coalesce(Study_name, "Not reported"),
          "<br>Estimate ID: ", dplyr::coalesce(Study_effect_ID, "Not reported"),
          "<br>Time point: ", dplyr::coalesce(Time_point, "Not reported"),
          "<br>Country: ", .data[["metaUI__filter_Country"]],
          "<br>Score: ", round(.data[[value$column]], 2)
        )
      )
    ) +
      ggplot2::geom_boxplot(outlier.shape = NA, fill = "#dceff2", color = "#244454") +
      ggplot2::geom_jitter(width = 0.16, alpha = 0.55, color = "#2d6f7e", size = 2) +
      ggplot2::coord_flip() +
      ggplot2::theme_minimal(base_size = 13) +
      ggplot2::theme(
        plot.margin = ggplot2::margin(8, 18, 8, 8),
        panel.grid.minor = ggplot2::element_blank(),
        axis.text = ggplot2::element_text(color = "#3f4f56")
      ) +
      ggplot2::labs(
        x = NULL,
        y = value$label
      )

    plotly::ggplotly(p, tooltip = "text") %>%
      plotly::config(displayModeBar = FALSE)
  })

  output$loneliness_country_count_plot <- renderPlot({
    df <- loneliness_levels_reactive()
    plot_df <- df %>%
      dplyr::filter(
        !is.na(.data[["metaUI__filter_Country"]]),
        !.data[["metaUI__filter_Country"]] %in% c("", "(Missing)", "Missing")
      ) %>%
      dplyr::count(Country = .data[["metaUI__filter_Country"]], name = "Number_of_scores") %>%
      dplyr::arrange(Number_of_scores)

    validate(need(nrow(plot_df) > 0, "No country information is available for the current selection."))

    ggplot2::ggplot(plot_df, ggplot2::aes(x = Number_of_scores, y = stats::reorder(Country, Number_of_scores))) +
      ggplot2::geom_col(fill = "#2d6f7e", alpha = 0.82) +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::theme(panel.grid.minor = ggplot2::element_blank()) +
      ggplot2::labs(x = "Number of scores", y = NULL)
  })

  output$association_compare_table <- DT::renderDataTable({
    df <- association_category_df()
    group_col <- input$association_compare_group

    validate(
      need(group_col %in% names(df), "This grouping is not available in the association data.")
    )

    out <- df %>%
      dplyr::filter(!is.na(.data[[group_col]])) %>%
      dplyr::mutate(
        Group = as.character(.data[[group_col]]),
        Indicator = as.character(.data[["metaUI__filter_SES indicator"]]),
        correlation_r = tanh(metaUI__effect_size)
      ) %>%
      dplyr::filter(!Group %in% missing_group_labels) %>%
      dplyr::group_by(Indicator, Group) %>%
      dplyr::summarise(
        Associations = dplyr::n(),
        Studies = dplyr::n_distinct(Study_ID),
        `Study samples` = dplyr::n_distinct(Study_sample_ID),
        `Average reported r` = mean(correlation_r, na.rm = TRUE),
        `Median reported r` = median(correlation_r, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      dplyr::arrange(Indicator, dplyr::desc(Associations), Group)

    names(out)[names(out) == "Indicator"] <- "SES indicator"

    DT::datatable(out, rownames = FALSE, options = list(pageLength = 10, scrollX = TRUE, dom = "tip", autoWidth = TRUE)) %>%
      DT::formatRound(columns = c("Average reported r", "Median reported r"), digits = 2)
  })

  association_panel_columns <- reactive({
    width <- session$clientData$output_association_compare_plot_width
    if (!is.null(width) && is.finite(width) && width < 760) 1 else 2
  })

  association_compare_plot_height <- reactive({
    df <- association_category_df()
    group_col <- input$association_compare_group
    if (!group_col %in% names(df)) {
      return(560)
    }

    indicator_count <- df %>%
      dplyr::filter(!is.na(.data[[group_col]])) %>%
      dplyr::mutate(
        Group = as.character(.data[[group_col]]),
        Indicator = as.character(.data[["metaUI__filter_SES indicator"]])
      ) %>%
      dplyr::filter(
        !Group %in% missing_group_labels,
        !Indicator %in% c("", "(Missing)", "Missing")
      ) %>%
      dplyr::pull(Indicator) %>%
      unique() %>%
      length()

    panel_rows <- ceiling(indicator_count / association_panel_columns())
    max(500, 300 * panel_rows + 100)
  })

  output$association_compare_plot_ui <- renderUI({
    plotOutput(
      "association_compare_plot",
      height = paste0(association_compare_plot_height(), "px")
    ) %>% shinycssloaders::withSpinner()
  })

  output$association_compare_plot <- renderPlot({
    df <- association_category_df()
    group_col <- input$association_compare_group

    validate(
      need(group_col %in% names(df), "This grouping is not available in the association data.")
    )

    plot_df <- df %>%
      dplyr::filter(!is.na(.data[[group_col]])) %>%
      dplyr::mutate(
        Group = as.character(.data[[group_col]]),
        Indicator = as.character(.data[["metaUI__filter_SES indicator"]]),
        correlation_r = tanh(metaUI__effect_size)
      ) %>%
      dplyr::filter(!Group %in% missing_group_labels)

    validate(
      need(nrow(plot_df) > 0, "No usable associations are available for this comparison.")
    )

    indicator_stats <- plot_df %>%
      dplyr::group_by(Indicator) %>%
      dplyr::summarise(
        Associations = dplyr::n(),
        Studies = dplyr::n_distinct(Study_ID),
        .groups = "drop"
      ) %>%
      dplyr::mutate(
        Indicator_title = paste0(
          stringr::str_to_lower(stringr::str_sub(Indicator, 1, 1)),
          stringr::str_sub(Indicator, 2)
        ),
        Evidence_note = paste0(
          Associations,
          if_else(Associations == 1, " association", " associations"),
          " from ", Studies,
          if_else(Studies == 1, " study", " studies"), "."
        ),
        Panel_label = paste0(
          "Correlation between ", Indicator_title, " and loneliness\n",
          Evidence_note
        )
      )
    indicator_labels <- stats::setNames(indicator_stats$Panel_label, indicator_stats$Indicator)

    indicator_order <- c(
      "Education", "Income", "Housing", "Employment", "Subjective socioeconomic status (SES)",
      "Racial/ethnic", "Gender/sexual", "Religious",
      "Household", "Partnership/marital status", "Family composition", "Social network", "Social embeddedness",
      "Frequent interactions with family members", "Frequent interactions with friends", "Everyday sociability", "Social support",
      "Political engagement", "Volunteering", "Trust and distrust", "Others"
    )
    indicator_order <- c(
      indicator_order[indicator_order %in% unique(plot_df$Indicator)],
      sort(setdiff(unique(plot_df$Indicator), indicator_order))
    )

    group_order <- manual_group_order(group_col)
    if (is.null(group_order)) {
      group_order <- plot_df %>%
        dplyr::group_by(Group) %>%
        dplyr::summarise(total_associations = dplyr::n(), .groups = "drop") %>%
        dplyr::arrange(dplyr::desc(total_associations)) %>%
        dplyr::pull(Group)
    }
    group_order <- group_order[group_order %in% unique(plot_df$Group)]

    plot_df <- plot_df %>%
      dplyr::mutate(
        Indicator = factor(Indicator, levels = indicator_order),
        Group = factor(Group, levels = rev(group_order))
      )

    boxplot_df <- plot_df %>%
      dplyr::group_by(Indicator, Group) %>%
      dplyr::filter(dplyr::n() >= 3) %>%
      dplyr::ungroup()

    ggplot2::ggplot(
      plot_df,
      ggplot2::aes(
        x = correlation_r,
        y = Group
      )
    ) +
      ggplot2::geom_vline(xintercept = 0, linetype = "dashed", color = "#777777") +
      ggplot2::geom_boxplot(
        data = boxplot_df,
        outlier.shape = NA,
        fill = "#dceff2",
        color = "#244454",
        width = 0.55
      ) +
      ggplot2::geom_jitter(height = 0.16, alpha = 0.55, color = "#2d6f7e", size = 2) +
      ggplot2::facet_wrap(
        ~ Indicator,
        ncol = association_panel_columns(),
        scales = "free_y",
        strip.position = "bottom",
        axes = "all_x",
        axis.labels = "all_x",
        labeller = ggplot2::labeller(
          Indicator = ggplot2::as_labeller(indicator_labels)
        )
      ) +
      ggplot2::scale_x_continuous(limits = c(-1, 1)) +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::theme(
        strip.placement = "inside",
        strip.background = ggplot2::element_rect(fill = "#f7f9fb", color = "#d8e0e6", linewidth = 0.7),
        strip.text = ggplot2::element_text(hjust = 0.5, size = 8.7, lineheight = 1.25, margin = ggplot2::margin(8, 3, 8, 3)),
        axis.text.y = ggplot2::element_text(size = 10),
        panel.grid.major.y = ggplot2::element_line(color = "#eeeeee"),
        panel.grid.minor = ggplot2::element_blank(),
        panel.border = ggplot2::element_rect(color = "#d8e0e6", fill = NA, linewidth = 0.8),
        panel.spacing = grid::unit(1.4, "lines"),
        plot.margin = ggplot2::margin(8, 12, 12, 12)
      ) +
      ggplot2::labs(
        x = "Correlation r",
        y = NULL
      )
  }, height = function() association_compare_plot_height())

  output$association_country_count_plot <- renderPlot({
    df <- association_category_df()
    plot_df <- df %>%
      dplyr::filter(
        !is.na(.data[["metaUI__filter_Country"]]),
        !.data[["metaUI__filter_Country"]] %in% c("", "(Missing)", "Missing")
      ) %>%
      dplyr::count(Country = .data[["metaUI__filter_Country"]], name = "Number_of_associations") %>%
      dplyr::arrange(Number_of_associations)

    validate(need(nrow(plot_df) > 0, "No country information is available for the current selection."))

    ggplot2::ggplot(plot_df, ggplot2::aes(x = Number_of_associations, y = stats::reorder(Country, Number_of_associations))) +
      ggplot2::geom_col(fill = "#2d6f7e", alpha = 0.82) +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::theme(panel.grid.minor = ggplot2::element_blank()) +
      ggplot2::labs(x = "Number of associations", y = NULL)
  })

  output$association_overview <- renderUI({
    df <- association_category_df()

    if (nrow(df) == 0) {
      return(tags$div(
        class = "metric-grid",
        metric_card("0", "Studies"),
        metric_card("0", "Study samples"),
        metric_card("0", "Indicators"),
        metric_card("0", "Reported associations"),
        metric_card("0", "Combined reported sample size")
      ))
    }

    study_count <- dplyr::n_distinct(df$Study_ID, na.rm = TRUE)
    sample_count <- dplyr::n_distinct(df$Study_sample_ID, na.rm = TRUE)
    indicator_count <- dplyr::n_distinct(df[["metaUI__filter_SES indicator"]], na.rm = TRUE)
    sample_sizes <- df %>%
      dplyr::filter(!is.na(Study_sample_ID), !is.na(metaUI__N)) %>%
      dplyr::group_by(Study_sample_ID) %>%
      dplyr::summarise(metaUI__N = max(metaUI__N, na.rm = TRUE), .groups = "drop")

    tags$div(
      class = "metric-grid",
      metric_card(format_count(study_count), "Studies"),
      metric_card(format_count(sample_count), "Study samples"),
      metric_card(format_count(indicator_count), "Indicators"),
      metric_card(format_count(nrow(df)), "Reported associations"),
      metric_card(format_count(sum(sample_sizes$metaUI__N, na.rm = TRUE)), "Combined reported sample size")
    )
  })

  output$association_plain_summary <- renderUI({
    df <- association_category_df()
    if (nrow(df) == 0) {
      return(tags$p("No association evidence is available for the current selection.", class = "section-note"))
    }

    category <- input$ses_category_filter
    indicator_count <- dplyr::n_distinct(df[["metaUI__filter_SES indicator"]], na.rm = TRUE)
    association_count <- nrow(df)
    study_count <- dplyr::n_distinct(df$Study_ID, na.rm = TRUE)

    tags$div(
      class = "info-panel plain-info",
      tags$b("Plain-language summary"),
      tags$p(
        paste0(
          "For ",
          category,
          ", the current selection includes ",
          format_count(association_count),
          " reported associations from ",
          format_count(study_count),
          " studies, covering ",
          format_count(indicator_count),
          " specific indicator(s). The figures below show whether the reported correlations tend to fall below zero, above zero, or vary across study groups."
        )
      ),
      tags$p(
        "Because indicator coding can differ across studies, these plots are best used as an evidence map rather than as direct policy guidance."
      )
    )
  })

  # Sample table -----------------------------------------------------------

  output$sample_table <- DT::renderDataTable({
    df <- association_category_df()

    out <- df %>%
      dplyr::select(dplyr::any_of(c(
        "Title", "Author", "Year_of_publication",
        "metaUI__N", "metaUI__filter_Country", "metaUI__filter_European region",
        "metaUI__filter_How participants were recruited",
        "mean_age", "female_prop", "metaUI__filter_Age of study sample",
        "metaUI__filter_Sample gender composition", "Majority", "Ethnicity",
        "metaUI__filter_Loneliness measure", "metaUI__filter_Loneliness type",
        "Number_of_items", "Reliability", "metaUI__filter_SES category",
        "metaUI__filter_SES indicator", "Operationalisation",
        "Socioeconomic_scale", "Socioeconomic_measurement",
        "Measure_of_association", "metaUI__effect_size", "Time_point",
        "Time_unit", "Time_interval", "Quality_of_measure"
      ))) %>%
      dplyr::mutate(
        `Correlation r` = tanh(.data$metaUI__effect_size),
        female_percent = female_prop * 100
      ) %>%
      dplyr::select(-dplyr::any_of("metaUI__effect_size")) %>%
      dplyr::select(-dplyr::any_of("female_prop")) %>%
      dplyr::rename(
        `Paper title` = dplyr::any_of("Title"),
        Authors = dplyr::any_of("Author"),
        `Publication year` = dplyr::any_of("Year_of_publication"),
        `Sample size` = dplyr::any_of("metaUI__N"),
        Country = dplyr::any_of("metaUI__filter_Country"),
        `European region` = dplyr::any_of("metaUI__filter_European region"),
        `How participants were recruited` = dplyr::any_of("metaUI__filter_How participants were recruited"),
        `Mean age` = dplyr::any_of("mean_age"),
        `Female participants (%)` = dplyr::any_of("female_percent"),
        `Age of study sample` = dplyr::any_of("metaUI__filter_Age of study sample"),
        `Gender composition` = dplyr::any_of("metaUI__filter_Sample gender composition"),
        `Majority group` = dplyr::any_of("Majority"),
        Ethnicity = dplyr::any_of("Ethnicity"),
        `Loneliness measure` = dplyr::any_of("metaUI__filter_Loneliness measure"),
        `Loneliness type` = dplyr::any_of("metaUI__filter_Loneliness type"),
        `Number of items` = dplyr::any_of("Number_of_items"),
        `Loneliness-measure reliability` = dplyr::any_of("Reliability"),
        `Indicator operationalisation` = dplyr::any_of("Operationalisation"),
        `Indicator scale` = dplyr::any_of("Socioeconomic_scale"),
        `Indicator measurement type` = dplyr::any_of("Socioeconomic_measurement"),
        `SES category` = dplyr::any_of("metaUI__filter_SES category"),
        `SES indicator` = dplyr::any_of("metaUI__filter_SES indicator"),
        `Association measure` = dplyr::any_of("Measure_of_association"),
        `Time point` = dplyr::any_of("Time_point"),
        `Time unit` = dplyr::any_of("Time_unit"),
        `Time interval` = dplyr::any_of("Time_interval"),
        `Measure quality` = dplyr::any_of("Quality_of_measure")
      ) %>%
      dplyr::relocate(`Female participants (%)`, .after = `Mean age`) %>%
      dplyr::relocate(`Correlation r`, .after = `Association measure`) %>%
      dplyr::mutate(
        dplyr::across(
          where(is.character),
          ~ dplyr::if_else(
            is.na(.x) | .x %in% c("", "(Missing)", "Missing"),
            "Not reported",
            .x
          )
        )
      ) %>%
      dplyr::arrange(.data$`Paper title`, .data$Country)

    DT::datatable(
      out,
      rownames = FALSE,
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        scrollCollapse = TRUE,
        autoWidth = TRUE,
        dom = "frtip"
      ),
      callback = top_scroll_callback
    ) %>%
      DT::formatRound(columns = intersect("Sample size", names(out)), digits = 0, mark = ",") %>%
      DT::formatRound(columns = intersect(c(
        "Mean age", "Female participants (%)", "Correlation r"
      ), names(out)), digits = 2)
  })

}
