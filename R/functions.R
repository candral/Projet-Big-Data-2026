library(dplyr)
library(stringr)
library(sf)

# Harmonisation utilisateurs
clean_users <- function(data) {
  data %>%
    mutate(created_user = case_when(
      created_user == "Edouard Cauchon" ~ "edouard.cauchon",
      created_user == "Thibaut DELAIRE" ~ "thibaut.delaire",
      TRUE ~ created_user
    ))
}

# Conversion coordonnées
convert_coords <- function(data) {
  data_sf <- data %>%
    filter(!is.na(X), !is.na(Y)) %>%
    st_as_sf(coords = c("X", "Y"), crs = 3949) %>%
    st_transform(crs = 4326)
  
  coords <- st_coordinates(data_sf)
  data_sf$long <- coords[, 1]
  data_sf$lat <- coords[, 2]
  
  return(as.data.frame(data_sf) %>%
           select(-geometry))
}

# Nettoyage colonne src_geo
clean_src_geo <- function(data) {
  data %>%
    mutate(src_geo = case_when(
      is.na(src_geo) | src_geo == "" ~ "à renseigner",
      str_detect(tolower(src_geo), "ortho") ~ "Orthophoto",
      TRUE ~ src_geo
    ))
}