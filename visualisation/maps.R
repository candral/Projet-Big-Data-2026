#install.packages("tidyverse")
#install.packages("leaflet")

library(tidyverse)
library(sf)

df <- read.csv("data/Patrimoine_Arbore_Nettoye.csv", stringsAsFactors = FALSE)

df_clean <- df %>% filter(!is.na(long) & !is.na(lat))

# Conversion en objet spatial (SF)
# On utilise le code EPSG 4326 pour les coordonnées GPS standards
df_sf <- st_as_sf(df_clean, coords = c("long", "lat"), crs = 4326)

# Calculer les statistiques
stats_quartier <- df_clean %>%
  group_by(clc_quartier) %>%
  summarise(nb_arbres = n()) %>%
  ungroup()

# Filtrer pour ne garder que les quartiers significatifs (> 100 arbres)
# et exclure les données non renseignées
quartiers_a_garder <- stats_quartier %>%
  filter(nb_arbres >= 100, 
         clc_quartier != "Non Renseigné") %>%
  pull(clc_quartier)

# Créer le dataset filtré
df_sf_filtre <- df_sf %>%
  filter(clc_quartier %in% quartiers_a_garder)

# Afficher la carte avec le nombre d'arbres dans la légende
df_sf_filtre <- df_sf_filtre %>%
  left_join(stats_quartier, by = "clc_quartier") %>%
  mutate(quartier_label = paste0(clc_quartier, " (", nb_arbres, ")"))

ggplot(data = df_sf_filtre) +
  geom_sf(aes(color = quartier_label), size = 0.6, alpha = 0.7) +
  theme_minimal() +
  labs(
    title = "Répartition des arbres par quartiers principaux",
    subtitle = "Affichage des secteurs possédant plus de 100 arbres",
    color = "Quartier (Total d'arbres)"
  ) +
  theme(
    legend.text = element_text(size = 9),
    panel.grid.major = element_line(color = "#ebebeb")
  ) +
  guides(color = guide_legend(override.aes = list(size = 3)))

library(leaflet)

leaflet(df_clean) %>%
  addTiles() %>%
  addCircleMarkers(
    lng = ~long, lat = ~lat,
    clusterOptions = markerClusterOptions(spiderfyOnMaxZoom = TRUE), # Éclate les points proches au clic
    popup = ~paste("<strong>Feuillage :</strong>", feuillage, "<br><strong>Age :</strong>", age_estim)
  )


# Filtrage des arbres remarquables
# Calcul de la répartition par quartier pour les arbres remarquables
stats_remarquables <- arbres_remarquables %>%
  group_by(clc_quartier) %>%
  summarise(nb_remarquables = n()) %>%
  arrange(desc(nb_remarquables))

leaflet(arbres_remarquables) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(
    lng = ~long, lat = ~lat,
    color = "red", 
    radius = 6,
    label = ~paste(clc_quartier)
  )