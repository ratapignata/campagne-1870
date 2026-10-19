# 1870 : Frœschwiller-Wœrth V41 — Rapport de tests

Vérifications des 14 et 15 octobre 2026. Version applicative 0.8.41, code Android 54.

## Résultat et périmètre

Les contrôles automatisés décrits ci-dessous passent. Une anomalie de compatibilité des sauvegardes a été corrigée. Le code IA fourni reste inchangé : son cache produit les mêmes décisions et classements sur les cas testés, mais un gain stable de vitesse n'est pas démontré. Cette livraison ne constitue pas une validation sur appareil Android.

Environnement : Godot 4.5.1 stable officiel, Linux, exécution sans interface graphique. Les résultats de la première séance ont été récupérés depuis l'archive de point d'étape ; les essais qui n'avaient pas de résultat final conservé ne sont pas comptés comme réussis. La simulation Normal et les scénarios tardifs ont été relancés le 15 octobre. Aucun test physique Android, aucun test dans un émulateur et aucune simulation complète de 20 tours à 81 unités n'ont été effectués.

## Intégrité et règles préservées

L'archive de point d'étape a passé le contrôle CRC. Comparaison intégrale avec l'archive expérimentale fournie : aucun fichier manquant ; seules deux notices historiques et la table `save_migrations` du scénario principal diffèrent parmi les fichiers d'origine. Les tests et rapports sont ajoutés séparément. Aucun correctif de syntaxe ou de compilation GDScript n'a été nécessaire. L'import Godot final se termine avec le code 0.

| Règle | Valeur conservée |
| --- | --- |
| Charge de cavalerie | 2 PA, soit 8 unités internes |
| Ripostes | Paramètres existants : 1 réaction, facteur 0,65 |
| Batterie prise pour cible | Facteur existant 0,42 |
| Durée du scénario principal | 20 tours |
| Score | Contrôle final 60 / durée de contrôle 20 / bilan militaire 20 |
| Soutien défensif adjacent | Aucun ajout |

Les anciennes sauvegardes terminées à 18 tours gardent leur durée historique par le mécanisme existant. Les fichiers du moteur de combat et le code IA de production sont conservés.

## Suites de régression

26 suites héritées et l'import Godot réussis. Elles couvrent sauvegardes, lignes de vue, isolation des packs, règles, interface, mondes cachés, artillerie, armes, chemins de combat, échanges et assauts, formations, positions, objectifs multiples, cavalerie, renseignement, soutien, compatibilité IA, rivières, moral et brouillard de guerre. Le test des rivières a utilisé son option `--quick` ; cela ne représente pas son balayage exhaustif.

Trois essais ont d'abord atteint leur délai de 180 secondes : artillerie, moral/IA et brouillard. Leurs relances avec des limites plus larges réussissent ; les journaux initiaux restent disponibles. Six compléments V38/V39 réussissent : budget d'artillerie, renforts, interface, lot 1, lot 2 et opportunités de capture. Le lot 2 teste notamment l'activation de l'artillerie avant l'infanterie en Normal et Difficile, puis une continuation légale.

Le vieux test V38 de sauvegarde échoue avec son constructeur sans table de migration. Sa version adaptée `tests/v41/test_legacy_save.gd` utilise le mécanisme actuel et normalise les types numériques JSON lors de la comparaison : 5/5 contrôles réussis sur la sauvegarde V37 fournie. Ce changement porte sur le test, pas sur les règles.

## Tirs à deux hexagones

Conditions identiques : 1 000 hommes, ligne, moral stable, terrain découvert et plat, pas de retranchement, munitions disponibles. 5 000 tirs par arme, puis 256 échanges complets par camp initiateur. 1 540/1 540 assertions réussies.

| Mesure | Chassepot | Dreyse |
| --- | --- | --- |
| Facteur à distance 2 fourni en V41 | 0,60 | 0,52 |
| Pertes moyennes par tir | 65,9888 | 57,2000 |
| Minimum–maximum | 59–73 | 51–63 |
| Dégâts moyens, échange initié par ce camp | 65,7539 | 56,9883 |
| Pertes moyennes subies en riposte | 37,2070 | 42,8828 |

Dans ce cas contrôlé, le Chassepot garde un avantage moyen de 15,37 %. Ces résultats quantifient le changement expérimental fourni (anciens facteurs V40 : 0,65 et 0,50). Ils ne prouvent pas un équilibre global des chances de victoire. Aucun rééquilibrage supplémentaire n'a été appliqué.

## Artillerie et simulations de 20 tours

Deux simulations appariées, graine 187038 : camp français en Normal ; camp prussien respectivement en Normal et Difficile. Carte originale de 30 × 20 hexagones, déploiement synthétique, 14 unités, aucun renfort programmé. Chaque commande est acceptée par le moteur et chaque état résultant est validé. Les durées ci-dessous sont des durées de simulation sur l'hôte, pas des mesures comparables de performance entre difficultés.

| Difficulté prussienne | Actions totales | Assertions | Tirs d'artillerie prussienne | Déplacements d'artillerie | Déploiements | Fins de phase avec tir légal inutilisé | Durée |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Normal | 501 | 1003/1003 | 36 | 2 | 2 | 0 | 855.2 s |
| Difficile | 437 | 875/875 | 39 | 1 | 1 | 0 | 596.8 s |

Les deux parties se terminent au tour 20. Les rapports JSON contiennent les actions, cibles, captures, pertes, scores et états aux limites de phase. Le diagnostic de tir inutilisé porte uniquement sur les unités pouvant encore agir en fin de phase ; il ne prouve pas l'optimalité tactique de chaque décision.

Scénarios synthétiques de fin de partie, sur le même banc réduit :

| Scénario | Tour de départ | Tours achevés | Actions | Résultat |
| --- | --- | --- | --- | --- |
| C_turn12 | 12 | 9 | 208 | Réussi |
| E_final | 17 | 4 | 122 | Réussi |

Les premiers essais de graine 187037 ont atteint la limite de 1 200 secondes après le tour 19 en Normal et le tour 17 en Difficile. Leurs relances étaient incomplètes au moment du point d'étape et ne sont pas validées. L'ancien essai Normal 187038 et l'ancien C_turn12 n'avaient pas de résultat final conservé ; les nouvelles exécutions complètes ci-dessus les remplacent. Les journaux partiels sont conservés, sans être assimilés à des échecs de règles ni à des réussites.

## Compatibilité des sauvegardes

Le changement des facteurs d'armes modifie l'empreinte du scénario. Le fichier expérimental n'autorisait pas l'empreinte V40 ; après la correction, il autorise explicitement les empreintes V40 et V41 expérimentale pour une durée de 20 tours. L'entrée historique à 18 tours reste en place.

Le test de migration passe 14/14 contrôles : sauvegarde V40 en cours et terminée, conservation du tour, de la difficulté, du score, puis réenregistrement et relecture V41. La comparaison des sources ne trouve aucun autre champ de scénario modifié. Les empreintes et tables avant/après figurent dans `source_comparison.json`.

## IA et limites de validation

80/80 décisions et 80/80 classements complets de candidats identiques avec et sans cache ; 326/326 assertions, comprenant six cas sur l'effectif complet initial avec une pression de tour synthétique 1/12/20. Un second banc de mesures processeur passe 17/17 assertions. Le témoin conserve les priorités d'artillerie V41 : seule la mise en cache est retirée. Ce test n'est donc pas une comparaison de stratégie V40 contre V41.

Le rapport de performances détaille les mesures et leurs résultats défavorables ou variables. Aucune accélération stable n'est déclarée validée. La couverture ne démontre ni l'optimalité de l'IA, ni l'absence de toute régression possible sur une campagne complète.

## Reproduction et preuves

Les scripts sont dans `tests/v41/`, les preuves de cette livraison dans `tests/results/0841/`. Les résultats plus anciens placés ailleurs dans `tests/results/` restent des archives historiques. Lire `tests/v41/README.md` pour les commandes. Le fichier `run_checks.py` lance aussi des graines supplémentaires : leur présence dans le script ne signifie pas qu'elles ont toutes été validées dans cette livraison.

L'archive intermédiaire des vérifications est produite et livrée avant l'export Android. Elle ne contient pas l'APK.

## APK livré

Export Android signé en mode debug avec la clé de développement du projet. Godot 4.5.1, Java 17 et Android build-tools 35.0.1. Nom `1870_v0.8.41.apk`, taille 88,114,747 octets. Package `org.woerth1870.prototype.v02`, version 0.8.41, code 54. Android minimum API 24, cible API 35 ; architectures armeabi-v7a, arm64-v8a et x86_64.

Signature vérifiée par `apksigner` ; alignement vérifié par `zipalign -c -P 16 4` ; archive ZIP vérifiée. Les tests et la clé de développement ne sont pas embarqués dans l'APK. Empreinte du certificat SHA-256 : `57c00efad8c9b822d4a1d63238a4137b9afc97b6e9248076f4f54bb292ae846c`. Cette empreinte correspond à celle vérifiée précédemment pour la V40.

SHA-256 de l'APK : `e69e18614032c5d23e80366634a1f7304c1af7dfafb2619d8be0d1dafbd101f2`. Ces contrôles établissent la structure, l'identité et la signature du paquet ; ils ne remplacent pas une installation et un lancement sur appareil. Aucun test Android physique ou émulé n'a été réalisé.
