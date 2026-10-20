# Tests V43.1 — 20 octobre 2026

Godot 4.5.1 réellement utilisé. Huit suites relancées, toutes réussies :

| Banc | Résultat |
|---|---:|
| Nouvelle arrivée voisine, Raoult réel, deux camps, sauvegarde et migration V43 | 32/32 |
| Interface et reprise de sauvegardes | 30/30 |
| Variante B et frontières des vingt tours | 1701/1701 |
| Diagnostic historique Raoult sur le pack V42 archivé | 42/42 |
| Sauvegardes | 43/43 |
| Renforts et dégagement d’entrée amie | 5/5 |
| Isolement et reddition | 45/45 |
| Contrat et roster Lot 8 | 301/301 |

Total : 2 199 contrôles réussis. La dernière passe de l’arrivée voisine ajoute quatre contrôles à la première passe de 28/28 : migration d’une ancienne sauvegarde V43 et symétrie des camps.

Les tests couvrent : entrée libre ; ennemi sur l’entrée ; arrivée réelle au tour 3 sur une case adjacente ; ennemi inchangé ; calendrier et phase ; choix déterministe ; terrain infranchissable ; rivière non pontée ; six voisins occupés ; entrée amie ; deux renforts simultanés sans empilement ; sauvegarde/reprise de la nouvelle position ; absence de nouvelle apparition d’un renfort déjà entré ; reprise d’une ancienne partie V43 bloquée puis arrivée au prochain tour français.

APK exporté avec les templates officiels Godot 4.5.1. Signature, paquet, version/code 58, intégrité ZIP, alignement 16 Ko, bibliothèques ELF 64 bits et présence de la licence de police vérifiés. Même certificat de développement. Le message adb relatif à /home/agent/.android n’empêche pas l’export ; aucun appareil n’est connecté.

Aucun nouvel essai sur téléphone, rendu graphique ou simulation complète de bataille n’a été exécuté pour cette correction. Les rendus et campagnes cités dans TESTS_V43.md sont les résultats antérieurs de V43, pas des campagnes V43.1. Les animations et règles de combat n’ont pas été modifiées.

Les résultats exécutés figurent dans tests/results/0843_1. Les preuves de l’extraction propre et de la publication sont vérifiées avant livraison.
