models_to_run <- tibble::tribble(
  ~name,                    ~aggregated, ~es,        ~LCL,         ~UCL,        ~k,
  "Main evidence summary",  FALSE,       "mod$b",    "mod$ci.lb",  "mod$ci.ub", "mod$k"
)

models_code <- tibble::tribble(
  ~name,                    ~code,
  "Main evidence summary",  "metafor::rma.mv(
    yi = metaUI__effect_size,
    V = metaUI__variance,
    random = ~ 1 | metaUI__study_id/metaUI__effect_size,
    tdist = TRUE,
    data = df,
    method = \"REML\",
    sparse = TRUE
  )"
)

# KEEP THIS AS THE **LAST** LINE! Helper functions etc must be added above.
models_to_run <- models_to_run %>% dplyr::left_join(models_code, by = "name")
models_to_run
