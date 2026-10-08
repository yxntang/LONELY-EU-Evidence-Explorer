# To launch the app manually, use shiny::runApp("lonely_eu_dma_app")
# or the Run App button in RStudio.

library(shiny)
library(dplyr)
library(DT)
library(ggplot2)
library(glue)
library(plotly)
library(purrr)
library(shinycssloaders)
library(shinyjs)
library(shinythemes)
library(shinyWidgets)
library(stringr)
library(tibble)

f <- if (file.exists("server.R")) {
  "."
} else if (file.exists(file.path("lonely_eu_dma_app", "server.R"))) {
  "lonely_eu_dma_app"
} else {
  stop("Cannot find server.R. Please run the app from the lonely_eu_dma_app folder.")
}

source(file.path(f, "helpers.R"))
source(file.path(f, "app_config.R"))

server <- source(file.path(f, "server.R")) %>% purrr::pluck("value")
ui <- source(file.path(f, "ui.R")) %>% purrr::pluck("value")

metaUI_eff_size_type_label <- "Fisher's z-transformed correlations"
metaUI__df <- readRDS(file.path(f, "dataset.rds"))

loneliness_levels_file <- file.path(f, "loneliness_levels.rds")
loneliness_levels_df <- if (file.exists(loneliness_levels_file)) {
  readRDS(loneliness_levels_file)
} else {
  metaUI__df
}
