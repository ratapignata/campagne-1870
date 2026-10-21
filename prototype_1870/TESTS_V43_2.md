# Tests V43.2 — Export JSON

Moteur réellement utilisé : Godot 4.5.1 stable officiel. Tests Linux isolés, sans téléphone Android.

| Suite exécutée | Résultat |
|---|---:|
| Export courant, relecture, intégrité original/.bak, annulation, pause/focus, protection des destinations, menu et dimensions tactiles | 28/28 |
| QG Raoult / renforts voisins | 32/32 |
| Référence Raoult | 42/42 |
| Cavalerie | 4096/4096 |
| Variante B | 1701/1701 |
| Charges successives réelles | 28/28 |
| Interface V43, reprise et migration | 30/30 |
| Sauvegardes sémantiques | 43/43 |
| Isolement/reddition | 45/45 |
| Lignes de vue | 40/40 |
| Mondes cachés / observation IA | 18/18 |

**Total : 6 103 contrôles fonctionnels réussis dans 11 suites.** Les relances d’une même suite ne sont pas additionnées.

Les comparaisons d’export portent sur tout le dictionnaire d’état et l’annulation, puis sur la relecture via le véritable chargeur. Elles incluent une modification non sauvegardée des paramètres et un déplacement légal. Original et copie de secours sont comparés octet par octet, depuis l’ouverture du menu jusqu’à la fermeture du message d’export. Le sélecteur desktop est ouvert puis annulé réellement. Les notifications Android de pause et de focus sont injectées au test ; ce n’est pas un essai Android réel.

Les premiers essais du panneau de confirmation ont détecté un débordement de libellé ; la construction du Label a été corrigée et les 28 contrôles finaux passent. Rendu réel Linux X11/OpenGL logiciel inspecté à 1280 × 720, menu et confirmation.

## Android

APK compilé et signé avec Godot 4.5.1 et le certificat de développement déjà utilisé. Version/code et certificat, signature, intégrité ZIP et alignement vérifiés (android_verification.json).

Non réalisés : installation et sélection de document sur appareil Android, contrôle tactile physique, test d’un fournisseur de documents non local. La disponibilité native à partir d’Android 10 et le contrat ACTION_CREATE_DOCUMENT sont vérifiés dans les sources officielles Godot 4.5.1 ; cela ne remplace pas un essai physique.

Le test UI peut émettre à la fermeture des avertissements ObjectDB/ressources concernant la musique Ogg (slow_world.ogg). Une relance verbale sur la V43.1 originale reproduit ces avertissements ; une relance V43.2 passe sans avertissement. Les résultats fonctionnels et les logs sont conservés séparément. Aucune fuite de partie ou modification des règles n’en est déduite. Le diagnostic de l’IA est livré séparément, sans correction du comportement dans cet APK.

## Reproduire

Importer avec Godot 4.5.1, puis :

```
godot --headless --path prototype_1870 --editor --import --quit
godot --headless --path prototype_1870 --script res://tests/v43_export/test_export.gd
```

Utiliser un répertoire utilisateur de test isolé (XDG_DATA_HOME sous Linux) pour ne pas modifier une partie personnelle avec les tests.
