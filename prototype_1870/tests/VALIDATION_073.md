# Validation — prototype 0.7.3

## Retouche 0.7.3 — 29 septembre 2026

Libellé du bouton : « Jouer la Prusse ». Comparaison exacte avec l’archive 0.7.2 :
le moteur, le pack de règles et le stockage sont inchangés. Dans les textes, seuls
le libellé du choix du camp et le numéro de version ont changé. Le libellé est plus court
que le précédent et utilise le même bouton. Aucun test fonctionnel supplémentaire
n’a été ajouté pour cette retouche ; les validations antérieures restent ci-dessous.



## Mise à jour 0.7.2 — 29 septembre 2026

145 assertions tactiles à 1280 × 720 et à 1520 × 720 : nom du camp Prussiens,
drapeau et nom sans suffixe dans la fiche, annulation masquée hors disponibilité,
appui long sur D et pelle. Les journaux courants sont `tests/results/touch_check072_1280.log`
et `touch_check072_1520.log`. Les anciennes validations ci-dessous sont conservées
comme historique, sans prétendre qu’elles ont été relancées pour cette retouche.

La nouvelle couverture vérifie notamment : aucun tir ni modification d’état en
maintenant une cible déjà visée ; aide sans blocage des actions ; relâchement sans
confirmation ; annulation par glissement, second doigt, interruption et événement
tactile annulé ; fonctionnement à la souris ; disparition automatique ; tir normal
toujours possible après consultation ; bouton Annuler apparaissant après un déplacement
réversible et disparaissant après annulation ou combat ; titres et terrain sans chevauchement.
Les bulles sont contrôlées à l’intérieur de la carte, sans débordement de texte.

Le pack de règles, le moteur et le stockage ont été comparés exactement à la 0.7.1 :
aucun changement. Le fichier de sauvegarde `save_v07.json` est conservé. Les textes
français sont externalisés ; les clés internes de camp restent stables pour compatibilité.
Les mentions affichées Allemands/ALL ont été remplacées par Prussiens/PRU.



## Mise à jour d’interface 0.7.1

122 assertions d’interface réussies à 1280 × 720 puis à 1520 × 720, sans erreur.
Journaux : `tests/results/touch_check071_1280.log` et `touch_check071_1520.log`.
Fiche ennemie testée en inspection directe et pendant la visée : terrain correct,
nom sans préfixe INF, arme et effectifs de la cible, tireur inchangé et rappelé au centre.
Aucun ordre militaire exposé en inspection ennemie seule, aucun changement d’état
par consultation ; retour à la fiche du tireur et confirmation du tir vérifiés.
Titres et terrain sans chevauchement ; captures inspectées à deux résolutions.
Drapeaux et chiffre de puissance contrôlés sur infanteries et canons des deux camps.

Les données du scénario, le moteur, le stockage et le nom du fichier de sauvegarde
ont été comparés exactement à la 0.7 : ils sont inchangés. Les 297 assertions moteur
ci-dessous proviennent de la validation 0.7 ; elles n’ont pas été relancées pour cette
retouche de présentation. Les captures actuelles figurent dans `captures/v071`.

## Validation antérieure du moteur 0.7.0


28 septembre 2026. Godot 4.5.1, Android paysage, français.

## Vérifications exécutées

| Ensemble | Réussites |
|---|---:|
| Moteur et sauvegardes | 40 / 40 |
| Trajets et tir | 35 / 35 |
| Armes et artillerie | 33 / 33 |
| Échanges et assauts | 45 / 45 |
| Moral et IA | 43 / 43 |
| Retranchement et import 0.4 | 34 / 34 |
| Régression 0.6 et import 0.5 | 33 / 33 |
| Révision 0.7 : relief, victoire, import 0.6 | 34 / 34 |
| Interface tactile à 1280 × 720 | 110 / 110 |
| Même interface à 1520 × 720 | 110 / 110 |

297 assertions moteur et 110 assertions d’interface distinctes : 407 au total.
La seconde résolution ne double pas le nombre d’assertions distinctes.
Les journaux sont dans `tests/results`. Les anciennes attentes ont été ajustées
pour les motifs détaillés de blocage et les nouvelles conditions de victoire majeure.

## Cas sensibles couverts

- Artillerie en plaine derrière un ami : tir et riposte impossibles.
- Batterie en hauteur au-dessus d’amis en contrebas : tir autorisé avec marge.
- Ami proche de la cible, marge insuffisante, crête, forêt, unité ennemie intermédiaire,
  cible en village et cible en hauteur. Les deux camps utilisent la même géométrie.
- Tentative de tir bloquée sans perte de PA ni mutation d’état ; double appui requis.
- Infanterie ne tirant pas au-dessus d’une unité amie, même depuis une hauteur.
- Victoire majeure seulement avec objectif final, écart ≥ 25, avantage net de pertes ≥ 10 points
  de pourcentage ; seuil juste au-dessous et au-dessus, camps inversés, effectifs inégaux.
- Calcul de résultat sans mutation d’état, pertes militaires incluant les prisonniers.
- Migration réelle du pack 0.6 par empreinte exacte : état, camp, contrôle, scores,
  retranchements, ripostes et dernier mouvement annulable conservés. Original intact.
- Sélection, désélection, déplacement, confirmation, annulation, zoom/déplacement de carte,
  tirs, ripostes, assaut, ralliement, retranchement, choix de camp, pause et reprise IA.
- Fiche : effectifs/PA et arme/riposte sans chevauchement ; textes longs contrôlés.
- Message de tour inférieur absent, indication supérieure conservée.
- Musique et sons séparés, préférences persistées, pause/reprise de l’audio.
- Bilan de bataille et explication du degré de victoire consultables sans action militaire.

Captures 0.7 contrôlées visuellement : canon, fiche désorganisé/retranché, bilan mineur
et bilan de reconquête. Certaines positions des captures sont aménagées pour les tests.

## Simulations IA

Quatre batailles complètes, graines 13, 71, 1870 et 2026 : 470 actions légales,
158 tirs et 36 assauts. Aucune partie bloquée ; états valides. Décision la plus lente :
91,9 ms sur cet environnement de bureau partagé, pas sur Android.
Durée de contrôle 5/1 dans les quatre parties. Pertes au combat FR/ALL :
2119/1868, 2120/1865, 2138/1870, 2172/1869 ; prisonniers français : 742, 744, 744, 747 ;
prisonniers allemands : 0. Ces essais ne démontrent pas un équilibre humain.

## APK 0.7 (validation antérieure)

- Godot 4.5.1, JDK 17, SDK 35, Build Tools 35.0.1.
- Paquet `org.woerth1870.prototype.v02`, versionCode 9, versionName 0.7.0.
- Android 7/API 24 minimum, cible API 35 ; ARMv7, ARM64, x86_64.
- Signature v2/v3 vérifiée, même certificat de développement que la version précédente.
- Pack, textes et crédits incorporés comparés exactement aux sources.
- Tests, captures et clé de développement exclus de l’APK ; aucune permission réseau.
- Taille : 87 171 312 octets.
- SHA-256 : `7533c2b80d92dbe4ca660999cb66dbde22f16785c2dcd27c7954b5ee4d62d671`.

## Limites

Pas d’exécution de cette version sur téléphone physique ni émulateur Android.
Les tests graphiques injectent des événements tactiles dans Godot sur bureau.
Installation, haut-parleurs, confort, chauffe, batterie et performances Android restent
à vérifier sur appareil. Ce scénario reste un exercice fictif de six tours, sans brouillard,
cavalerie, fatigue, munitions ni formations. Les coefficients du relief sont des adaptations
jouables, pas une reconstitution balistique. La musique Slow World n’a pas été remplacée.

## APK 0.7.1

VersionCode 10 ; même paquet et même certificat que la 0.7. Signature v2/v3 vérifiée.
Pack et textes incorporés comparés aux sources, tests et clé exclus de l’application.
Taille : 87171312 octets.
SHA-256 : `dff5164fc52c72144a85a1ea9b795c98ddc958560db1f1f3ac3a94252346bf71`.
Tests de cette version sur bureau uniquement ; téléphone physique encore à vérifier.

## APK 0.7.2

VersionCode 11 ; même paquet et même certificat que la 0.7.1. Signature v2/v3 vérifiée.
Pack et textes incorporés identiques aux sources ; tests et clé exclus de l’application.
Taille : 87179896 octets.
SHA-256 : `963f590b9a84e7c067d7d262b59299aa58c6bd652df8f4d2e10cbd6a3042e2f6`.
Validation graphique sur bureau ; confort et fonctionnement sur appareil Android à confirmer.

## APK 0.7.3

VersionCode 12, même paquet et certificat. Signature vérifiée ; libellé « Jouer la Prusse »
contrôlé directement dans les données de l’APK. Taille : 87179896 octets.
SHA-256 : `bed51e906cdfd2dca2cfc6019779825445dede38ad2ab3d2fb2570af97f82939`.
