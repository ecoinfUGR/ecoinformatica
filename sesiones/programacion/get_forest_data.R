

library(forestables)
library(tidyverse)
library(sf)
ifn_folder <- 'assets/ext_data/ifn/'


sn_provinces <- c("04","18")

ifn_plots <- show_plots_from(
  "IFN",
  folder = ifn_folder,
  provinces = sn_provinces, versions = "ifn3"
)


prov_ifn3 <- c("04","18")
prov_ifn4 <- c("30")



show_plots_from(
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
sn <- st_read('assets/ext_data/geoinfo/sn_wdpa.shp')

ggplot(ifn_plots) +
  geom_sf(
    aes(color = province_name_original), alpha = 0.4,
    show.legend = FALSE
  ) +
  scale_color_manual(values = hcl.colors(9, palette = "Zissou 1")) +
  # add geom_sf for the protected areas
  geom_sf(data = sn, fill = "transparent", color = "black")


sn_plots_geo <- ifn_plots |>
  st_filter(sn) |>
  st_transform(crs = 23030)

# sn_ifn_csv <- sn_plots_geo |>
#   st_coordinates() |>
#   as.data.frame() |>
#   rename(x = X, y = Y) |>
#   bind_cols(sn_plots_geo) |>
#   st_drop_geometry() |>
#   dplyr::select(-geometry)
#
# write_csv(sn_ifn_csv, here("assets/ext_data/ifn_sn_geo.csv"))
#
#



sn_plots <- ifn_plots |>
  st_filter(sn) |>
  st_transform(crs = 23030) |>  create_filter_list()

sn_plots <- st_drop_geometry(sn_plots)

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

sn_tree_raw <- sn_tree |>
  dplyr::rename(prov = province_name_original,
                specie = tree_sp_name,
                tree_id = tree_tree_id,
                dbh = tree_dbh,
                height = tree_height) |>
  dplyr::select(-crs, -version, -province_code, -country,
                -coord_sys_orig, -ca_name_original,
                -sheet_ntm, -crs_orig, -regen, -understory,
                -huso, -type, -tree_cubing_form, -tree_tree_ifn2, -tree_tree_ifn3,
                -tree_sp_code, -class, -subclass, -year, -id_unique_code) |>
  dplyr::relocate(prov, .after = "tree_quality_wood") |>
  dplyr::relocate(tree_density_factor, .before = "tree_quality_wood") |>
  st_drop_geometry()

write_csv(sn_tree_raw, file= "assets/ext_data/ifn_sn_tree.csv")

