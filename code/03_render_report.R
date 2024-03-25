here::i_am("code/03_render_report.R")

rmarkdown::render(
  here::here("final_report.Rmd"),
  knit_root_dir = here::here()
)