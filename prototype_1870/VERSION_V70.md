# V70 — France, Graphisme12 et introduction BD 2

27 novembre 2026. Base V43.17 Graphisme12, commit `896d8211e56403020baee6c5ecda30a1befa0595`. Branche distincte `v70-france-artillerie-bd2`. Aucune fusion avec main ou les versions précédentes.

## Difficultés françaises

Normal reprend exactement l’ancienne France Difficile V43.17, avec ses deux aides françaises figées. Les seuls changements dans la copie du contrôleur sont les chemins de ces deux dépendances. Les états de repositionnement sont transmis et vérifiés. Les doctrines prussiennes Normal et Difficile restent identiques.

Difficile reçoit uniquement les trois améliorations approuvées :

1. Positionnement des canons derrière l’infanterie, ancrage sur une formation amie engagée, préférence pour une ligne de tir à trois/quatre hexagones et un écran proche. Chaque destination reste soumise aux vrais coûts, occupation, relief, LOS, commandement et ravitaillement.
2. Conservation d’une position déployée utile et pénalité aux réattelages sans gain de tir ou de sécurité. Une infanterie observée à trois hexagones ne suffit plus à elle seule à déclencher un repli urgent ; l’approche de cavalerie et le contact proche restent pris en compte. Aucun tir gratuit ni PA supplémentaire.
3. Couverture locale des batteries par au plus deux formations d’infanterie disponibles, en préservant les premiers défenseurs d’objectifs et les unités déjà chargées d’une incursion arrière. Cet écran est une estimation de planification et un déplacement réel, pas une nouvelle règle de soutien ou de riposte.

Aucun nouveau système de contre-attaque ou de concentration de feu ajouté dans cette version. Les règles actuelles de combat, riposte, isolement/reddition, coût de charge deux PA, vingt tours, score 60/20/20, objectifs 3/2/1 et les 95 unités déclarées, dont cinquante allemandes totalisant 95 000 hommes, restent celles de V43.17. Chassepot actif quatre hexagones, riposte trois ; Dreyse deux ; canons français six et Krupp huit. Coûts et dégâts inchangés.

## Introduction BD 2

Reprise exacte des six images, des six textes développés, de la scène et du lecteur du commit BD 2 `141b184d0a45e399cf46d62f73d734aa3e1d11b0`. Aucun contenu BD 3 substitué. Menu → introduction générale → fiche existante de bataille/choix des paramètres → scénario. La BD spécifique de Frœschwiller-Wœrth n’a pas été fournie et n’est pas présentée comme réalisée.

Suivant, Précédent, lecture automatique trente secondes par scène, passage immédiat, retour au menu et retour Android conservés. Images entières, texte défilable sur petit écran, images chargées à la demande puis libérées. Continuer une sauvegarde accède directement à la partie. Les illustrations Graphisme12, pions, bandeaux et animations de combat restent ceux de V43.17.

## Installation et sauvegardes

APK nommé V70, version Android `0.8.70`, code 15. Même paquet `org.woerth1870.prototype.graphics2dexp`, même certificat et mêmes données que V43.17 Graphisme12 : installer par-dessus, sans désinstaller. L’application BD expérimentale historique reste distincte.

Scénario et format de sauvegarde inchangés ; aucune migration nouvelle nécessaire. Les nouveaux exports portent le préfixe `1870_V70`. Chargement et aller-retour de la véritable partie T20 fournie vérifiés dans une copie isolée, état et score conservés, original intact. Les parties chargées gardent leur difficulté enregistrée : une ancienne partie Difficile applique donc la nouvelle politique Difficile. Pour retrouver la référence V43.17 en Normal, créer une nouvelle partie en jouant les Prussiens puis choisir Normal.

## Limites

Tests automatisés, rendu logiciel Linux et comparaison chronologique T1–T8 du scénario réel. Bilan mesuré : Wœrth retardé de deux tours, moins de pertes de servants, mais pas de hausse du nombre de tirs ou des dégâts des canons dans cet essai. Pas de nouvelle bataille complète à vingt tours ni de reproduction exacte des choix du joueur. Aucun test physique ou émulateur Android. Les mesures et leurs limites sont détaillées dans TESTS_V70.md et COMPARAISON_IA_V70.md ; aucun taux de victoire général n’est garanti.
