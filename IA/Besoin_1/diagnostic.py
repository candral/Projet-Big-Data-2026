import joblib
import pandas as pd

def diagnostic_arbre():
    model = joblib.load('modele_arbres.pkl')
    scaler = joblib.load('scaler_arbres.pkl')
    mapping = joblib.load('mapping_noms.pkl')

    print(f"Diagnostic : ({len(mapping)} catégories)")
    h = float(input("Hauteur souhaitée en MÈTRES (ex: 15) : "))
    d = float(input("Diamètre souhaité en CM (ex: 100) : "))

    entree = pd.DataFrame([[h, d]], columns=['haut_tot', 'tronc_diam'])
    scaled = scaler.transform(entree)

    res_id = int(model.predict(scaled)[0])
    nom_final = mapping.get(res_id, "Inconnu")

    print(f"\nCet arbre est classé : {nom_final}")

diagnostic_arbre()
