#!/usr/bin/env python3
"""
Analyser les fichiers récupérés et ne garder que la version la plus récente de chaque fichier
"""
import json
import os
from pathlib import Path
from datetime import datetime
from collections import defaultdict

# Charger le rapport
report_file = Path('/Users/quentinlebreton/git/trainer_backend/recovered_models_report.json')
with open(report_file, 'r', encoding='utf-8') as f:
    all_files = json.load(f)

# Grouper par chemin et garder seulement la version la plus récente
files_by_path = defaultdict(list)
for file_info in all_files:
    path = file_info['path']
    files_by_path[path].append(file_info)

# Pour chaque fichier, garder la version la plus récente
latest_files = {}
for path, versions in files_by_path.items():
    # Trier par timestamp décroissant
    versions.sort(key=lambda x: x['timestamp'], reverse=True)
    latest = versions[0]
    
    # Ignorer les fichiers vides (1 caractère)
    if 'Taille: 1 caractères' in str(latest):
        continue
    
    latest_files[path] = latest

# Trier par chemin
sorted_paths = sorted(latest_files.keys())

print("=" * 80)
print("📋 FICHIERS RÉCUPÉRÉS - VERSION LA PLUS RÉCENTE")
print("=" * 80)
print()

# Grouper par sous-dossier
categories = {
    'api': [],
    'auth/enums': [],
    'auth/state': [],
    'auth': [],
    'history': [],
    'training/converters': [],
    'training/enums': [],
    'training/parameters': [],
    'training': [],
    'root': []
}

for path in sorted_paths:
    if path.startswith('api/'):
        categories['api'].append(path)
    elif path.startswith('auth/enums/'):
        categories['auth/enums'].append(path)
    elif path.startswith('auth/state/'):
        categories['auth/state'].append(path)
    elif path.startswith('auth/'):
        categories['auth'].append(path)
    elif path.startswith('history/'):
        categories['history'].append(path)
    elif path.startswith('training/converters/'):
        categories['training/converters'].append(path)
    elif path.startswith('training/enums/'):
        categories['training/enums'].append(path)
    elif path.startswith('training/parameters/'):
        categories['training/parameters'].append(path)
    elif path.startswith('training/'):
        categories['training'].append(path)
    else:
        categories['root'].append(path)

# Afficher par catégorie
for category, paths in categories.items():
    if not paths:
        continue
    
    print(f"\n📁 {category}/")
    print("-" * 80)
    
    for path in paths:
        file_info = latest_files[path]
        print(f"\n  ✓ {path}")
        print(f"    📅 Date: {file_info['date']}")
        print(f"    📝 Source: {file_info['source']}")
        
        # Vérifier si le contenu semble correct (pas de mélange avec session_log)
        preview = file_info['content_preview']
        if 'session_log' in path.lower():
            status = "✅ OK"
        elif 'sealed class SessionLog' in preview and 'session_log' not in path.lower():
            status = "⚠️  ATTENTION: Contenu semble être session_log.dart (mélange)"
        else:
            status = "✅ OK"
        
        print(f"    {status}")

print()
print("=" * 80)
print(f"📊 RÉSUMÉ: {len(latest_files)} fichiers uniques récupérés")
print("=" * 80)

# Sauvegarder la liste des fichiers valides
valid_files = {}
for path, file_info in latest_files.items():
    preview = file_info['content_preview']
    # Exclure les fichiers qui ont du contenu mélangé
    if 'sealed class SessionLog' in preview and 'session_log' not in path.lower():
        continue
    valid_files[path] = file_info

print(f"\n✅ Fichiers valides (sans mélanges): {len(valid_files)}")
print()

# Sauvegarder pour la prochaine étape
output = Path('/Users/quentinlebreton/git/trainer_backend/valid_models.json')
with open(output, 'w', encoding='utf-8') as f:
    json.dump(valid_files, f, indent=2, ensure_ascii=False)

print(f"💾 Fichiers valides sauvegardés dans: {output}")

