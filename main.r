library(sf)
library(dplyr)
library(stringr)

source("R/functions.R")

df <- read.csv("data/Patrimoine_Arboré_data.csv")

df_final <- df %>%
  clean_users() %>%
  convert_coords() %>%
  clean_src_geo() %>%
  clean_fk_stadedev()

write.csv(df_final, "data/Patrimoine_Arbore_Nettoye.csv", row.names = FALSE)
