# Validation 0.8.14 — Sauer

- test_river0814.gd : 114/114 contrôles réussis. Toutes les frontières de rivière,
  infanterie / cavalerie / artillerie, coûts, arrêt après traversée, nouveau tour,
  invalidation atomique des chemins interdits, tir et riposte par-dessus la rivière,
  assaut sur pont, sauvegarde/rechargement/annulation, confidentialité de l’observation IA.
- Trois parties complètes IA contre IA : facile 204 décisions, moyen 257, difficile 240.
  Toutes les décisions légales, sauvegardes d’état valides, combats et fin de partie.
  Ces trois parties ne prouvent pas l’équilibrage ni la qualité optimale de l’IA.
  Dans ces essais l’IA a privilégié le pont ; le franchissement libre est validé
  mécaniquement et reste à évaluer tactiquement avec un joueur.
- test_support0813.gd : 59/59 contrôles de régression avec le pack 0.8.13 figé.
- test_ui0814.gd : 25/25 contrôles à 1280×720 et 25/25 à 1520×720.
  Sélection/désélection, double appui, coût du franchissement, arrêt, sauvegarde,
  deux camps, 600 correspondances case/écran, absence de chevauchement des bandeaux.
- Captures rendues sous OpenGL Mesa et examinées visuellement.
- Export APK signé v2/v3, package org.woerth1870.prototype.v02, versionCode 27,
  versionName 0.8.14. Certificat identique à la version 0.8.13.

Limites : pas de téléphone ni d’émulateur Android disponible pour lancer l’APK.
Durée, ergonomie réelle, batterie et équilibre restent à tester. Ce scénario est
un exercice fictif sur une carte provisoire, pas un ordre de bataille historique.
