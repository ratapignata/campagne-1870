# v0.8.22 — effectifs QG et numéros des pions

Les QG français et prussien passent de 150 à 250 hommes dans les deux scénarios de nouvelles parties. Leurs 4 PA, armements et valeurs de tir restent identiques. L'aide est actualisée. Effectifs d'essai : ADAPTATION GAMEPLAY.

Suppression des petits rectangles sombres derrière le numéro d'identification en haut à droite des pions, pour les unités amies et les contacts ennemis. Les chiffres sont dessinés directement sur le fond de leur camp.

Sauvegardes séparées save_classic_v0822.json et save_three_v0822.json. Les packs v0.8.21 exacts sont conservés avec leurs anciens emplacements : les parties en cours gardent leurs effectifs et pertes, sans ajout rétroactif d'hommes. Nouvelle bataille nécessaire pour les QG de 250 hommes.

Validation : test_hq0822_ui.gd 12/12 headless (fiches, effectifs, commandes, aide, reprise v0.8.21). Les deux packs de l'APK contiennent bien des QG de 250 hommes et les anciens packs sont identiques octet pour octet. Godot 4.5.1 ; version Android 0.8.22, code 35 ; signature v2/v3 et alignement 16 Ko vérifiés, même certificat et package.

Aucun test physique Android ni contrôle visuel du rendu effectué ; contraste des numéros à confirmer sur téléphone. Pas de nouvelle simulation de bataille complète pour ces changements limités.
