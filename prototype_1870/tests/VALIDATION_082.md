# Validation — prototype 0.8.2

29 septembre 2026. Retouche visuelle : bouton Formation jaune doré et texte sombre.

Comparaison exacte à l’archive 0.8.1 : moteur, IA, stockage, carte et pack de règles
inchangés. Seul le paramètre de style du bouton change dans l’interface ; textes
identiques hors numéro de version. Aucune migration de sauvegarde nécessaire.

Pas de nouvelle suite de tests ni de relance complète pour ce changement de style.
Les validations fonctionnelles 0.8.1 figurent dans `tests/VALIDATION_081.md`.
Contrôle visuel des états disponible et désactivé réalisé sur bureau avant export.

Pas de test sur téléphone physique ni émulateur Android. Le confort et la visibilité
sur le téléphone du joueur restent à confirmer.

## APK

VersionCode 15, versionName 0.8.2 ; même paquet et certificat que la 0.8.1.
Signature v2/v3 vérifiée. Pack, textes et crédits identiques aux sources.
Tests, captures et clé exclus de l’APK. Aucune permission réseau.
Android API 24 minimum, cible API 35 ; ARMv7, ARM64 et x86_64.
Captures des deux états du bouton : `captures/v082`.
Taille : 87183992 octets.
SHA-256 : `7905595fbd23737662b30de03b161f0eb7eacafeae512858ccb7abc7471aa4ad`.
