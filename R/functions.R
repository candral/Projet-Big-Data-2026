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