## Create input data for MTurk
library("tidyverse")

## Extract file names
train_bar <- grep("bar_TEST", list.files("./experiment_app/static/images/"), value = TRUE)
train_area <- grep("area_TEST", list.files("./experiment_app/static/images/"), value = TRUE)
task <- list.files("./experiment_app/static/images/")[-grep("TEST", list.files("./experiment_app/static/images/"))]
task_bar <- grep("bar", task, value = TRUE)
task_area <- grep("area", task, value = TRUE)

## Create tibble
dat <- tibble(train = c(rep(train_area, length.out = length(task_area)),
                        rep(train_bar, length.out = length(task_bar))),
              task = c(task_area, task_bar)) %>%
  mutate_all(function(x) paste0("charts/", x))

## Export TSV
write.table(dat, file = "../aws-mturk-clt-1.3.3/samples/stacked_area/external_hit.input",
            sep = "\t", row.names = FALSE, quote = FALSE)
