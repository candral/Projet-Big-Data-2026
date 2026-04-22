library(tidyverse)
library(sf)


df <- read.csv("data/Patrimoine_Arbore_Nettoye.csv", stringsAsFactors = FALSE)


# On sélectionne les variables numériques relatives à l'arbre
vars_num <- df[, c("age_estim", "haut_tot", "tronc_diam", "haut_tronc")]

# Matrice de corrélation
cor_matrix <- cor(vars_num, use = "complete.obs")
print(cor_matrix)
library(corrplot)
corrplot(cor_matrix, method="color", )

# Analyses bivariées

# 1 : Age et diamètre du tronc de l'arbre
# Graphique de corrélation entre l'âge et le diamètre du tronc de l'arbre
ggplot(df, aes(x = tronc_diam, y = age_estim)) +
  geom_point(alpha = 0.5, color = "darkgreen") +
  geom_smooth(method = "lm", col = "red") + # Ajoute une ligne de tendance
  labs(title = "Lien entre le diamètre du tronc et l'âge estimé",
       x = "Diamètre du tronc (cm)", y = "Âge estimé (années)")

# 2 : Age et hauteur totale de l'arbre
ggplot(df, aes(x = haut_tot, y = age_estim)) +
  geom_point(alpha = 0.5, color = "darkgreen") +
  geom_smooth(method = "lm", col = "red") + # Ajoute une ligne de tendance
  labs(title = "Lien entre la hauteur et l'âge estimé",
       x = "Hauteur totale (cm)", y = "Âge estimé (années)")

# 3 : Age et caractère remarquable de l'arbre
ggplot(df, aes(x = remarquable, y = age_estim, fill=remarquable)) +
  geom_boxplot() +
  labs(title = "Distribution de l'âge selon le caractère remarquable de l'arbre",
       x = "Est remarquable", y = "Âge estimé (années)")
aggregate(age_estim ~remarquable, data = df, 
          FUN = function(x) c(moyenne = mean(x), ecart_type=sd(x)))
#Test de Student
t.test(age_estim ~remarquable, data = df)


#Relations entre variables qualitatives
#MOSAIC PLOTS

# Créer un vecteur de couleurs personnalisées pour chaque catégorie
couleurs <- c("green", "blue", "red", "orange")

# 1 : Lien entre l'âge et remarquable
# Créer le tableau croisé
tableau <- table(df$fk_stadedev, df$remarquable)
print(tableau)

# Faire le test du Chi-2
test <- chisq.test(tableau)
print(test)

# Le Mosaic Plot
library(vcd)
mosaicplot(tableau,
           main = "Lien entre stade de développement et remarquable", xlab="stade dev", ylab="remarquable", color= couleurs, las=2)
