# LONELY-EU WP4 Evidence Explorer

This repository contains the ready-to-run source code and processed data for the LONELY-EU WP4 Evidence Explorer.

The live application is available at:
https://yxntang.shinyapps.io/lonely_eu_dma_app_v6/

## Run locally

1. Open the repository as an R project or set it as your working directory.
2. Restore the recorded R package versions:

   ```r
   renv::restore()
   ```

3. Start the app:

   ```r
   shiny::runApp("lonely_eu_dma_app_v6")
   ```

The processed data files are already included in `lonely_eu_dma_app_v6/`:

- `dataset.rds` supports the Socioeconomic Links section.
- `loneliness_levels.rds` supports the Loneliness Levels section.

This collaboration copy does not include the raw coding sheet or data-preparation scripts. Please contact Dr. Yixin Tang (yixin.tang@rub.de) for data questions or for a version that can regenerate the processed data.

## Development transparency

The application code was co-developed with support from OpenAI Codex, an AI coding assistant. The LONELY-EU WP4 research team remains responsible for the data, methodological decisions, interpretation, and approval of all changes.

## Contact

Dr. Yixin Tang  
Ruhr University Bochum  
yixin.tang@rub.de
