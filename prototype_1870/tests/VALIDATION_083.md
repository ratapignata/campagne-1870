# Validation — prototype 0.8.3

29 septembre 2026. Correction d’un chevauchement de commandes dans le bandeau inférieur.

## Reproduction

La suite tactile `test_formation_button_ui.gd` reproduit le défaut de la 0.8.2 :
infanterie prussienne 3 déplacée de deux cases pour 1,25 PA (reste 2,75), puis
sélection des infanteries 2, 4 et 1 restées à 4 PA. Tant qu’un mouvement reste
annulable, Se retrancher recouvre Formation et reçoit l’appui à sa place.
12 échecs observés avant correction sur les quatre unités ; journal
`tests/results/formation_button_before.log`.

## Correction et vérifications

Annulation placée au-dessus de la rangée tactique lorsqu’elle coexiste avec
Se retrancher. Formation garde sa taille et son emplacement ; rectangles distincts.
Le titre « Mouvement annulable » tient dans la largeur disponible.

46 / 46 assertions de régression réussies à 1280 × 720 et à 1520 × 720,
puis 179 / 179 contrôles tactiles généraux réussis à 1280 × 720.
Journaux : `formation_button_after_1280.log`, `formation_button_after_1520.log`,
`touch_check083_1280.log`. Captures avant/après dans `captures/v083`. Vérification du dialogue par de vrais événements
tactiles injectés : ouverture sans dépense et sans retranchement involontaire,
Colonne vers Ligne à exactement 1 PA, annulation et retranchement toujours utilisables,
formation après retranchement préservant l’abri. Rendu inspecté sur bureau.

Comparaison exacte avec la 0.8.2 : moteur, règles, IA et stockage inchangés.
Aucune migration supplémentaire. Les validations précédentes sont conservées dans
`tests/VALIDATION_082.md` et les autres rapports archivés.

## Limites

Pas d’exécution sur téléphone physique ni émulateur Android. Les contrôles tactiles
sont injectés dans Godot sur bureau. Une action accidentelle déjà sauvegardée par
une ancienne version n’est pas annulée automatiquement : son intention est inconnue.

## APK

VersionCode 16, versionName 0.8.3 ; même paquet et certificat que la 0.8.2.
Signature v2/v3 vérifiée. Pack, textes et crédits identiques aux sources.
Tests, captures et clé exclus de l’APK. Aucune permission réseau.
Android API 24 minimum, cible API 35 ; ARMv7, ARM64 et x86_64.
Taille : 87183992 octets.
SHA-256 : `e175f0a10ad50d5e3c1349357ec85cd1e36e7e2eb23cef15a99c2131d0f72dc9`.
