# Essai 2D № 2 — ressources et provenance

Les deux planches PNG sont des illustrations générées pour ce prototype à partir de la référence visuelle fournie par le joueur. La référence sert à la direction artistique ; les hexagones, villages, routes et unités ne sont pas extraits de cette image. Le jeu compose sa carte à partir de ses propres données, inchangées.

- `assets/graphics2d2/painted_ground.png` : 1536 × 1024, douze matériaux peints, sans réseau géographique ni texte.
- `assets/graphics2d2/painted_figures.png` : 1536 × 1024 RGBA, six illustrations militaires par arme/camp, trois groupes forestiers, trois villages. Transparence réelle. Les figures sont génériques ; elles ne constituent pas une reconstitution d’uniforme propre à chaque régiment.
- `atlas_manifest.json` : rectangles de lecture des images. Les images sont chargées comme deux textures partagées ; le moteur utilise des régions d’atlas et des UV limités aux hexagones. Aucun traitement de détourage à chaque image.
- `build_ui_assets.py` : sources originales des dix petites peaux SVG pour les bandeaux et boutons. Pour les reconstruire : `python3 development/graphics2d2/build_ui_assets.py` depuis la racine du projet.

Les deux PNG complets sont livrés comme sources raster. Leur reconstruction à l’identique par génération d’image n’est pas déterministe ; le rendu en jeu l’est, car les images et régions sont fixes. Les variantes visuelles dépendent seulement de l’index public de l’hexagone, sans consommer le RNG du moteur de combat.

Les polices, drapeaux, logo et sons restent ceux du prototype stable et conservent leurs crédits. Les anciens SVG de l’essai 1 sont gardés dans les sources pour permettre de reprendre son apparence ; ils ne sont plus préchargés par le module de rendu de l’essai 2.
