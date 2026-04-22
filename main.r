library(sf)
library(dplyr)
library(stringr)

source("R/functions.R")

df <- read.csv("data/Patrimoine_Arboré_data.csv")

df_final <- df %>%
  remove_columns() %>%
  clean_areas() %>%
  clean_pied() %>%
  convert_coords() %>%
  clean_fk_stadedev() %>%
  clean_age() %>%
  impute_precision() %>%
  clean_remarquable() %>%
  nettoyage_colonnes() %>%
  mutate(
    haut_tronc = haut_tronc * 100,
    haut_tot = haut_tot * 100
  )

for (col in c("haut_tot", "haut_tronc", "tronc_diam")) {
  df_final <- remplir_valeurs(df_final, col)
}

write.csv(df_final, "data/Patrimoine_Arbore_Nettoye.csv", row.names = FALSE)
