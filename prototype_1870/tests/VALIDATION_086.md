# Validation — prototype 0.8.6

30 septembre 2026. Charge 2 PA, brouillard et reconnaissance.

## Tests ciblés

- 41/41 contrôles du brouillard : portées, hauteur, couverts, masquage, identification,
  mémoire figée, effacement après réobservation, impossibilité d’attaquer une unité
  cachée, déplacements limités par découverte, coût réel et annulation.
- 7/7 contrôles complémentaires : un ennemi caché ne bloque pas le diagnostic
  de visée ; s’il intercepte le tir exécuté, il reçoit les pertes, les PA sont
  dépensés et il se révèle sans possibilité d’annuler. Déplacement après tir et
  recul forcé hors de vue ne révèlent pas les nouvelles positions.
- Test de deux mondes identiques du point de vue du joueur : modifier la position,
  les pertes, le nombre de mouvements et la graine d’un ennemi caché ne change ni
  les chemins proposés, ni l’observation de l’IA, ni sa décision. La liste d’ennemis
  passée par un appelant ne contourne pas le filtre du moteur.
- Sauvegarde exacte des contacts, révélations et événements après JSON/rechargement ;
  normalisation des nombres des signalements anciens. Un contact invalide est rejeté.
- Bataille IA contre IA de six tours terminée en 145 décisions avec les seules
  observations de chaque camp, aucune commande rejetée ni état invalide.
- 19/19 contrôles tactiles ciblés à 1280 × 720 et 19/19 à 1520 × 720 : reprise 0.8.5,
  coût 2 PA dans cette reprise, nouvelle partie avec brouillard, redémarrage réel,
  clic sur ennemi caché, fiche repérée/identifiée/ancienne, confirmation et coût de
  charge, pertes estimées, camp prussien. Captures inspectées et conservées.

## Régressions

Échanges/assauts 45/45 ; formations 39/39 ; positions/résultats 34/34 ; migration
0.8.1 32/32 ; cavalerie historique 0.8.5 41/41 sur son pack archivé, coût ancien de
3 PA conservé dans cette fixture uniquement. Le parcours applicatif de reprise
applique désormais 2 PA. Suite tactile générale : 179/179 à 1280 × 720 (`touch086.log`),
exécutée avec brouillard désactivé pour isoler les commandes déjà en place.

## Limites

Exécution sur ordinateur avec événements tactiles simulés, rendu OpenGL logiciel.
Aucun essai sur téléphone ou émulateur Android : performances, batterie, sons,
lisibilité et équilibre sur appareil restent à confirmer. L’IA actuelle utilise les
contacts présents ; la recherche des contacts perdus et les trois difficultés ne
sont pas encore intégrées. Carte, troupes et coefficients restent un exercice
fictif, non le scénario historique documenté de Frœschwiller.

## Export Android

APK debug signé : `org.woerth1870.prototype.v02`, version 0.8.6, code 19.
Signatures v2/v3 vérifiées, même certificat que 0.8.5. API minimum 24, cible 35 ;
ARMv7, ARM64 et x86_64. Aucune permission Internet. Packs courant et deux anciens,
textes français et crédits vérifiés dans l’APK. Moteur et module de reconnaissance
compilés présents ; tests, captures et clé de développement exclus. Carte, troupes,
armes et règles précédentes comparées à l’archive 0.8.5 et conservées ; charge 2 PA
et configuration du brouillard ajoutées séparément.

Taille : 87610515 octets.
SHA-256 : `7a856ad16826852518c3a2992f871057e170a2454138c88170320990dc5a12de`.
