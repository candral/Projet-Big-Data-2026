==============================================
   BESOIN 2 : OUTIL DE PRÉDICTION DE L'ÂGE
==============================================

Ce projet utilise un modèle (Random Forest) pour estimer l'âge d'un arbre en fonction de ses dimensions (hauteur totale, hauteur du tronc, diamètre du tronc) et de son espèce.

--- 1. PRÉREQUIS ---

Avant de lancer le script, vous devez avoir Python installé 
ainsi que les bibliothèques suivantes :
- pandas
- numpy
- scikit-learn
- joblib

Pour les installer, ouvrez un terminal et tapez :
pip install pandas numpy scikit-learn joblib

--- 2. STRUCTURE DES DOSSIERS ---

Le projet doit être organisé comme suit pour fonctionner :
.
├── script.py               (Le fichier de prédiction à exécuter)
├── model/
│   ├── meilleur_modele_arbre.pkl   (Le modèle entraîné)
│   └── standard_scaler.pkl         (Le fichier de normalisation)
└── README.txt

--- 3. COMMENT LANCER L'OUTIL ---

1. Ouvrez un terminal ou une invite de commande dans le dossier du projet.
2. Lancez le script avec la commande suivante :
   
   python script.py

3. Suivez les instructions à l'écran :
   - Choisissez le code de l'espèce dans la liste affichée (ex: 3 pour Chêne).
   - Entrez la hauteur totale, la hauteur du tronc et le diamètre. (en cm)

--- 5. TABLE DE CORRESPONDANCE DES ESPÈCES ---

Si vous n'avez pas le script sous les yeux avec la table de correspondance, voici les codes :
[0] : Autres    [1] : Bouleau   [2] : Charme    [3] : Chêne
[4] : Hêtre   	[5] : Pin    	[6] : Platane       [7] : Prunus
[8] : Tilleul   [9] : Erable

===========================================================