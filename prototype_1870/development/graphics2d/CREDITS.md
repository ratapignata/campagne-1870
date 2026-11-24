# Illustrations originales — essai 2D

Les terrains, feuillages et maisons de cet essai sont des dessins vectoriels originaux, générés de manière déterministe par `generate_svg.py`. Aucun élément graphique d’Age of Rifles n’est reproduit. Les illustrations militaires et les polices du prototype stable restent celles du projet, avec leurs crédits existants.

Les SVG sont les sources éditables. `build_atlas.gd` les assemble en un seul atlas PNG 1320 × 965. Les régions ont huit pixels de marge ; filtrage linéaire avec mipmaps pour les zooms réduits. Les variantes sont déterminées par l’index public de l’hexagone ; aucun tirage aléatoire de partie.

Reconstruction depuis la racine du projet :

```sh
python3 development/graphics2d/generate_svg.py
godot --headless --path . --script res://development/graphics2d/build_atlas.gd
godot --headless --editor --path . --import --quit
```

Godot 4.5.1 recommandé. Le PNG livré permet de lancer le jeu sans reconstruire les dessins. Les SVG et outils sont exclus de l’APK.
