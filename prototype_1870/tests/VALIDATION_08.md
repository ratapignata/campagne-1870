# Validation — prototype 0.8

29 septembre 2026. Godot 4.5.1, environnement de bureau.

## Moteur

297 assertions des huit suites antérieures relancées et réussies ; 39 assertions
supplémentaires de `test_formations08.gd` réussies : **336 au total**.
Journaux : `tests/results/08_test_*.log`.

Couverture : coûts réels, arrondis par terrain, rejet atomique des ordres invalides,
annulation, PA épuisés, état d’abri conservé ; facteurs des tirs et du contact,
riposte et feu défensif ; persistance des formations et import du véritable pack 0.7
avec empreinte exacte, état normalisé, mouvement annulable et fichier original intact.
Sauvegardes aux formations invalides rejetées. Moral et victoire conservés.

## IA

Quatre batailles complètes, graines 13, 71, 1870 et 2026 : 544 actions légales,
244 tirs, 16 assauts, aucun blocage, états valides. Décision la plus lente : 68,8 ms
sur bureau partagé, pas Android. Durée de contrôle 3/3 dans chaque partie.
Pertes FR/PRU : 1719/1604, 1708/1610, 1718/1593, 1714/1586 ; aucun prisonnier.
Ces simulations ne démontrent pas l’équilibre contre un humain.

## Interface

163 / 163 assertions tactiles réussies à 1280 × 720 et à 1520 × 720.
Journaux : `touch_check08_1280.log`, `touch_check08_1520.log`.
Le choix des formations, les coûts affichés, la sauvegarde, l’inspection ennemie
et les contrôles désactivés ont été vérifiés. Captures inspectées visuellement.
Captures de positions aménagées dans `captures/v08`.

## Limites

Pas d’exécution de cette version sur téléphone physique ni émulateur Android.
Installation, confort tactile réel, sons, chauffe, batterie et performances restent
à confirmer sur appareil. Le scénario reste un exercice fictif de six tours,
sans cavalerie, brouillard, fatigue ni munitions. Musique et sons inchangés.
Les validations antérieures sont conservées dans `tests/VALIDATION_073.md`.

## APK

VersionCode 13, versionName 0.8.0 ; même paquet et certificat que la 0.7.3.
Signature v2/v3 vérifiée. Pack, textes et crédits comparés exactement aux sources.
Tests, captures et clé exclus de l’APK ; aucune permission réseau.
Android API 24 minimum, cible 35 ; ARMv7, ARM64 et x86_64.
Taille : 87183992 octets.
SHA-256 : `67e7ce483e819b48cdb0583e641b326c7c9296206911e2256c85cf5ec1bc3b82`.
