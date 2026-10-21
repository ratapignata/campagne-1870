# V43.2 — Export de la partie courante (21 octobre 2026)

Correctif d’interface sur V43.1, version Android 0.8.43.2, code 59. Aucune correction du comportement de l’IA n’est appliquée. Les règles, le scénario, les profils et les scripts IA restent identiques octet par octet à V43.1 (empreintes dans tests/results/0843_2_export/protected_sources.json).

## Utilisation sur Android

1. Installer la mise à jour sans désinstaller l’application existante.
2. Reprendre la partie, puis ouvrir **Menu → Exporter la sauvegarde**.
3. Dans le sélecteur Android, choisir **Téléchargements** puis **Enregistrer**.
4. Dans Fichiers / Mes fichiers → Téléchargements, sélectionner le fichier `1870_V43_T12_….json` pour le joindre à ChatGPT ou le transférer sur ordinateur.

Le mécanisme natif Godot 4.5.1 utilise Android ACTION_CREATE_DOCUMENT. Il est disponible à partir d’Android 10 dans cette version de Godot. Sur Android plus ancien, un message indique cette limite ; le jeu conserve sa compatibilité existante. Le sélecteur Godot vise les documents locaux : choisir Téléchargements ; partager ensuite depuis Fichiers. Aucun accès global aux fichiers ni permission Internet ajouté.

## Données et intégrité

L’export fige l’état actuel du moteur, même si celui-ci diffère du fichier sauvegardé. Il conserve l’état complet et le précédent état d’annulation : 95 unités, positions, effectifs, PA, moral, renforts, tour/camp, brouillard, contacts, commandement, ravitaillement, isolement, objectifs, historiques, score, graine et paramètres IA.

Le JSON garde l’enveloppe de sauvegarde existante : schema=1, pack_hash, payload (chaîne JSON), checksum SHA256. Les métadonnées export_info indiquent la version/date UTC ; les décisions IA transitoires sont jointes lorsqu’aucun worker ne travaille. Si un worker travaille, ce fait est indiqué ; aucun état partagé du worker n’est lu. Les paramètres IA et toute la partie se trouvent toujours intégralement dans payload.

L’export n’appelle pas save_game et ne tourne pas le fichier .bak. L’ouverture du menu ne refait plus une autosauvegarde redondante ; les sauvegardes après chaque action sont conservées. Les notifications pause/perte de focus provoquées par le sélecteur sont exclues de l’autosauvegarde pendant l’export. Original, .bak et .tmp sont des destinations interdites. Le fichier externe est relu et son contenu comparé à l’intégralité du payload avant de confirmer la réussite.

Le fichier est compatible avec le chargeur existant ; aucune nouvelle commande d’import n’a été ajoutée au menu. Pour une analyse externe : `outer=json.load(f); data=json.loads(outer['payload'])`. Ne pas altérer le checksum.

## Fichiers modifiés

- war_engine/platform/save_store.gd : construction et vérification de la copie exportée.
- war_engine/presentation/main.gd : bouton tactile, sélecteur, résultats/annulation, protection de la sauvegarde.
- project.godot, export_presets.cfg, packs/1870/fr.json : identification 0.8.43.2.
- tests/v43_export : tests d’export et captures d’interface.
- TESTS_V43_2.md et tests/results/0843_2_export : preuves et limites.

Raoult, variante B 0,90, charge 2 PA, ripostes, isolement, 20 tours, 60/20/20, objectifs 3/2/1 et 95 000 Allemands restent inchangés. L’empreinte du scénario V43.1 est conservée : les sauvegardes V43/V43.1 restent compatibles.
