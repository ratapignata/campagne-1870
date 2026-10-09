# Validation 0.8.15

- Réseau : 36 liaisons adjacentes, 37 nœuds dans une seule composante ; aucun
  triangle, aucune case routière isolée, aucune liaison hors pont traversant
  la rivière. Terrain routier aligné sur les liaisons. Un seul pont conservé.
- Moteur de franchissement : 108/108 tests test_river0814.gd -- --quick.
- Interface : test_ui0815.gd, 41/41 contrôles en 1280×720 et en 1520×720.
  Annulation par appui après traversée, PA et position restaurés, interdiction
  après tir effectif, bouton grisé visible et explicatif, Repos sans chevauchement.
- Sauvegarde : création d’une véritable sauvegarde 0.8.14, reprise via l’écran
  initial avec les PA conservés, puis nouvelle partie 0.8.15 indépendante.
- Captures OpenGL examinées visuellement. APK versionCode 28, versionName 0.8.15,
  même package et certificat de signature que 0.8.14.

Aucun changement aux formules de combat, aux forces, aux tours ou à l’IA.
Les trajets et coûts de déplacement peuvent changer avec le réseau routier corrigé.
Pas de test sur appareil Android physique ; équilibre à réévaluer en jeu.
