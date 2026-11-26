# V43.17 — France, artillerie et essai Chassepot 4

26 novembre 2026. Base V43.16 + Graphisme12 (29008a8), branche séparée `v43-17-france-difficile`. Version d’essai, sans fusion avec main ou les branches précédentes.

## Modes

France Normal : code de l’ancienne France Difficile V43.16 figé dans `v4316_ai.gd` et `v4316_french_defence.gd`. Seul le chemin de préchargement de la défense figée est redirigé. Même style et observation : mêmes ordres et reprise de déplacement. Les armes communes de cette variante comportent toutefois le Chassepot à quatre hexagones : le déroulement complet n’est donc pas annoncé identique à l’ancienne partie à portée trois.

France Difficile : positions préparées avant le contact, maintien de réserves proportionné aux menaces observées, protection des axes arrière/QG, repli plus tôt des positions secondaires coupées et maintien plus prudent de l’objectif majeur au premier constat. Les seuils d’isolement/déroute/reddition restent ceux du moteur. Une vraie fermeture ou le deuxième constat peut déclencher un décrochage ; aucune immunité.

Les canons prêts passent en priorité avant l’infanterie. Déploiement réel, éventuellement préparation d’un tir au tour suivant à trois PA ; réorientation des batteries silencieuses vers un engagement observé soutenu par l’infanterie ; recherche d’une ligne de tir à distance, conservation d’une position utile et repli avant un contact trop dangereux. Le tir consomme toujours trois PA, le déploiement/attelage un PA ; portée française six, Krupp huit. Munitions et repos suivent les règles existantes. Pas de quota, de tir gratuit ou de PA ajoutés.

Contre-attaques locales de réserves : mêmes seuils de rapport de force, assauts et coûts ; au plus deux formations disponibles, sans prélever le premier défenseur de chaque objectif. Les petites incursions ne mobilisent plus systématiquement deux régiments entiers.

Prusse Normal et Difficile : doctrines/profils conservés. Quand l’humain joue les Prussiens, le calendrier avancé joué en V43.16 est commun aux deux difficultés françaises, afin que le nouveau Normal reste une référence cohérente. Quand l’humain joue les Français, le calendrier prussien antérieur Normal/Difficile est préservé. Aucune unité ni aucun effectif ajouté.

## Variante Chassepot

Tir actif de l’infanterie française : quatre hexagones pour les humains et l’IA, Normal et Difficile. Coût inchangé deux PA. Coefficients de distance : 1 / 0,60 / 0,36 / 0,216 ; les trois premiers restent identiques. La quatrième bande est expérimentale, pas une portée historique en mètres certifiée. LOS, relief et brouillard restent obligatoires. Les escortes de QG conservent leur portée actuelle.

Riposte Chassepot maintenue à trois hexagones grâce à une limite explicite ; toutes les autres portées de riposte et leurs règles restent identiques. Aucun nouveau soutien défensif ou bouton TIRER.

## Sauvegardes et installation

Même format JSON/checksum. Empreinte du nouveau scénario différente (portée changée), ancienne empreinte V43.16 explicitement compatible. Chargement et sauvegarde de la partie personnelle vérifiés en copie, original intact et score final conservé. Le champ optionnel de durée des parties terminées est normalisé en entier pour permettre un aller-retour canonique. Une sauvegarde reprise utilise les règles du nouveau build ; une partie achevée ne gagne aucun tour supplémentaire.

APK `0.8.43.17-g2d12`, code 14, même paquet `org.woerth1870.prototype.graphics2dexp`, certificat et répertoire de données que V43.16 Graphisme12. Installer par-dessus sans désinstaller. Pour comparer les difficultés, commencer une nouvelle partie Prussiens / Normal ou Difficile. La version classique et l’introduction BD restent séparées.

Graphisme12 conservé, carte/terrains/effectifs/renforts déclarés identiques, vingt tours et score 60/20/20 conservés. Charge deux PA, variante d’assaut 0,90, animations et interface inchangées hors textes explicatifs/version. Voir le rapport des mesures : les gains de tirs ne constituent pas une garantie universelle de meilleure défense territoriale. Aucun essai physique Android.
