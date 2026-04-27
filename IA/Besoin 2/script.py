import joblib
import pandas as pd
import numpy as np
import os
import warnings
warnings.filterwarnings("ignore", category=UserWarning)

def charger_modeles(modele_path='model/meilleur_modele_arbre.pkl', scaler_path='model/standard_scaler.pkl'):
    """Charge le modèle et le scaler enregistrés."""
    if not os.path.exists(modele_path) or not os.path.exists(scaler_path):
        raise FileNotFoundError("Erreur : Les fichiers modèles sont introuvables.")
    
    model = joblib.load(modele_path)
    scaler = joblib.load(scaler_path)
    return model, scaler

def predire_age():
    mapping_especes =  {0: 'Autres', 1: 'Bouleau', 2: 'Charme', 3: 'Chêne', 4: 'Hêtre', 5: 'Pin', 6: 'Platane', 7: 'Prunus', 8: 'Tilleul', 9: 'Érable'}

    print("Outil de Prédiction (en centimètres):")
    
    try:
        model, scaler = charger_modeles()

        print("\n Table des Espèces :")
        for code, nom in mapping_especes.items():
            print(f"[{code}] : {nom}")
        print("-----------------")
        
        # Entrées utilisateur
        genre_id = int(input("\nEntrez le code de l'espèce : "))
        if genre_id not in mapping_especes:
            print("Code espèce inconnu, utilisation du code 0 (Autres).")
            genre_id = 0

        # On garde les noms de colonnes exacts du datafrale
        haut_tot = float(input("Hauteur totale (cm) : "))
        haut_tronc = float(input("Hauteur du tronc (cm) : "))
        tronc_diam = float(input("Diamètre du tronc (cm) : "))
        
        # Création du DataFrame avec les mêmes noms de colonnes que lors du training
        input_data = pd.DataFrame([[haut_tot, haut_tronc, tronc_diam, genre_id]], 
                                 columns=['haut_tot', 'haut_tronc', 'tronc_diam', 'genre_id'])
        # Scaler normalise les valeurs en cm
        input_scaled = scaler.transform(input_data)
        
        age_predit = model.predict(input_scaled)[0]
        
        print("-" * 45)
        print(f"Espèce : {mapping_especes[genre_id]}")
        print(f"Résultat : L'âge estimé est de {age_predit:.1f} ans.")
        print("-" * 45)

    except Exception as e:
        print(f"Une erreur est survenue : {e}")

if __name__ == "__main__":
    predire_age()