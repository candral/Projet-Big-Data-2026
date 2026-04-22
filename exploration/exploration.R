library(tidyverse)
library(lubridate)

df <- read.csv("data/Patrimoine_Arboré_data.csv", na.strings = c("", "NA"))

# Structure et Types des données
str(df)

