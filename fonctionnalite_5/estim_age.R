library(sf)
library(dplyr)
library(stringr)


df <- read.csv("data/Patrimoine_Arbore_Nettoye.csv")

# Création du modèle
modele_arbre <- lm(age_estim ~ tronc_diam, data = df)

# Affichage des résultats
summary(modele_arbre)