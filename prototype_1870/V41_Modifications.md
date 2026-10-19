# V41 — Liste des modifications

Référence de départ : `1870_v0.8.41_IA_Optimisee_Experimental_Sources.zip`, SHA-256 `ec9a6e751dde58014c328716ca2f064363cad033a4fa195e88f78549729afaa6`.

## Correction de production

`packs/1870/regimental_trial.json`, table `save_migrations` uniquement : ajout de l'empreinte du scénario V40 `f73f6698da6070fe55ebff4eb0cafda06dbff64db994d557a054e82748835947` et de l'empreinte V41 expérimentale `f87600ad4fda5480cf80f0f34e3424da9b28fc3ecca8a3792c7a5af1f2e5bb9a`, toutes deux avec durée de 20 tours. Cela permet la reprise des sauvegardes compatibles malgré le changement d'empreinte du scénario. L'ancienne migration à 18 tours est conservée. Tests de migration V40 : 14/14 ; sauvegarde historique V37 : 5/5.

## Tests et documentation

Ajout des bancs V41 : équilibre des armes, migration, ancienne sauvegarde, comparaison avec témoin sans cache, temps CPU et simulation d'artillerie. Adaptation de la condition de fin des bancs de simulation aux tours définis par le scénario ; aucun changement de durée du jeu. Conservation des journaux et rapports JSON, y compris dépassements de délai et ancien test V38 en échec. Le banc complet à 81 unités est fourni mais n'a pas été exécuté jusqu'au bout dans cette validation.

Ajout des trois rapports de livraison, des instructions de reproduction et de compilation. Les deux rapports expérimentaux historiques portent une notice invitant à consulter les résultats finaux ; leurs affirmations initiales ne remplacent pas les mesures de cette livraison.

## Modifications déjà présentes dans les sources fournies

Version 0.8.41 / code Android 54 ; facteurs de tir à 2 hexagones Chassepot 0,60 et Dreyse 0,52 ; priorités d'artillerie ; mise en cache du rapport de soutien de la case de départ de l'unité active. Ces éléments proviennent de la V41 expérimentale, pas de la correction de finalisation. Le fichier `war_engine/ai/tactical_ai.gd` est identique octet pour octet à celui fourni.

## Règles conservées

Charge de cavalerie à 2 PA ; ripostes et leurs paramètres actuels ; scénario principal à 20 tours ; score 60/20/20 ; autres champs de règles inchangés. Aucun réglage d'équilibre supplémentaire, aucune modification du moteur de combat, aucun ajout de soutien défensif adjacent. Le gain de vitesse de l'optimisation demeure non confirmé.
