# Validation v0.8.33

Godot 4.5.1 headless, Android debug APK signé avec la clé de développement conservée.
- Liaisons, PA, reddition, sauvegarde : 21/21.
- Surbrillance QG et cibles infanterie, obstacle, PA : 6/6.
- Profils IA promus, décisions légales, sauvegardes : 70/70.
- Compatibilité sauvegarde IA et indépendance des ennemis cachés : 18/18.
- Scénario régimentaire, renforts, déroulement et sauvegardes : 181/181.
- Régression règles récentes : 119/119.
- Interface, choix des camps, reprise : 27/27.
- Benchmark première décision du scénario : environ 0,66–0,96 s dans cet environnement serveur, pas une mesure Android.

Ancien test complet IA 0.8.9 : son attente de différence entre ancien Facile et Difficile sur une charge n’est plus pertinente après promotion des profils. Les erreurs de roundtrip initiales ont été corrigées par normalisation des compteurs et couvertes par les 18 contrôles de compatibilité.
Pas de validation visuelle rendue ni de test sur appareil Android disponible. Équilibrage à confirmer en partie.
