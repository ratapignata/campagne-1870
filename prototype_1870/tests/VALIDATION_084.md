# Validation — prototype 0.8.4

30 septembre 2026. Retouche de lisibilité des pions et des terrains.

## Vérifications

- 179 / 179 assertions tactiles réussies à 1280 × 720 : sélection, déplacement,
  confirmation et annulation, tirs et ripostes, assaut, ralliement, retranchement,
  formations, sauvegarde, menus, pause et appuis longs sur D/pelle.
- 46 / 46 assertions du chevauchement Formation / Se retrancher réussies à
  1520 × 720 : infanteries prussiennes à 4 PA et 2,75 PA, commandes distinctes.
- Journaux : `touch_check084_1280.log` et `formation_button084_1520.log`.
- Comparaison exacte avec la 0.8.3 : moteur, pack de règles/carte, IA, stockage
  et interface de commandes inchangés. Aucun changement de compatibilité de sauvegarde.
  Gestion des événements tactiles et animations conservée dans la vue de carte.
- Captures de contrôle avec unités disposées pour montrer les états : zooms 1,5,
  1,18, 1,0, 0,6 et minimum 0,42 ; D, pelle, déroute, PA épuisés et artillerie.
  Contrôle visuel des chiffres et symboles ; largeur du D gras corrigée pour
  éviter son masquage. Captures conservées dans `captures/v084`.

## Limites

Vérifications sur bureau, sans téléphone physique ni émulateur Android.
La lisibilité sur le téléphone du joueur et les performances Android restent à confirmer.
Au zoom de vue générale, les détails des silhouettes sont naturellement réduits.
Le scénario est toujours un exercice fictif : aucun nouvel uniforme ou terrain ne
prétend valider historiquement une unité ou position de Frœschwiller.
La cavalerie, le brouillard et les trois niveaux d’IA restent à développer.
Validation précédente : `tests/VALIDATION_083.md`.

## Export Android

- APK debug signé, paquet `org.woerth1870.prototype.v02`, version 0.8.4, code 17.
- Certificat identique à la version précédente ; signatures v2/v3 vérifiées.
- Android minimum 24, cible 35 ; ARMv7, ARM64 et x86_64. Aucune permission Internet.
- Pack, textes français et crédits audio identiques aux fichiers sources. Police
  grasse et moteur compilé présents ; tests, captures et clé de développement exclus.
- Taille : 87585622 octets.
- SHA-256 : `966bf4316a7ab43574ddc817cd5210472af6b15394732da13ea596ef81872f3b`.
