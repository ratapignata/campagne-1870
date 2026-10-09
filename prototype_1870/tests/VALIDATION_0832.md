# Validation v0.8.32 — 6 octobre 2026

- check_terrain0832.py : trois scénarios contrôlés ; restauration des terrains d’origine (anciennes cases hill converties en plain), suppression des variantes height_ sur la carte ; routes, ponts, toponymes et armes inchangés.
- test_release0830.gd exécuté sur v0.8.32 : 104/104 (tir à deux cases, absence de pénalité de relief, cases éclairées, bois/villages, cultures, portée, pont tour 4, routes et observation IA).
- test_feedback0832.gd : 14/14 (Plaine seule, bois/village/cultures reconnus malgré altitude, absence de traits de relief, messages de blocage, fin du bilan).
- test_regimental0832_ui.gd : 27/27 (deux camps, sélection, déploiement, sauvegarde, reprise et choix des scénarios).
- Android : versionCode 45 / versionName 0.8.32 ; même paquet org.woerth1870.prototype.v02 et même certificat ; signature v2/v3 et alignement 16 Ko valides.
- Données d’altitude internes conservées pour les autres règles antérieures (observation et passage au-dessus d’une troupe amie) ; aucun blocage ou malus de tir dû au relief entre positions découvertes. Aucun changement non demandé des règles de commandement ou de ravitaillement.
- Pas de validation sur appareil Android physique ni de contrôle visuel interactif dans cette session.
