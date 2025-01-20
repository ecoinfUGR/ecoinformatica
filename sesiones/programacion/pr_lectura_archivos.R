library(tidyverse)

my_path <- "assets/ext_data/nbr_lanjaron_micro/"

files <- list.files(path = my_path,
                    pattern = "*.csv",
                    full.names = TRUE)
files

# Init a list to store the data
all_data <- vector(mode = "list", length = length(files))


for (i in seq_along(files)) {
  # get file
  f <- read_csv(file = files[i])

  # get name of the file
  site_nbr <- str_remove(string = basename(files[1]), pattern = ".csv")
  site <- str_remove(site_nbr, pattern = "nbr_")

  # add name site
  f$site <- site

  # Store data in the list
  all_data[[i]] <- f
  }

# Combine data
nbr <-dplyr::bind_rows(all_data)


