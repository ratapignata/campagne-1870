# Tests V43.14 réellement exécutés

Godot 4.5.1 officiel sous Linux. Tests graphiques sous Xorg et OpenGL Compatibility / Mesa llvmpipe. Pas de test physique Android.

## Résultat technique final

**21 suites headless, 2 450 / 2 450 contrôles réussis**, sans suite ignorée. Les deux suites nouvelles ont été relancées après les dernières corrections de présentation ; le total compte leurs résultats finaux une seule fois.

- V43.14 moteur/IA : 25/25. Batterie inactive sur objectif détenu, comparaison avec témoin V43.13, dételage/déplacement légaux puis déploiement et tir réels ; conservation d’une batterie avec cible ; absence de cible inventée ; Normal identique au témoin sur ce cas ; protection d’une avance seule en double coupure sous menace visible, maintien du score d’une avance soutenue et priorité à la restauration d’une liaison ; enregistrement, validation et reprise des diagnostics ; refus de métadonnées invalides ; compatibilité des événements anciens ; rapport réservé aux parties terminées et disposition ancienne des objectifs conservée.
- V43.14 interface : 14/14. Fiche double coupure, QG propre, plafond courant et plafond de renouvellement distincts, fenêtres Cmd./Ravit., diagnostic ennemi inaccessible, ancien journal sans cause inventée, en-tête réel Wœrth 2, ouverture du rapport complet sans mutation de l’état.
- 19 suites antérieures : 2 411/2 411. Variante B/combats 1 701 ; V43.13 30 ; engagement d’assaut 11 ; baseline V43.12/Normal/renforts 247 ; pont/bombardement 16 ; assaut avant repos 8 ; compatibilité IA 18 ; mondes cachés 18 ; isolement 45 ; ennemi contenu 25 ; renforts voisins 32 ; interface existante 30 ; export 28 ; Android EOF 9 ; cavalerie/village 20 ; fiche arme 18 ; présentation 102 ; journal redditions 11 ; Raoult 42.

Rendus canon : **53/53** ; infanterie : **54/54**, avec vérification de pixels sur plusieurs terrains et zooms. Ces animations n’ont pas changé.

Relecture du fichier réel fourni par l’utilisateur, export V43.13 T20 du 28 octobre : **3/3**. Chargement et validation réussis, résultat exact conservé, fichier original inchangé. Ce n’est pas une nouvelle simulation de sa bataille ni une reproduction de sa capture T6.

**Total de ces contrôles techniques : 2 560 / 2 560.** Les comparaisons de simulation ci-dessous sont comptées séparément.

Contrôle complémentaire des fichiers : scénario complet, profils courants et Normal, IA Normal gelée, règles de base, réseaux de soutien et rendu de carte identiques octet pour octet au commit V43.13 `dd05ff6`. Les changements du moteur concernent uniquement la métadonnée facultative des coupures et sa validation/normalisation.

## Comparaison reproductible, défense française active

Même état initial **T11, après dix tours entièrement simulés sous V43.13**, fourni dans `tests/fixtures/v4313_t11_simulation.json`. Graine initiale 18704311, style 0. Le témoin utilise `reference_ai_v4313.gd`, la variante utilise l’IA courante. Même politique française active : mouvement, tir, ralliement, retranchement et défense de Wœrth quand possible. Aucun changement de PA, effectif, position ou objectif entre les deux départs. Exécution de **deux tours entiers T11–T12**, jusqu’à T13 ; aucune phase écourtée, aucun plafond atteint.

| Mesure prussienne sur ces deux tours | V43.13 témoin | V43.14 |
|---|---:|---:|
| Tirs de canon | 28 | 28 |
| Autres tirs actifs | 25 | 25 |
| Assauts | 10 | 10 |
| Mouvements | 58 | 59 |
| Objectifs contrôlés en fin T12 | 3/3 | 3/3 |
| Pertes françaises cumulées hors prisonniers | 19 299 | 19 274 |
| Pertes prussiennes cumulées hors prisonniers | 11 997 | 11 996 |
| Prisonniers cumulés français / prussiens | 4 544 / 275 | 4 544 / 275 |

L’activité offensive est maintenue dans cet extrait. Les pertes presque identiques ne démontrent pas une amélioration générale de l’efficacité ; l’amélioration de batterie est démontrée par le cas ciblé, et la protection par les cas de décision ciblés. Il n’est pas affirmé que les quatre redditions prussiennes de la partie humaine auraient été évitées.

Témoin : **471/471** contrôles de légalité/état ; courant : **473/473**. Total séparé : **944/944**. Les deux phases françaises et les deux phases prussiennes ont terminé dans chaque exécution.

Durée cumulée des phases prussiennes sur ce serveur : témoin 395 419 ms ; courant 422 881 ms (environ +7 %). Médiane de décision : 2 446 ms / 2 540 ms ; maximum : 4 486 / 4 952 ms. Les processus ont tourné en parallèle sur la même machine avec d’autres vérifications : ces valeurs ne constituent pas un benchmark Android isolé. La recherche de missions de soutien ajoute un coût mesurable ; cache limité à la décision courante pour éviter de réévaluer chaque destination.

Ce test est une reprise d’un état de simulation, **pas une nouvelle partie chronologique de vingt tours**, ni une reproduction de la défense humaine ou une garantie sur toutes les graines. Les identifiants internes historiques `elsasshausen` désignent Wœrth dans cette nouvelle disposition.

Reproduction :

```sh
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v4314_checkpoint.gd -- reference /tmp/reference.json
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v4314_checkpoint.gd -- current /tmp/current.json
```

Employer Godot 4.5.1 et des XDG_CONFIG_HOME / XDG_DATA_HOME / XDG_CACHE_HOME accessibles en écriture. Les pilotes écrivent aussi les états finaux séparés ; les mesures publiées concernent un scénario automatisé, aucune sauvegarde personnelle complète n’est fournie.

## Contrôle visuel et Android

Ouverture réelle des nouvelles fiches de liaison et du rapport final avec le rendu du jeu : texte lisible, contenu défilable, bouton de retour accessible. Trois captures effectuées ; seule la fiche synthétique de liaison est jointe aux preuves publiques. Le rapport de la sauvegarde réelle a également été produit en mémoire sans modifier son état.

APK **0.8.43.14**, code **71**, application **org.woerth1870.prototype.v02**. Export Android réussi ; signature v2/v3 vérifiée, même certificat SHA-256 `57c00efad8c9b822d4a1d63238a4137b9afc97b6e9248076f4f54bb292ae846c`. Le nouveau module de rapport et les textes actualisés sont présents dans l’APK.

Le journal d’export se termine par un échec de lancement d’ADB dans le dossier personnel non inscriptible après la compilation/signature réussies. Aucune installation ni exécution sur appareil Android effectuée.

## Échecs rencontrés et limites restantes

Les premières assertions du nouveau cas de batterie échouaient parce que le pilote n’incluait pas explicitement l’ennemi dans l’observation sans brouillard, et plaçait un ami dans la ligne testée. L’observation et la géométrie de ce cas ont été corrigées ; un véritable tir après déplacement est maintenant exécuté. Le premier test de reprise de métadonnées a aussi révélé l’absence de normalisation de la nouvelle distance : conversion numérique ajoutée et reprise exacte vérifiée. Aucun test de combat existant supprimé ni assoupli.

La fermeture de l’ancienne suite UI émet encore des avertissements ObjectDB / ressources utilisées, malgré ses assertions réussies. Le rendu logiciel signale le VSync non pris en charge. Ces avertissements sont distincts des nouveaux écrans vérifiés.

Non exécutés : campagne complète T1–T20 sous V43.14, reproduction exacte T6 de la partie humaine, validation statistique sur plusieurs graines et essais physiques Android. Les nouvelles protections n’empêchent pas une unité d’être isolée par une action ennemie ultérieure.
