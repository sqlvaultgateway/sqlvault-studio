# Publier SQLVault Studio 0.2.0

## 1. Dépôt GitHub public (compte sqlvaultgateway)
1. github.com › New repository › nom `sqlvault-studio` › Public › sans README › Create.
2. « uploading an existing file » › glisser **le contenu** du dossier `depot-sqlvault-studio`
   (README.md, LICENSE.txt, install.sh, install.ps1, docs/, lab/) › Commit changes.
   Important : la branche doit s'appeler `main` (valeur par défaut de GitHub), car les commandes d'installation pointent vers elle.
   Ne jamais y mettre le code source.

## 2. Release
1. Dans le dépôt : Releases › Draft a new release.
2. Tag : `v0.2.0` (Create new tag). Titre : `SQLVault Studio 0.2.0`.
3. Description : copier `NOTES-v0.2.0.md`.
4. Joindre les 6 fichiers du dossier `SQLVault Studio 0.2.0` (.exe, .dmg, 2 .zip, guide PDF, SHA256SUMS.txt).
5. Laisser **Set as the latest release** coché, puis Publish release.

## 3. Site
Le site (dossier `Documents/bdk/sqlvaultgateway.io`) contient la nouvelle section « Studio gratuit ».
Le publier comme prévu sur GitHub Pages (dépôt `sqlvaultgateway.github.io`) : téléverser tout le dossier.
Les boutons de téléchargement pointent vers la dernière release du dépôt `sqlvault-studio`.

## 4. Vérifier
- Ouvrir https://github.com/sqlvaultgateway/sqlvault-studio/releases/latest : les 6 fichiers sont là.
- Tester la ligne de commande sur le Mac : `curl -fsSL https://raw.githubusercontent.com/sqlvaultgateway/sqlvault-studio/main/install.sh | sh`
- Faire tester `install.ps1` par un collègue sous Windows (seul élément non testé ici).
- Télécharger le .dmg depuis cette page et l'installer sur le Mac.
- Version Windows : déjà validée par 3 testeurs.

## 5. Annoncer
Publication LinkedIn et groupes d'étudiants : lien du site, section « Studio gratuit ».
