import joblib
import pandas as pd
import numpy as np
import os
import warnings
warnings.filterwarnings("ignore", category=UserWarning)

def charger_modeles(modele_path='model/best_random_forest_model.pkl', scaler_path='standard_scaler.pkl'):
    """Charge le modèle et le scaler enregistrés."""
    if not os.path.exists(modele_path) or not os.path.exists(scaler_path):
        raise FileNotFoundError("Erreur : Les fichiers modèles sont introuvables.")
    
    model = joblib.load(modele_path)
    scaler = joblib.load(scaler_path)
    return model, scaler

def predire_age():
    print("--- Outil de Prédiction (Unités : Centimètres) ---")
    
    try:
        model, scaler = charger_modeles()
        
        print("\nVeuillez entrer les dimensions en CENTIMÈTRES :")
        # On garde les noms de colonnes exacts de ton dataframe original
        haut_tot = float(input("Hauteur totale (cm) : "))
        haut_tronc = float(input("Hauteur du tronc (cm) : "))
        tronc_diam = float(input("Diamètre du tronc (cm) : "))
        
        # Création du DataFrame avec les mêmes noms de colonnes que lors du training
        input_data = pd.DataFrame([[haut_tot, haut_tronc, tronc_diam]], 
                                 columns=['haut_tot', 'haut_tronc', 'tronc_diam'])
        
        # Le scaler va normaliser ces valeurs en cm comme il l'a fait pour le train_set
        input_scaled = scaler.transform(input_data)
        
        age_predit = model.predict(input_scaled)[0]
        
        print("-" * 45)
        print(f"Résultat : L'âge estimé est de {age_predit:.1f} ans.")
        print("-" * 45)

    except Exception as e:
        print(f"Une erreur est survenue : {e}")

if __name__ == "__main__":
    predire_age()