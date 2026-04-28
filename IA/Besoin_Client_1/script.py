import joblib
import pandas as pd

def diagnostic_arbre():
    model = joblib.load('models/modele_arbres.pkl')
    scaler = joblib.load('models/scaler_arbres.pkl')
    mapping = joblib.load('models/mapping_noms.pkl')

    print(f"Diagnostic : ({len(mapping)} catégories)")
    hauteur_totale = float(input("Hauteur totale en MÈTRES (ex: 15) : "))

    stade_table = """
      Table de correspondance :
      1 -> "Jeune"
      2 -> "Adulte"
      3 -> "Vieux/Sénescent"
    """
    print(stade_table)
    fk_stadedev = str(input("Entrez le chiffre correspondant au stade : "))
    age_estim = int(input("Age de l'arbre : "))
    diametre_tronc = float(input("Diamètre souhaité en CM (ex: 100) : "))

    entree = pd.DataFrame([[hauteur_totale, fk_stadedev, age_estim, diametre_tronc]], columns=['haut_tot', 'fk_stadedev', 'age_estim', 'tronc_diam'])
    scaled = scaler.transform(entree)

    res_id = int(model.predict(scaled)[0])
    nom_final = mapping.get(res_id, "Inconnu")

    print(f"\nCet arbre est classé : {nom_final}")

diagnostic_arbre()