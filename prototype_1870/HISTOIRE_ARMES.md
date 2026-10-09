# Armements — note historique et choix du prototype 0.2.1

Recherche ciblée du 23 septembre 2026. Cette note complète la phase 0 ; elle ne
valide ni un ordre de bataille ni les positions du 6 août 1870.

## Conclusions et degré de certitude

**CONFIRMÉ — Chassepot / Dreyse.** Le Chassepot constitue un avantage français,
notamment pour engager à plus longue distance que le Dreyse prussien. Les Archives
nationales du monde du travail soulignent portée et précision supérieures [1] ;
Chemins de mémoire confirme la supériorité générale de l’arme [2].

**CONFIRMÉ — artillerie allemande.** Le Musée de la bataille du 6 août 1870 souligne
les atouts des Krupp et de leurs projectiles [3]. Christophe Pommier, conservateur
adjoint au département Artillerie du musée de l’Armée, insiste sur le rôle majeur
de la doctrine dans cette supériorité, au-delà du seul matériel [4].

**PROBABLE / à préciser — caractéristiques exactes par batterie.** Cette livraison
n’établit pas la dotation précise de chaque formation à Frœschwiller. Le canon
français reste volontairement une famille générique ; aucun modèle Trochu n’est
attribué aux unités du 6 août à partir de la comparaison générale de [1]. Les
modèles Krupp et les armements des autres contingents allemands doivent être
rattachés à l’ordre de bataille documenté avant le scénario historique.

## Transposition jouable

**ADAPTATION GAMEPLAY — toutes les valeurs du tableau du README.** Chassepot :
3 cases contre 2 pour Dreyse. Même puissance nominale à bout portant ; meilleure
conservation de l’effet à distance pour le Chassepot. Krupp : 2 PA par tir contre
3 pour le canon français, et moindre diminution des effets aux grandes distances.
Ces écarts de cadence et d’efficacité résument l’avantage dans l’exercice ; ils ne
sont pas des mesures historiques. Les deux artilleries portent au maximum à 6 cases.

Une batterie par camp permet d’essayer cette interaction sans ajouter tout le
système d’armes spéciales. Les 250 hommes d’une batterie sont un effectif de test,
pas une estimation historique ; aucune quantité de pièces n’est prétendue.
Les canons doivent être mis en batterie (1 PA) pour tirer et attelés (1 PA) pour
bouger. Les règles sont identiques quel que soit le camp utilisant l’arme.

La doctrine ne reçoit aucun bonus national de dégâts : concentration et placement
restent des décisions du joueur. Le commandement et l’IA l’intégreront ultérieurement.

## Incertitudes importantes

Ne pas confondre portée utile, portée maximale et graduation de hausse. [2]
mentionne une portée utile de 300–350 m ; aucune conversion universelle de ces
valeurs vers les hexagones n’est retenue ici. Les portées de ce prototype restent
abstraites et seront révisées avec l’échelle de la carte historique. Les sources
institutionnelles généralistes ne suffisent pas à fixer les caractéristiques
balistiques de chaque modèle ou les pertes attendues par demi-heure.

## Sources

[1] Archives nationales du monde du travail, 18 juin 2023, « La guerre de 1870 :
un désastre économique et social ? », section « Trochu contre Krupp, Chassepot
contre Dreyse ». Consulté : page complète.
https://archives-nationales-travail.culture.gouv.fr/Decouvrir/Dossiers-du-mois/La-guerre-de-1870-un-desastre-economique-et-social

[2] Ministère des Armées, Chemins de mémoire, « Le fusil Chassepot ».
Consulté : extraits indexés ; ouverture directe indisponible pendant cette session.
https://www.cheminsdememoire.gouv.fr/fr/le-fusil-chassepot

[3] Musée de la bataille du 6 août 1870, « Déclaration de guerre ».
Consulté : page complète.
https://www.6aout1870.com/docHisto.php?nom=declaration

[4] Christophe Pommier, novembre 2025, Fondation Napoléon, « Pourquoi la France
ne s’est-elle pas équipée de canons Krupp avant 1870 ? ». Consulté : page complète.
https://www.napoleon.org/histoire-des-2-empires/articles/une-chronique-de-christophe-pommier-pourquoi-la-france-ne-sest-elle-pas-equipee-de-canons-krupp-avant-1870/

## Mise à jour 0.4 — 24 septembre 2026

Les références historiques ci-dessus sont conservées. Aucune donnée nouvelle
relative à l’ordre de bataille ou à la carte historique n’est ajoutée.

**ADAPTATION GAMEPLAY** : riposte limitée à une fois par tour adverse, assaut à
3 PA, pertes bilatérales, récupération du moral, seuils de déroute et paramètres
révisés des armes. Le README et le pack JSON décrivent les valeurs effectivement
livrées. Les effets à distance sont plus marqués et les pertes de base ont été
réduites pour compenser les ripostes. La batterie Krupp conserve un avantage
abstrait à longue distance et par sa fréquence de tir.

Le facteur de pertes reçues des batteries (0,42), leurs puissances de contact et
les sons ne reposent pas sur des mesures historiques propres à Frœschwiller.
Les bruitages sont des créations synthétiques originales. Ces choix doivent être
révisés lors du passage de l’exercice fictif à la bataille documentée.


## Version 0.5 : abris et sons — ADAPTATION GAMEPLAY

Le retranchement est un abri sommaire abstrait : 2 PA, −25 % de pertes au tir,
+25 % de puissance de défense au contact. Ces chiffres ne sont pas des données
historiques et ne valident aucune position retranchée du 6 août 1870.

Les deux sources sonores CC0 sont créditées dans assets/sounds/CREDITS.txt :
https://freesound.org/people/mlsulli/sounds/234869/ et
https://freesound.org/people/qubodup/sounds/187767/. Elles servent à l’ambiance ;
aucune authenticité Chassepot/Dreyse/Krupp précise n’est revendiquée.

## Version 0.6 — adaptations de jeu

Les règles de moral et de victoire de la 0.5 sont remplacées par celles décrites
dans README.md : désorganisation vers 35 %, choc de déroute à 40 %, résultat
pondéré 40 contrôle final / 20 durée / 40 pertes militaires. Aucun de ces chiffres
ne revendique une mesure historique. Le contrôle persistant est une abstraction.
Les mentions numériques des sections de versions précédentes documentent leur état
historique de développement, pas les réglages actuellement actifs.

Musique « Slow World » (szegvari) et montage d’assaut (joelcarrsound,
florianreichelt), sources Freesound CC0 créditées dans assets/sounds/CREDITS.txt.
Le cri est issu d’une reconstitution médiévale et utilisé seulement comme ambiance
générique. Ni le son de l’assaut ni la musique ne sont attribués aux armées de 1870.

## Version 0.8 — ADAPTATION GAMEPLAY

Krupp : base de pertes 125 → 131 (+4,8 %), portée et cadence identiques. Ce réglage
répond au retour de jeu ; le pourcentage n’est pas une mesure historique.
Les réserves sur l’importance de la doctrine, source [4], restent applicables.
Ligne, Colonne et Tirailleurs sont des modes abstraits du régiment entier. Le coût
de changement en 1 PA et tous les coefficients du README sont des adaptations,
sans prétention de reproduire exactement les règlements ou proportions de compagnies.
Aucune donnée historique nouvelle de carte ou d’ordre de bataille n’est validée ici.

## Version 0.8.1 — ADAPTATION GAMEPLAY

L’infanterie des deux camps commence en Colonne dans les nouvelles parties de
l’exercice fictif. Ce choix de jouabilité ne valide aucune formation initiale
historique au 6 août 1870. Coefficients des formations et armements inchangés.


## Version 0.8.9 - adaptations de commandement et d'approvisionnement

Trois niveaux de munitions, trois salves par palier, facteur de tir 0,65 à Faibles,
rayons 4/6 cases, demi-récupération hors commandement et +1 PA au ralliement :
valeurs expérimentales, sans prétention de correspondre à des mesures historiques.
Les sources et points d'approvisionnement réels du 6 août ne sont pas établis.
Les accès du bord de carte et la formation par camp appartiennent seulement à
l'exercice fictif. L'encerclement n'inflige pas de pertes ou de déroute automatiques.
