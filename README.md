# Prototype courant : V43.4

- [Télécharger l’APK V43.4](https://github.com/ratapignata/campagne-1870/raw/refs/heads/main/releases/1870_v0.8.43.4.apk)
- [Sources complètes V43.4](releases/1870_v0.8.43.4_Sources.zip)
- [Changements et vérifications](releases/VERSION_0843_4.md)

Seul le numéro d’unité en haut à droite est retiré. Le chiffre de force reste en bas du pion. Installer sans désinstaller l’application. Règles et IA inchangées.

---

# Prototype courant : V43.3 — pions sans numéros

- [Télécharger l’APK V43.3](https://github.com/ratapignata/campagne-1870/raw/refs/heads/main/releases/1870_v0.8.43.3.apk)
- [Sources complètes V43.3](releases/1870_v0.8.43.3_Sources.zip)
- [Changements et vérifications](releases/VERSION_0843_3.md)

Numéros d’unité et chiffres d’effectif retirés des pions ; effectifs consultables dans les fiches. Export de sauvegarde et corrections précédentes conservés. Aucun changement de comportement de l’IA. Installer sans désinstaller l’ancienne version. APK compilé et signé ; aucun essai sur appareil physique.

---

# 1870 : Frœschwiller-Wœrth — V43.2

**V43.2 ajoute l’export de la partie courante en JSON. Le comportement de l’IA et toutes les règles V43.1 sont conservés.**

- **[Télécharger l’APK V43.2](https://github.com/ratapignata/campagne-1870/raw/refs/heads/main/releases/1870_v0.8.43.2.apk)**
- **[Sources complètes V43.2](https://github.com/ratapignata/campagne-1870/raw/refs/heads/main/releases/1870_v0.8.43.2_Sources.zip)**
- [Utilisation et changements](releases/VERSION_0843_2.md)
- [Tests exécutés et limites](releases/TESTS_V43_2.md)
- **[Audit complet de l’IA Difficile V43](audit_v43/AUDIT_IA_V43.md)**
- [Diagnostic : sources de test, traces et données](releases/1870_V43_Diagnostic_IA_2026-10-21.zip)
- [Empreintes SHA256](releases/SHA256SUMS.txt)

Pour transmettre une partie : installer la mise à jour sans désinstaller l’ancienne application, reprendre la partie, ouvrir **Menu → Exporter la sauvegarde**, choisir **Téléchargements**, puis **Enregistrer**. Joindre ensuite le fichier JSON depuis **Mes fichiers / Fichiers → Téléchargements**.

Export natif disponible à partir d’Android 10 avec Godot 4.5.1. L’original et sa copie de secours sont conservés. Le JSON inclut toute la partie, les informations cachées et les paramètres IA, pour permettre un diagnostic exact.

11 suites : **6 103 contrôles fonctionnels réussis**, dont 28 sur l’export. Archive propre extraite et export retesté : 28/28. APK 0.8.43.2, code 59, signature et alignement vérifiés, même certificat de développement que V43.1. Aucun essai physique Android ; le sélecteur Android doit encore être essayé sur appareil.

Raoult entre sur un voisin libre et praticable si un ennemi occupe son entrée. Charge 2 PA, variante B 0,90, ripostes, isolement, commandement, ravitaillement, 20 tours, score 60/20/20, objectifs 3/2/1, 95 000 Allemands/50 unités : inchangés. Normal/Difficile, aucun bouton TIRER, aucun bonus IA.

Sources Godot 4.5.1 dans `prototype_1870`. Le diagnostic de l’IA Difficile est terminé : 20 tours des 95 unités contre une défense française mobile, 1 936 contrôles réussis. Au T12, 17 unités restent sans commande et 106,25 PA sont inutilisés ; les Prussiens finissent par prendre le dernier objectif au T19 et gagnent 82,42 contre 16,65. Congestion de progression, choix de tirs avant assaut et sécurisation des conquêtes sont détaillés dans le rapport. Ce n’est pas une reproduction de la partie personnelle du joueur. Aucune correction du comportement IA n’est appliquée à cet APK ; l’accord de l’utilisateur est attendu. Les versions précédentes restent archivées dans `releases` et l’historique Git.
