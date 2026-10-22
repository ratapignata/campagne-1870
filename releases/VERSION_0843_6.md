# V43.6 — Faux échec d’export Android

Android 0.8.43.6, code 63. Correction du message d’échec qui pouvait apparaître après une écriture réussie.

## Cause et correction

Dans Godot 4.5.1 Android, FileAccessFilesystemJAndroid::get_error() renvoie ERR_FILE_EOF lorsque eof_reached() est vrai. Après l’écriture, la position peut être à la fin du fichier sans que l’écriture ait échoué. L’export introduit en V43.2 traitait tout résultat différent de OK comme un échec, avant même sa relecture intégrale. Source du moteur examinée : https://github.com/godotengine/godot/blob/4.5.1-stable/platform/android/file_access_filesystem_jandroid.cpp#L259

L’export autorise désormais OK ou ERR_FILE_EOF pour passer à la vérification obligatoire. Il n’annonce un succès que si le fichier externe est relu et que TOUT le contenu sauvegardé correspond au snapshot, checksum compris. Les autres erreurs sont refusées. L’enregistrement interne, son backup et l’état courant ne sont pas modifiés. Le sélecteur Android et le format JSON restent identiques.

Cela corrige une cause confirmée dans le code, reproduite avec un adaptateur de fichier simulant le retour EOF Android sur un vrai fichier écrit et relu sur serveur. La capture du téléphone ne permet pas d’exclure une autre cause d’échec (accès au dossier, fournisseur de documents ou espace disponible) ; aucun essai physique Android n’a été fait. Le JSON de la tentative antérieure peut déjà être présent dans Téléchargements.

## Vérifications exécutées — Godot 4.5.1

- Retour EOF simulé après écriture, relecture par le chargeur réel, fichier tronqué, protection original/backup et état courant : 9/9.
- Suite complète d’export : 28/28.
- Interface V43 : 30/30.

Total 67/67. APK compilé et signature vérifiée avec le certificat de développement existant. Pas de nouvelle simulation complète ni de test Android physique.

Aucune modification des règles ou de l’IA. Corrections V43.5 et affichage de la force conservés. Même application et sauvegardes ; installer par-dessus sans désinstaller. Puis Menu → Exporter la sauvegarde, choisir Téléchargements et Enregistrer. Retrouver le JSON dans Mes fichiers → Téléchargements.

Fichiers applicatifs modifiés : war_engine/platform/save_store.gd, project.godot, export_presets.cfg, packs/1870/fr.json. Test ajouté : tests/v43_export/test_android_eof.gd.
