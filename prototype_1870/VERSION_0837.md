# Version 0.8.37

V37 reprend V36 et ajoute la validation chronologique du scénario complet à 81 unités. Les sources V36 sont conservées dans un commit de référence local ; aucune modification des originaux.

## Changements

- Numéro d’application et badge : 0.8.37 ; code Android : 50.
- Test complet de 18 tours avec déploiement historique, calendrier réel des renforts, deux IA actives, difficulté moyenne et graine 187037.
- Validation de l’état après chaque commande, sauvegardes physiques périodiques et vérification de la reprise finale.
- Conservation des décisions et des indicateurs par demi-tour ; rejeu déterministe et analyse des occasions tactiques à partir des observations autorisées.
- Lanceur reproductible hors des sources, avec reprise de la simulation.

## Règles et sauvegardes

Moteur et doctrines IA identiques à V36. Charge à 2 PA, absence de bouton TIRER, confirmation par second toucher, PA et coûts d’actions, portées 6/8, score 60/20/20, carte 30×20 et durée de 18 tours conservés. Aucune nouvelle mécanique.

Les trois fichiers de scénario et les profils IA restent identiques à V35/V36. Empreintes et répertoire utilisateur inchangés. Les sauvegardes valides V35/V36 restent compatibles selon la validation renforcée introduite en V36 ; les états invalides ne sont pas rendus acceptables par un changement de version. Même identifiant Android et même certificat de test pour permettre une mise à jour sans désinstallation.

## Résultats et limites

Voir TESTS_V37.md et BATAILLE_V37.md pour les résultats finaux, les commandes et les anomalies observées. Une seule graine et une seule difficulté ne démontrent pas l’équilibrage général. Aucun test physique Android ni en émulateur.

Bilan final : 26 suites de régression (2 186 assertions) réussies ; bataille de 18 tours à 81 unités déclarées (80 entrées) ; rejeu intégral 2 753/2 753. Le contrôle initial d’arrivée de tous les renforts a échoué sur le QG Raoult bloqué ; attente légale vérifiée après correction de ce test. Trois objectifs prussiens, victoire mineure 77,36 contre 14,95. APK 0.8.37 code 50 compilé et signé, signature et alignement vérifiés ; aucun essai appareil.
