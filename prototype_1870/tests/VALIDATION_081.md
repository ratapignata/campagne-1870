# Validation — prototype 0.8.1

29 septembre 2026. Godot 4.5.1, environnement de bureau.

## Contrôles ciblés

- 32 / 32 assertions de `test_revision081.gd` : départ gratuit en Colonne des huit
  infanteries pour les deux camps jouables, batteries inchangées, conservation du
  moral, de la victoire et des armes ; import 0.8 avec ses trois formations et son
  mouvement annulable, original intact, rechargement exact, nouvelle partie après
  import, normalisation des sauvegardes antérieures sans formation vers Ligne.
- 39 / 39 assertions de `test_formations08.gd` : effets et coûts des formations,
  tirs, contact, ripostes, sauvegardes et import 0.7. Cette régression utilise le
  pack 0.8 archivé pour conserver son scénario de référence débutant en Ligne.
- Les anciennes suites conservent désormais le pack de référence 0.8 ; elles ne
  prétendent pas tester le départ en Colonne, couvert par la suite 0.8.1.
- Journaux : `tests/results/081_*.log`.

## Interface

179 / 179 assertions réussies à 1280 × 720 et à 1520 × 720.
Journaux : `touch_check081_1280.log` et `touch_check081_1520.log`.
Captures vérifiées visuellement, conservées dans `captures/v081`. Les anciens scénarios de référence utilisent
Ligne ; la nouvelle séquence vérifie le véritable départ en Colonne, la surface
et l’emplacement du bouton, l’absence de chevauchement avec les autres actions,
le coût de changement et la consultation sans dépense de PA.

## Limites

Tests réalisés sur bureau, sans téléphone physique ni émulateur Android.
Le confort de cette commande et l’intérêt des formations restent à apprécier en jeu.
Les simulations IA 0.8 ne sont pas une mesure d’équilibre avec le nouveau départ
systématique en Colonne. Scénario fictif, sans cavalerie, brouillard ni fatigue.
Validation précédente conservée dans `tests/VALIDATION_08.md`.

## APK

VersionCode 14, versionName 0.8.1 ; même paquet et certificat que la 0.8.
Signature v2/v3 vérifiée. Pack, textes et crédits identiques aux sources.
Tests, captures et clé exclus de l’APK. Aucune permission réseau.
Android API 24 minimum, cible API 35 ; ARMv7, ARM64 et x86_64.
Taille : 87183992 octets.
SHA-256 : `2e879a44ee7b813b32c49c5299728592c6adcad51a2bf6e2d42eee8479d354f4`.
