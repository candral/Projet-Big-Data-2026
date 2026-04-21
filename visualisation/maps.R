#install.packages("tidyverse")
#install.packages("leaflet")

library(tidyverse)
library(sf)

df <- read.csv("data/Patrimoine_Arbore_Nettoye.csv", stringsAsFactors = FALSE)

df_clean <- df %>% filter(!is.na(long) & !is.na(lat))

# Conversion en objet spatial (SF)
# On utilise le code EPSG 4326 pour les coordonnées GPS standards
df_sf <- st_as_sf(df_clean, coords = c("long", "lat"), crs = 4326)

ggplot(data = df_sf) +
  geom_sf(aes(color = clc_quartier), size = 0.5) +
  guides(color = guide_legend(override.aes = list(size = 4))) + 
  theme_minimal() +
  labs(title = "Répartition par quartier")

library(leaflet)

leaflet(df_clean) %>%
  addTiles() %>%
  addCircleMarkers(
    lng = ~long, lat = ~lat,
    clusterOptions = markerClusterOptions(spiderfyOnMaxZoom = TRUE), # Éclate les points proches au clic
    popup = ~paste("<strong>Feuillage :</strong>", feuillage, "<br><strong>Age :</strong>", age_estim)
  )