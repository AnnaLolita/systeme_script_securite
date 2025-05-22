import csv

# Données à écrire
donnees = [
    ["Jean", 25, "Paris"],
    ["Marie", 30, "Lyon"],
    ["Pierre", 22, "Marseille"],
    ["Sophie", 35, "Toulouse"]
]

#Nom du fichier CSV
nom_fichier = "personnes.csv"

# Création du fichier CSV et écriture des données
with open(nom_fichier, mode="w", newline='', encoding="utf-8") as fichier_csv:

    writer = csv.writer(fichier_csv)
    
    # Écrire l'en-tête (facultatif)
    writer.writerow(["Nom", "Âge", "Ville"])
    
    # Écrire les données
    writer.writerows(donnees)

print("Le fichier personnes.csv a été créé avec succès.")

