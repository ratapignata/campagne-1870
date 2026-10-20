# Reproduire V43

Utiliser Godot 4.5.1. Depuis prototype_1870 :

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/v43/test_raoult.gd
godot --headless --path . --script res://tests/v43/test_real_charges.gd
godot --headless --path . --script res://tests/v43/test_cavalry.gd
godot --headless --path . --script res://tests/v43/test_variant_b.gd
godot --headless --path . --script res://tests/v43/test_ui.gd
godot --headless --path . --script res://tests/v43/test_tactical_mobile.gd -- medium 430001
```

Isoler XDG_DATA_HOME par test sous Linux ; le sous-dossier utilisateur est 1870-prototype-v02. Refaire la petite campagne avec hard et les graines 430001 et 430002. Ne pas confondre ses douze unités de test avec le scénario réel de 95 unités.

Pour le test de rendu, un véritable affichage X11/OpenGL est nécessaire : lancer test_animation_render.gd sans --headless avec --display-driver x11 --rendering-method gl_compatibility --audio-driver Dummy. Le serveur Linux de livraison utilisait Xorg dummy et Mesa llvmpipe. Un rendu Dummy headless ne valide pas les pixels.

Configurer les templates officiels Godot 4.5.1, Java 21 (ou la version supportée par le moteur), SDK Android 35 et build-tools 35.0.0 dans l’éditeur. Le préréglage Android conserve le certificat de développement du prototype et le paquet historique.

```sh
godot --headless --path . --export-debug Android ../1870_v0.8.43.1.apk
apksigner verify --verbose --print-certs ../1870_v0.8.43.1.apk
zipalign -c -P 16 4 ../1870_v0.8.43.1.apk
```

Ce certificat sert aux APK de test ; ce n’est pas une nouvelle clé de production pour un magasin. Ne pas effacer l’ancienne application pour installer une mise à jour compatible si l’on souhaite conserver ses données.

## Arrivée voisine V43.1

```sh
godot --headless --path . --script res://tests/v43/test_adjacent_reinforcements.gd
```

Cette suite teste aussi une sauvegarde V43 antérieure à la règle et son entrée voisine au prochain tour propre.
