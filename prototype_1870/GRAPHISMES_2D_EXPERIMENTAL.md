# Essai graphique № 10 — journal filtré et coche de fin d’action

Version `0.8.43.15-g2d10`, 31 octobre 2026. Branche `v43-graphismes-2d-experimental`. Essai 9 conservé au commit source `693ed1d` et dans ses livraisons. Stable/main préservées.

## Journal approuvé

Fenêtre bleu nuit/ivoire/or dans le style du jeu, cinq filtres actifs : Tous, Combats, Redditions, Objectifs, Renforts. Icônes, titres et horaires par tour, texte plus aéré, liste tactile défilante, bouton habituel de retour à la carte. Adaptation aux écrans logiques 1280 × 606 / 1280 × 720 / 1520 × 720. Les longues listes chargent leurs lignes par tranches de 40 au défilement.

Les pertes, ripostes, prisonniers autorisés, captures d’objectifs et bilans de fin de tour restent disponibles. Les liaisons restent dans Tous. Les arrivées de QG reportées restent prioritaires et expliquées, notamment Raoult. Les horaires correspondent au début des tours ; les bilans de fin de tour portent leur heure de fin.

Les données viennent de la partie et respectent les informations autorisées : noms de combat enregistrés sous brouillard, redditions confirmées, pertes adverses non confirmées masquées. Les renforts détaillés sont ceux du joueur. Une arrivée ancienne sans date effective conservée est signalée « date non consignée », jamais attribuée arbitrairement au tour prévu. Aucune capture absente d’une vieille sauvegarde n’est reconstituée. Les filtres n’enregistrent ni ordre ni sauvegarde.

## Coche demandée

Une unité du joueur porte la coche quand aucune action active légale accessible ne reste, même avec des PA positifs : déplacement vers une case libre (y compris transit à travers des amis), tir sur une cible connue, assaut/charge, ralliement, changement de formation, mise en batterie/attelage, retranchement accessible dans l’interface.

Ce n’est pas un seuil fixe : à 0,5 PA, un fantassin sans déplacement abordable est coché, mais un fantassin sur route ou un cavalier pouvant encore avancer reste disponible. À 0,25 PA, une route peut encore permettre un déplacement de cavalerie. Toutes les vérifications utilisent les coûts, terrains, rivières, occupation connue et conditions du moteur existant. Une voie libérée par un allié peut faire disparaître la coche.

Le compteur, Unité suivante et la confirmation de fin de tour utilisent la même disponibilité réelle. Une unité cochée reste consultable. La coche et la teinte grisée sont purement visuelles : aucun PA retiré, aucun `done=true` imposé, aucun ordre exécuté. Les réactions défensives et le réapprovisionnement automatique ne sont pas des actions actives ; ils restent inchangés. Annuler un mouvement garde son fonctionnement global existant.

La classification lit un instantané isolé du moteur ; ses caches ne touchent pas la partie. Elle évalue le budget propre sans déclarer toutes les unités terminées à cause de la seule phase adverse. Les positions ennemies inconnues n’influencent pas la coche ; aucune nouvelle information d’action/PA ennemie n’est affichée. Calcul uniquement au rafraîchissement de la fiche/partie, pas à chaque image ou déplacement de caméra.

## Conservation des règles et du rendu

IA Normal/Difficile et doctrine inchangées, charge 2 PA, ripostes, variante B, commandement/ravitaillement, isolement/reddition, 20 tours, score 60/20/20, objectifs 3/2/1, 95 000 Allemands/50 unités allemandes, effectifs/renforts, correction du QG Raoult, brouillard et animations conservés. Aucun bouton TIRER. Aucun module core/IA/plateforme/scène ou donnée de bataille modifié.

Carte et illustrations historiques de l’essai 9 conservées, une/deux silhouettes au seuil existant de 2 000 hommes connus. Grande police et cadre horaire centré conservés. Les nouveaux signes du journal sont de petits SVG ; la coche est vectorielle et ne masque pas le chiffre de force. Bandeaux et commandes de carte de mêmes dimensions ; nouvelles commandes limitées à la navigation du journal.

## Installation et livraison

Installer `1870_V43_Graphismes_2D_Experimental_10.apk` par-dessus l’essai précédent **sans le désinstaller**. Même application « 1870 · Essai graphique 2D », paquet expérimental et certificat, code Android 10. Sauvegardes des essais 1 à 9 vérifiées. Aucun champ de journal ou de coche ajouté au format ; tout se reconstruit à partir des données disponibles. Application stable et partie stable séparées, sans transfert automatique.

Sources complètes du jeu, ressources, tests, rapports et galerie courante inclus. Anciennes galeries 1 à 9 non dupliquées dans le ZIP, toujours dans GitHub/historique. Caches et compilations exclus ; aucun fichier nécessaire au jeu omis. Galerie : `captures/graphismes2d10/README.md`. Tests : `TESTS_GRAPHISMES_2D.md`. Liste exhaustive : `FICHIERS_GRAPHISMES_2D.txt`.

## Limites

7 494 assertions finales réussies, APK compilé/signature vérifiée, captures réelles Godot 4.5.1/Linux. Aucun essai physique ou émulateur Android. Les horaires d’arrivée non enregistrés des renforts restent inconnus. La navigation du journal revient à Tous à sa réouverture. Aucun changement intégré à main avant validation visuelle.
