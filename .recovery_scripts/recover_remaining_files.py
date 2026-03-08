#!/usr/bin/env python3
"""
Script pour récupérer les fichiers restants depuis le cache Cursor:
- lib/clients/
- lib/trainer_backend.configuration.dart
- lib/trainer_backend.dart
- README.md
"""
import json
import os
from pathlib import Path
from datetime import datetime
from collections import defaultdict

# Chemin vers l'historique Cursor
HISTORY_DIR = Path.home() / "Library/Application Support/Cursor/User/History"

# Fichiers cibles
TARGET_PATTERNS = [
    'trainer_backend/lib/clients/',
    'trainer_backend/lib/trainer_backend.configuration.dart',
    'trainer_backend/lib/trainer_backend.dart',
    'trainer_backend/README.md',
]

all_recovered = []

print("🔍 Recherche des fichiers restants dans le cache Cursor...\n")

# Parcourir tous les dossiers d'historique
for history_folder in HISTORY_DIR.iterdir():
    if not history_folder.is_dir():
        continue
    
    entries_file = history_folder / "entries.json"
    if not entries_file.exists():
        continue
    
    try:
        with open(entries_file, 'r') as f:
            data = json.load(f)
        
        resource = data.get('resource', '')
        
        # Vérifier si le fichier correspond à un des patterns
        match = False
        for pattern in TARGET_PATTERNS:
            if pattern in resource:
                match = True
                break
        
        if not match:
            continue
        
        # Exclure les fichiers générés
        if resource.endswith('.g.dart'):
            continue
        
        entries = data.get('entries', [])
        if not entries:
            continue
        
        # Trouver l'entrée la plus récente
        latest_entry = max(entries, key=lambda e: e.get('timestamp', 0))
        
        timestamp = latest_entry.get('timestamp', 0) / 1000
        file_date = datetime.fromtimestamp(timestamp)
        
        # Récupérer le contenu COMPLET du fichier
        entry_id = latest_entry.get('id')
        content_file = history_folder / entry_id
        
        if not content_file.exists():
            continue
        
        with open(content_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Ignorer les fichiers vides
        if len(content) <= 1:
            continue
        
        # Extraire le chemin relatif
        rel_path = None
        if 'trainer_backend/lib/clients/' in resource:
            rel_path = 'clients/' + resource.split('trainer_backend/lib/clients/')[1]
            category = 'lib/clients/'
        elif 'trainer_backend/lib/trainer_backend.configuration.dart' in resource:
            rel_path = 'trainer_backend.configuration.dart'
            category = 'lib/'
        elif 'trainer_backend/lib/trainer_backend.dart' in resource:
            rel_path = 'trainer_backend.dart'
            category = 'lib/'
        elif 'trainer_backend/README.md' in resource:
            rel_path = 'README.md'
            category = 'root/'
        else:
            continue
        
        all_recovered.append({
            'path': rel_path,
            'category': category,
            'full_resource': resource,
            'content': content,
            'date': file_date,
            'timestamp': timestamp,
            'source': latest_entry.get('source', 'Unknown'),
            'size': len(content)
        })
        
    except Exception as e:
        continue

print(f"✅ {len(all_recovered)} versions de fichiers trouvées\n")

# Grouper par chemin et ne garder que la version la plus récente de chaque fichier
files_by_path = defaultdict(list)
for file_info in all_recovered:
    path = file_info['path']
    files_by_path[path].append(file_info)

latest_files = {}
for path, versions in files_by_path.items():
    # Trier par timestamp décroissant
    versions.sort(key=lambda x: x['timestamp'], reverse=True)
    latest = versions[0]
    latest_files[path] = latest

print(f"📋 {len(latest_files)} fichiers uniques identifiés\n")
print("=" * 100)

# Grouper par catégorie
categories = defaultdict(list)
for path, file_info in latest_files.items():
    categories[file_info['category']].append(path)

# Afficher par catégorie
for category in sorted(categories.keys()):
    paths = categories[category]
    print(f"\n\n📁 {category}")
    print("=" * 100)
    
    for path in sorted(paths):
        file_info = latest_files[path]
        content = file_info['content']
        
        print(f"\n📄 {category}{path}")
        print(f"   📅 Date: {file_info['date'].strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"   📏 Taille: {file_info['size']} caractères")
        print(f"   📝 Source: {file_info['source']}")
        
        # Afficher un aperçu du contenu
        preview_lines = [l for l in content.split('\n')[:8] if l.strip()][:4]
        print(f"   📋 Aperçu:")
        for line in preview_lines:
            print(f"      {line[:85]}")

print("\n" + "=" * 100)
print(f"\n📊 RÉSUMÉ:")
print(f"   • {len(latest_files)} fichiers récupérés")
print("=" * 100)

# Sauvegarder les fichiers avec leur contenu complet
remaining_data = {}
for path, file_info in latest_files.items():
    remaining_data[path] = {
        'content': file_info['content'],
        'category': file_info['category'],
        'date': file_info['date'].strftime('%Y-%m-%d %H:%M:%S'),
        'timestamp': file_info['timestamp'],
        'source': file_info['source']
    }

output_file = Path('/Users/quentinlebreton/git/trainer_backend/.recovery_scripts/remaining_files_ready_to_restore.json')
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(remaining_data, f, indent=2, ensure_ascii=False)

print(f"\n💾 Fichiers prêts à restaurer sauvegardés dans:")
print(f"   {output_file}")
print(f"\n✅ Prêt pour l'analyse et la comparaison!")



