

library(forestables)
library(tidyverse)
ifn_folder <- 'assets/ext_data/ifn/'


sn_provinces <- c("04","18")

ifn_plots <- show_plots_from(
  "IFN",
  folder = ifn_folder,
  provinces = sn_provinces, versions = "ifn3"
)

# Descargar datos Sierra Nevada (límite)

# World Database on Protected Areas (WDPA)
# install.packages("wdpar")
library(wdpar)
# download protected area data from Spain
# spain <- wdpa_fetch("Spain", wait = TRUE,
#                     download_dir = rappdirs::user_data_dir("wdpar"))
#
# sn <- spain |>
#   dplyr::filter(NAME == "Sierra Nevada" & WDPAID == "555588878")
# st_write(sn, 'assets/ext_data/geoinfo/sn_wdpa.shp')


ggplot(ifn_plots) +
  geom_sf(
    aes(color = province_name_original), alpha = 0.4,
    show.legend = FALSE
  ) +
  scale_color_manual(values = hcl.colors(9, palette = "Zissou 1")) +
  # add geom_sf for the protected areas
  geom_sf(data = sn, fill = "transparent", color = "black")


sn_plots <- ifn_plots |>
  st_filter(sn)


ggplot() +
  # add geom_sf for the protected areas
  geom_sf(data = sn, fill = "transparent", color = "black") +
  geom_sf(
    data = sn_plots,
    show.legend = FALSE
  )

library(future)
plan("multisession", workers = 4)

ifn_data <- ifn_to_tibble(
  provinces = sn_provinces,
  versions = "ifn3",
  filter_list = sn_plots,
  folder = ifn_folder
)

sn_tree <- ifn_data |>
  inventory_as_sf() |>
  clean_empty("tree") |>
  unnest("tree", names_sep = "_")


  # unnest the tree data
  unnest("tree")
