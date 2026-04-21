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

# Nettoyage colonne fk_stadedev
clean_fk_stadedev <- function(data) {
  data %>%
    mutate(fk_stadedev = case_when(
      tolower(fk_stadedev) == "jeune" ~ "Jeune",
      tolower(fk_stadedev) == "adulte" ~ "Adulte",
      tolower(fk_stadedev) %in% c("vieux", "senescent") ~ "Vieux/Sénescent",
      is.na(fk_stadedev) | fk_stadedev == "" | fk_stadedev == " " ~ "Non renseigné",
      TRUE ~ as.character(fk_stadedev)
    ))
}

# Nettoyage et Imputation de l'âge
clean_age <- function(data) {
  # 1. Nettoyage des valeurs aberrantes ou nulles
  data <- data %>%
    mutate(age_estim = ifelse(age_estim <= 0, NA, age_estim))
  
  # Calcul des médianes d'âge par stade de développement (fk_stadedev)
  medians_age_stade <- data %>%
    filter(!is.na(age_estim) & !is.na(fk_stadedev) & fk_stadedev != "Non renseigné") %>%
    group_by(fk_stadedev) %>%
    summarise(mediane_age = round(median(age_estim)), .groups = "drop")
  
  # Calcul de la médiane globale pour le reste
  mediane_globale <- round(median(data$age_estim, na.rm = TRUE))
  
  # 4. Application de l'imputation
  data <- data %>%
    left_join(medians_age_stade, by = "fk_stadedev") %>%
    mutate(age_estim = case_when(
      !is.na(age_estim) ~ age_estim,               # On garde l'existant
      !is.na(mediane_age) ~ mediane_age,           # Priorité au stade de dév (Jeune, Adulte, etc.)
      TRUE ~ mediane_globale                       # Par défaut, médiane globale
    )) %>%
    select(-mediane_age)
  
  return(data)
}

# Imputation données numériques vides
remplir_valeurs <- function(donnees, nom_colonne) {
  
  # Calcul de la moyenne globale (pour les arbres dont l'âge est inconnu)
  moyenne_globale <- round(mean(donnees[[nom_colonne]], na.rm = TRUE), 2)
  
  # Calcul de la médiane par groupe d'âge
  medians_par_age <- donnees %>%
    filter(!is.na(age_estim) & !is.na(.data[[nom_colonne]]) & .data[[nom_colonne]] > 0) %>%
    group_by(age_estim) %>%
    summarise(mediane_groupe = round(median(.data[[nom_colonne]]), 2), .groups = "drop")
  
  # Fusion et remplacement
  donnees <- donnees %>%
    left_join(medians_par_age, by = "age_estim") %>%
    mutate(!!nom_colonne := case_when(
      !is.na(.data[[nom_colonne]]) & .data[[nom_colonne]] > 0 ~ .data[[nom_colonne]], # Garde l'original
      !is.na(mediane_groupe) ~ mediane_groupe,                                       # Priorité Médiane/Âge
      TRUE ~ moyenne_globale                                                         # Sinon Moyenne Globale
    )) %>%
    select(-mediane_groupe) # Supprime la colonne temporaire
  
  return(donnees)
}