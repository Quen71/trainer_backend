#!/usr/bin/env python3
"""
Script pour récupérer les fichiers du répertoire example/lib/ depuis le cache Cursor
"""
import json
import os
from pathlib import Path
from datetime import datetime
from collections import defaultdict

# Chemin vers l'historique Cursor
HISTORY_DIR = Path.home() / "Library/Application Support/Cursor/User/History"

all_recovered = []

print("🔍 Recherche des fichiers trainer_backend/example/lib/ dans le cache Cursor...\n")

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
        
        # Filtrer : seulement les fichiers de trainer_backend/example/lib/
        if 'trainer_backend/example/lib/' not in resource:
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
        if 'trainer_backend/example/lib/' in resource:
            rel_path = resource.split('trainer_backend/example/lib/')[1]
        else:
            continue
        
        all_recovered.append({
            'path': rel_path,
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

# Afficher chaque fichier
for path in sorted(latest_files.keys()):
    file_info = latest_files[path]
    content = file_info['content']
    
    print(f"\n📄 example/lib/{path}")
    print(f"   📅 Date: {file_info['date'].strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"   📏 Taille: {file_info['size']} caractères ({file_info['size'] // 1024}KB)")
    print(f"   📝 Source: {file_info['source']}")
    
    # Afficher un aperçu du contenu
    preview_lines = [l for l in content.split('\n')[:10] if l.strip()][:5]
    print(f"   📋 Aperçu:")
    for line in preview_lines:
        print(f"      {line[:85]}")

print("\n" + "=" * 100)
print(f"\n📊 RÉSUMÉ:")
print(f"   • {len(latest_files)} fichiers récupérés")
print("=" * 100)

# Sauvegarder les fichiers avec leur contenu complet
example_data = {}
for path, file_info in latest_files.items():
    example_data[path] = {
        'content': file_info['content'],
        'date': file_info['date'].strftime('%Y-%m-%d %H:%M:%S'),
        'timestamp': file_info['timestamp'],
        'source': file_info['source']
    }

output_file = Path('/Users/quentinlebreton/git/trainer_backend/.recovery_scripts/example_lib_ready_to_restore.json')
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(example_data, f, indent=2, ensure_ascii=False)

print(f"\n💾 Fichiers prêts à restaurer sauvegardés dans:")
print(f"   {output_file}")
print(f"\n✅ Prêt pour l'analyse et la comparaison!")



