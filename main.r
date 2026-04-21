library(sf)
library(dplyr)
library(stringr)

source("R/functions.R")

df <- read.csv("data/Patrimoine_Arboré_data.csv")

df_final <- df %>%
  clean_users()