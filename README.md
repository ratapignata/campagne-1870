# 1870 : Frœschwiller-Wœrth — V43.1

**V43.1 est le prototype courant** — correction des entrées de renforts demandée le 20 octobre 2026.

- **[Télécharger l’APK V43.1](https://github.com/ratapignata/campagne-1870/raw/refs/heads/main/releases/1870_v0.8.43.1.apk)**
- **[Sources complètes V43.1](https://github.com/ratapignata/campagne-1870/raw/refs/heads/main/releases/1870_v0.8.43.1_Sources.zip)**
- [Règle et changements](releases/VERSION_0843_1.md)
- [Tests exécutés](releases/TESTS_V43_1.md)
- [Cas Raoult](releases/RAOULT_V43.md)
- [Reproduire les tests](releases/REPRODUIRE_V43.md)
- [Empreintes SHA256](releases/SHA256SUMS.txt)

Si un ennemi occupe l’entrée d’un renfort, celui-ci arrive sur un hexagone immédiatement voisin libre et praticable. Dans le cas reproduit, Raoult entre au tour 3 en (15,3), tandis que la cavalerie prussienne reste en (15,4). Aucun empilement ni déplacement d’un occupant.

Si aucun voisin n’est disponible, le renfort attend. Une entrée occupée par un ami conserve son attente. Pas de franchissement d’une rivière non pontée. Même règle pour les deux camps. Une ancienne sauvegarde V43 déjà retardée réessaie au prochain début du tour du camp ; aucune réécriture du passé.

Variante B 0,90, projectile anthracite, charge 2 PA, ripostes, isolement/reddition, 20 tours, score 60/20/20, 95 000 Allemands et 50 unités inchangés. Normal/Difficile, aucun bouton TIRER ni bonus IA.

Huit suites relancées : 2 199 contrôles réussis, dont 32 pour l’arrivée voisine. Archive extraite et retestée indépendamment. APK 0.8.43.1, code 58, signé avec le certificat de développement existant ; aucun essai physique Android ni nouvelle simulation complète.

Sur téléphone : télécharger puis ouvrir Mes fichiers → Téléchargements → 1870_v0.8.43.1.apk et installer la mise à jour. Ne pas désinstaller l’ancienne application pour conserver les sauvegardes.

Sources dans prototype_1870, moteur Godot 4.5.1. V43.1 remplace V43 sur main ; les anciennes branches et l’archive originale V42 Lot 8 sont conservées.
