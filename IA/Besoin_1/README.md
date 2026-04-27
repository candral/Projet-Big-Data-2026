# Projet-BigData-IA-Web-2026

Projet sur le patrimoine arboré de St-Quentin

## Mise en place pour le développement en local

### Prérequis

- Python >= 3.8

### Créer et utiliser un venv

1. **Créer un environnement virtuel:**

   ```bash
   python -m venv venv
   ```

2. **Activer l'environnement virtuel:**
   - **Windows (PowerShell):**
     ```bash
     .\venv\Scripts\Activate.ps1
     ```
   - **Windows (Command Prompt):**
     ```bash
     venv\Scripts\activate.bat
     ```
   - **Windows (Git Bash):**
     ```bash
     . venv/Scripts/activate
     ```
   - **macOS/Linux:**
     ```bash
     source venv/bin/activate
     ```

3. **Installer les librairies:**
   ```bash
   pip install -r requirements.txt
   ```

### Dépendances

Toutes les dépendances nécessaires sont listées dans `requirements.txt`:

- **pandas**: Manipulation et analyse de données
- **numpy**: Calcul numérique
- **scikit-learn**: Modèles d'apprentissage automatique (clustering KMeans)
- **matplotlib**: Visualisation de données
- **plotly**: Cartographie et visualisation interactive
- **joblib**: Sérialisation de modèles (sauvegarde/chargement de fichiers .pkl)
- **jupyter**: Support des notebooks Jupyter
- **ipython**: Interpréteur Python amélioré

### Exécuter le projet

Une fois l'environnement virtuel activé :

#### Via le script complet (.ipynb)

```bash
jupyter notebook Projet_IA_Besoin_1.ipynb
```

#### Via le script python (.py) :

```bash
python projet_ia_besoin_1.py
```

### Désactiver l'environnement virtuel

```bash
deactivate
```
