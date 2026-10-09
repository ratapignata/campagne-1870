# Validation v0.8.30 — 6 octobre 2026

- test_revision0830.gd : 18/18 (routes, franchissement, ouverture tour 4, sauvegarde, tir et couverts).
- test_release0830.gd : 104/104 (reproduction canon à 2 hexagones, relief sans pénalité, cohérence affichage/tir, forêt/village, cultures, portée 8/6, topologie routière, pont, observation IA).
- test_regimental0830_ui.gd : 27/27 (sélection, déploiement, deux camps, scénarios, sauvegarde et reprise).
- test_feedback0830.gd : 9/9 (raison de blocage persistante, cible éclairée, hauteur et largeur du libellé, extinction du bilan).
- test_regimental0828.gd sur données 0830 : 181/181 (81 unités, vagues, réserves masquées, entrée bloquée, sauvegarde et 36 phases).
- Six décisions IA comparées avant/après optimisation, mêmes données 0829 : actions identiques aux trois niveaux et pour les deux camps ; temps total 6222 → 4690 ms, gain 24.6 %. Mesure sur ordinateur d’exécution, sans extrapolation garantie au smartphone ; pas un benchmark de partie complète.
- Optimisation : cache des voisins hexagonaux et initialisation directe depuis l’observation filtrée, sans création inutile d’une nouvelle bataille et de ses réseaux.
- Android : versionCode 43, versionName 0.8.30, paquet org.woerth1870.prototype.v02. Signature v2/v3 valide ; alignement 16 Ko valide.
- Certificat SHA-256 : 57c00efad8c9b822d4a1d63238a4137b9afc97b6e9248076f4f54bb292ae846c.
- Pas d’exécution sur appareil Android physique ni de validation visuelle interactive dans cette session.
- Les anciennes sauvegardes utilisent les packs legacy0829 ; démarrer une nouvelle bataille pour les nouvelles règles.
