library(tidyverse)
library(lubridate)
df <- read.csv("data/Patrimoine_Arbore_Nettoye.csv", na.strings = c("", "NA"))

# Conversion des colonnes de dates (format YYYY/MM/DD)
df$dte_plantation <- ymd_hms(df$dte_plantation)

# Conversion des variables qualitatives en facteurs
qualitative_vars <- c("fk_arb_etat", "fk_stadedev", "fk_port", "clc_quartier", "feuillage", "remarquable")
df[qualitative_vars] <- lapply(df[qualitative_vars], as.factor)

# Statistiques descriptives (Moyennes et Écarts-types)

stats_quantitatives <- df %>%
  select(haut_tot, haut_tronc, tronc_diam, age_estim) %>%
  summarise(across(everything(), list(
    moyenne = ~mean(., na.rm = TRUE),
    ecart_type = ~sd(., na.rm = TRUE)
  )))

print(stats_quantitatives)

# Histogramme de la distribution de la hauteur totale des arbres
plot_hist <- ggplot(df, aes(x = haut_tot)) +
  geom_histogram(binwidth = 100, fill = "#2e7d32", color = "white") +
  stat_bin(binwidth = 100, geom = "text", aes(label = after_stat(count)), 
           vjust = -0.5, size = 3) +
  labs(title = "Distribution de la hauteur totale des arbres",
       x = "Hauteur totale (cm)",
       y = "Nombre d'arbres") +
  theme_minimal()

ggsave("assets/distribution_hauteur.png", plot = plot_hist, width = 10, height = 6, dpi = 300)

# Camembert sur la Répartition du stade de développement (fk_stadedev)
pie_data <- df %>%
  filter(!is.na(fk_stadedev)) %>%
  count(fk_stadedev) %>%
  mutate(prop = n / sum(n) * 100,
         label = paste0(round(prop, 1), "%")) # Crée le texte du label

plot_pie <- ggplot(pie_data, aes(x = "", y = n, fill = fk_stadedev)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  geom_text(aes(label = label), 
            position = position_stack(vjust = 0.5), # Centre le texte dans les parts
            size = 4) +
  labs(title = "Répartition par stade de développement",
       fill = "Stade") +
  theme_minimal()

ggsave("assets/repartition_stade_developpement.png", plot = plot_pie, width = 8, height = 8, dpi = 300)

# Diagramme en barres
bar_data <- df %>%
  filter(!is.na(clc_quartier)) %>%
  count(clc_quartier)

plot_bar <- ggplot(bar_data, aes(x = reorder(clc_quartier, n), y = n, fill = clc_quartier)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = n), 
            hjust = -0.2, # Décale le texte juste après la fin de la barre
            size = 3.5) +
  coord_flip() +
  labs(title = "Nombre d'arbres par quartier",
       x = "Quartier",
       y = "Nombre d'arbres") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("assets/arbres_par_quartier.png", plot = plot_bar, width = 10, height = 8, dpi = 300)