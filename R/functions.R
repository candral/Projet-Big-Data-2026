library(dplyr)
library(stringr)
library(sf)

# Suppression des colonnes inutiles pour l'étude
remove_columns <- function(data) {
  columns_to_remove = c("OBJECTID", "created_date", "created_user", "src_geo", "id_arbre", "commentaire_environnement", "clc_nbr_diag", "last_edited_user", "last_edited_date", "nomfrancais", "nomlatin", "GlobalID", "CreationDate", "Creator", "EditDate", "Editor")
  data %>%
    select(-all_of(columns_to_remove))
}

# Nettoyage des colonnes de quartier et secteur
clean_areas <- function(data) {
  
  # 1 : Nettoyage (supprimer espaces et corriger)
  data <- data %>%
    mutate(
      clc_secteur = str_trim(clc_secteur),
      clc_quartier = str_trim(clc_quartier),
      clc_secteur = ifelse(clc_secteur == "Griourt", "Gricourt", clc_secteur),
      clc_secteur = ifelse(clc_secteur == "square des marronniers", "Square des Marronniers", clc_secteur),
      # 2 : On gère les quartiers vides
      clc_quartier = case_when(
        # Si le quartier n'est pas vide, on le garde
        !is.na(clc_quartier) & clc_quartier != "" ~ clc_quartier,
        
        # Si le quartier est vide mais que le secteur existe, on recopie le secteur
        !is.na(clc_secteur) & clc_secteur != "" ~ clc_secteur,
        
        # Si les deux sont vides on remplace par "Non Renseigné"
        TRUE ~ "Non Renseigné"
      ),
      clc_secteur = case_when(
        is.na(clc_secteur) | clc_secteur == "" ~ "Non Renseigné",
        TRUE ~ clc_secteur
      )
    )
}

clean_pied <- function(data) {
  data <- data %>%
    mutate(
      fk_pied = case_when(
        str_to_lower(fk_pied) %in% c("bande de terre", "fosse arbre", "terre", "gazon") ~ "Pleine terre",
        TRUE ~ fk_pied 
      )
    )
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
    mutate(age_estim = case_when(
      age_estim <= 0    ~ NA_real_,  # On remplace le 0 ou négatif par NA
      age_estim == 2010 ~ NA_real_,  # On traite le 2010 comme une valeur manquante
      TRUE              ~ as.numeric(age_estim)
    ))
  
  
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

nettoyage_colonnes <- function(data) {
  # Liste des colonnes à traiter
  cols_to_fix <- c(
    "fk_arb_etat", "fk_port", "fk_pied", "fk_situation", 
    "fk_revetement", "dte_plantation", "dte_abattage", 
    "fk_nomtech", "villeca", "feuillage"
  )
  
  data %>%
    mutate(across(all_of(cols_to_fix), ~ {
      # On convertit en caractère, on enlève les espaces vides
      val <- as.character(.)
      ifelse(is.na(val) | str_trim(val) == "", "Non renseigné", val)
    }))
}

clean_remarquable <- function(data) {
  data %>%
    mutate(remarquable = case_when(
      is.na(remarquable) ~ "Non",
      str_trim(remarquable) == "" ~ "Non",
      TRUE ~ as.character(remarquable)
    ))
}

# Imputation de la précision (fk_prec_estim)
impute_precision <- function(data) {
  
  # Calcul de la médiane globale
  mediane_globale <- median(data$fk_prec_estim, na.rm = TRUE)
  
  data %>%
    mutate(
      # On traite les 0 suspects (> 5 ans) comme des NA pour ne pas fausser la médiane
      fk_prec_estim_clean = ifelse(fk_prec_estim == 0 & age_estim > 5, NA, fk_prec_estim)
    ) %>%
    group_by(fk_nomtech) %>%
    mutate(
      mediane_espece = median(fk_prec_estim_clean, na.rm = TRUE)
    ) %>%
    ungroup() %>%
    mutate(
      fk_prec_estim = case_when(
        !is.na(fk_prec_estim_clean) ~ fk_prec_estim_clean,
        !is.na(mediane_espece) ~ mediane_espece,
        TRUE ~ mediane_globale
      )
    ) %>%
    select(-fk_prec_estim_clean, -mediane_espece)
}