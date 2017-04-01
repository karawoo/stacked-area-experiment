#############################################
####  Figures to be used for experiment  ####
#############################################

## Load required packages
library("tidyverse")

###########################
####  Data generation  ####
###########################

## Generate charts using the proportions in Cleveland & McGill 1984 (see fig. 11
## in that paper; several proportions were repeated in their study but I'll just
## use each one once).

## Proportions used in Cleveland & McGill 1984:
cm <- c(0.825, 0.681, 0.562, 0.464, 0.383, 0.261, 0.178)

## An issue here is that I want to use fixed coordinates so that the angles of
## the segments are consistent. I also want to keep the plots at a reasonable
## aspect ratio (ideally 1.618, but there's no way I can be that precise and I
## will settle for something roughly in the ballpark). Let's say I have 10 x
## values, then the max height of the chart should be ~6. Then the point of
## comparison in the chart should be no more than 5, since the chart will need
## to be higher on one side. In the past, I kept one segment a set size and
## varied the other in proportion to it, but that led to chart heights that were
## too variable. So instead I'll try fixing the total height and dividing the
## segments so they end up in the right proportion.

## Function to split a given value into two segments where the smaller is a
## given proportion of the larger
get_ab <- function(total, prop, which_larger = c("A", "B")) {
  ## Split total into two values where the smaller is `prop` proportion of the
  ## larger
  smaller <- total * ((prop * 1000) / ((prop * 1000) + 1000))
  larger <- total - smaller

  ## If A should be larger than B, return larger first
  if (which_larger == "A") {
    return(c(larger, smaller))
    ## Otherwise, return smaller first
  } else if (which_larger == "B") {
    return(c(smaller, larger))
  }
}

## Set seed for reproducibility
set.seed(8291) 

## Total height. 8 is min so that smaller segment (which has a y value of 1.2)
## still has room to decrease on one side
y <- 8                                  

## Max x value 
max_x <- 14

## Range of x values that are possible points of comparison. Shouldn't be at the
## far edges of the chart, but can vary a bit within the middle.
xrange <- 3:11

## For each ratio, create two tibbles of data. Each tibble has two observations,
## "A", and "B". The first tibble has the larger segment on the bottom, the
## second has the larger segment on the top.
data_pairs <- map(cm, function(cm) {
  datalist <- list(data.frame(var = c("A", "B"),
                              x = sample(xrange, size = 1),
                              y = get_ab(total = y, prop = cm,
                                         which_larger = "A"),
                              ## So we know this is the x value to mark on the
                              ## chart:
                              obs = TRUE,
                              stringsAsFactors = FALSE),
                   data.frame(var = c("A", "B"),
                              x = sample(xrange, size = 1),
                              y = get_ab(total = y, prop = cm,
                                         which_larger = "B"),
                              obs = TRUE,
                              stringsAsFactors = FALSE))

  ## Name the elements of the list
  names(datalist) <- c(paste0(cm, "_A"), paste0(cm, "_B"))
  return(datalist)
})

## Partially unlist so this is a list of data frames instead of a list of lists
## of data frames
data_pairs <- unlist(data_pairs, recursive = FALSE)

## Function to generate a single data set
generate_data <- function(input, seed, max_x = 14,
                          chart_shape = c("increasing", "decreasing")) {
  set.seed(seed)
  
  ## Points of comparison
  x <- input[input$var == "A", "x"]
  a_val <- input[input$var == "A", "y"]
  b_val <- input[input$var == "B", "y"]

  ## Values of a that will appear on either side of the point of comparison
  if (chart_shape == "increasing") {
    left_a <- a_val - 1
    right_a <- a_val + 1
  } else if (chart_shape == "decreasing") {
    left_a <- a_val + 1
    right_a <- a_val - 1
  }

  ## B values somewhat close to b_val. B should be increasing linearly here, so
  ## we'll subtract and add the same amount on either side, being careful not to
  ## take the total below 0
  b_variation <- abs(rnorm(1, mean = b_val / 20, sd = 0.1))
  if (b_val - b_variation <= 0) {
    b_variation <- 0.1
  }

  ## If chart shape is increasing, the element of leftright_b should be less
  ## than b_val and the second should be larger; the opposite is true if chart
  ## shape is decreasing
  if (chart_shape == "increasing") {
    leftright_b <- c(b_val - b_variation, b_val + b_variation)
  } else if (chart_shape == "decreasing") {
    leftright_b <- c(b_val + b_variation, b_val - b_variation)
  }
  
  ## Create data frame of left and right values
  set.seed(seed)
  leftright <- tibble(var = rep(c("A", "B"), 2),
                      x = rep(c(x - 1, x + 1), each = 2),
                      y = c(left_a, leftright_b[1], right_a, leftright_b[2]),
                      obs = FALSE)

  ## Combine left and right side with input to create the "middle chunk" of data
  ## for the chart
  middle_chunk <- bind_rows(input, leftright) %>%
    arrange(x)

  ## Generate random data for the rest of the chart. Must be positive since
  ## stacked area charts don't make sense with negative values
  rest_of_data <- tibble(var = rep(c("A", "B"), each = max_x - 2),
                         x = rep(setdiff(0:max_x, unique(middle_chunk$x)),
                                 times = 2),
                         y = c(abs(rnorm(n = max_x - 2, mean = a_val,
                                         sd = 0.5)),
                               abs(rnorm(n = max_x - 2, mean = b_val,
                                         sd = 0.5))),
                         obs = FALSE)

  ## Combine the datasets and arrange in order of x
  bind_rows(middle_chunk, rest_of_data) %>%
    arrange(x)
}

## Generate data for chart_shape == "increasing"
increasing_seed <- c(21154, 49274, 12447, 42966, 6895, 38916, 41514, 48176,
                     12302, 36175, 46890, 55201, 55685, 16262)

increasing_data <- map2(data_pairs, increasing_seed, .f = generate_data,
                        max_x = max_x, chart_shape = "increasing")

## Generate data for chart_shape == "decreasing"
decreasing_seed <- c(69155, 17083, 54629, 26097, 29167, 27723, 10023, 53153,
                     47910, 5496, 13438, 14596, 62658, 1178)

decreasing_data <- map2(data_pairs, increasing_seed, .f = generate_data,
                        max_x = max_x, chart_shape = "decreasing")

## Rename list elements to include "increasing" or "decreasing"
names(increasing_data) <- paste0("increasing_", names(increasing_data))
names(decreasing_data) <- paste0("decreasing_", names(decreasing_data))

##############################
####  Plotting functions  ####
##############################

## Custom, minimal ggplot theme
custom_theme <- theme_set(theme_bw())
custom_theme <- theme_update(plot.background = element_blank(),
                             panel.grid.major = element_blank(),
                             panel.grid.minor = element_blank(),
                             legend.position = "none"
                             )

## Function to generate and save a plot
generate_plot <- function(data, name, max_x) {
  ## Reorder var as a factor, otherwise A will be on top
  data$var <- factor(data$var, levels = c("B", "A"))
  
  ## Coordinates for annotating the plot
  comp_point <- unique(data[data$obs == TRUE,][["x"]])
  
  acoord <- data[data$x == comp_point & data$var == "A", "y"] / 2
  bcoord <- data[data$x == comp_point & data$var == "A", "y"] +
    (data[data$x == comp_point & data$var == "B", "y"] / 2)

  ## Create plot
  p <- ggplot(data, aes(x = x, y = y, group = var, fill = var)) +
    geom_area(position = "stack") +
    scale_x_continuous(breaks = 0:max_x) +
    scale_fill_brewer(palette = "Set2") +
    annotate("text", x = comp_point, y = acoord, label = "A") +
    annotate("text", x = comp_point, y = bcoord, label = "B") +
    coord_fixed()

  ## Save output
  ggsave(paste0("stacked_area_", name, ".png"), p,
         path = "experiment_app/static/images",
         width = 6, height = 4)
  
}

## Generate and save plots for all the data
walk2(.x = increasing_data, .y = names(increasing_data), .f = generate_plot,
      max_x = max_x)
walk2(.x = decreasing_data, .y = names(decreasing_data), .f = generate_plot,
      max_x = max_x)

######################
####  Bar charts  ####
######################

## Use some of the generated to data to create bar charts. Keep the point of
## comparison plus one other random row.
bar_data <- map(increasing_data, function(dat) {
  pcomp <- unique(dat[dat$obs == TRUE, "x"])
  indices <- c(pcomp, sample(setdiff(0:max_x, pcomp), size = 1))
  filter(dat, x %in% indices)
})

## Remove "increasing" from names of bar data since there's no increasing vs.
## decreasing for the bar charts
names(bar_data) <- gsub("increasing_", "", names(bar_data))

## Generate stacked bar charts
walk2(bar_data, names(bar_data), function(dat, name) {
  ## Reorder factor levels
  dat$var <- factor(dat$var, levels = c("B", "A"))

  ## Calculate coordinates where marks will be placed
  pcomp <- unique(dat[dat$obs == TRUE, "x"])
  acoord <- dat[dat$obs == TRUE & dat$var == "A", "y"] / 2
  bcoord <- dat[dat$obs == TRUE & dat$var == "A", "y"] +
    (dat[dat$obs == TRUE & dat$var == "B", "y"] / 2)

  ## Plot
  ggplot(dat, aes(x = x, y = y, group = var, fill = var)) +
    geom_bar(stat = "identity") +
    scale_x_continuous(labels = NULL) +
    scale_fill_brewer(palette = "Set2") +
    annotate("text", x = pcomp, y = acoord, label = "A") +
    annotate("text", x = pcomp, y = bcoord, label = "B") +
    ggsave(paste0("stacked_bar_", name, ".png"),
           path = "experiment_app/static/images",
           width = 3, height = 5)
})

########################################
####  Obvious charts for screening  ####
########################################

## Function to create screening charts where the answer to which segment is
## smaller is very obvious. For these, the point of comparison will always be at
## x == 5 (for simplicity) and the x axis goes to 10.
screening <- function(seed, type) {
  ## Create data set
  set.seed(seed)
  dat <- data.frame(x = rep(c(0:10), 2),
                    var = rep(c("A", "B"), each = 11),
                    y = c(sample(8:10, size = 11, replace = TRUE),
                          sample(1:2, size = 11, replace = TRUE)),
                    stringsAsFactors = FALSE)

  dat <- dat %>%
    arrange(x) %>%
    ## Make sure ratio is 10:1.3 at point of interest
    mutate(y = ifelse(x == 5 & var == "A", 10, y)) %>%
    mutate(y = ifelse(x == 5 & var == "B", 1.3, y))

  if (type == "bar") {
    set.seed(seed)
    ## Choose the x == 5 and one other row either before or after that row for
    ## bar charts
    dat <- dplyr::filter(dat, x == 5 | x == sample(c(4, 6), size = 1))
  }

  ## Coordinates for labels
  center <- dat[dat$x == 5, ]
  acoord <- dat[dat$x == 5 & dat$var == "A", "y"] / 2
  bcoord <- dat[dat$x == 5 & dat$var == "A", "y"] +
    (dat[dat$x == 5 & dat$var == "B", "y"] / 2)

  ## Reorder var factor levels
  dat$var <- factor(dat$var, levels = c("B", "A"))

  if (type == "stacked") {
    ## Annoted stacked area chart
    ggplot(dat, aes(x = x, y = y, group = var, fill = var)) +
      geom_area(position = "stack") +
      scale_fill_brewer(palette = "Set2") +
      scale_x_continuous(breaks = 1:10) +
      annotate("segment", x = 5, xend = 5, y = 0, yend = 4.8,
               color = "red") +
      annotate("segment", x = 5, xend = 5, y = 5.3, yend = 9.97,
               color = "red") +
      annotate("segment", x = 5, xend = 5, y = 10.02, yend = 10.4,
               color = "blue") +
      annotate("segment", x = 5, xend = 5, y = 10.9, yend = 11.3,
               color = "blue") +
      annotate("text", x = 5, y = acoord, label = "A") +
      annotate("text", x = 5, y = bcoord, label = "B")
    ggsave(paste0("stacked_area_TEST_", seed, ".png"),
           path = "experiment_app/static/images",
           width = 6, height = 4)   
  } else if (type == "bar") {
    ggplot(dat, aes(x = x, y = y, group = var, fill = var)) +
      geom_bar(stat = "identity") +
      scale_fill_brewer(palette = "Set2") +
      scale_x_continuous(labels = NULL) +
      annotate("segment", x = 5, xend = 5, y = 0, yend = 4.8,
               color = "red") +
      annotate("segment", x = 5, xend = 5, y = 5.2, yend = 9.97,
               color = "red") +
      annotate("segment", x = 5, xend = 5, y = 10.02, yend = 10.5,
               color = "blue") +
      annotate("segment", x = 5, xend = 5, y = 10.8, yend = 11.3,
               color = "blue") +
      annotate("text", x = 5, y = acoord, label = "A") +
      annotate("text", x = 5, y = bcoord, label = "B")
      ggsave(paste0("stacked_bar_TEST_", seed, ".png"),
             path = "experiment_app/static/images",
             width = 3, height = 6)
  }
}

## Create 5 stacked area charts using 1, 2, 3, 4, 5 as seeds
sapply(1:5, screening, type = "stacked")

## Create 5 stacked bar charts using 1, 2, 3, 4, 5 as seeds
sapply(1:5, screening, type = "bar")

###################################
####  Export data of interest  ####
###################################

## Convert data pairs into a data frame
data_pairs_df <- dplyr::bind_rows(data_pairs, .id = "name") %>%
  ## Add column containing which segment is smallest
  mutate(smaller_var = ifelse(grepl("_A$", name), "B", "A")) %>%
  ## Remove "obs" column
  select(-obs)

## Export to csv
## write.csv(data_pairs_df, "correct_answers.csv", row.names = FALSE)
