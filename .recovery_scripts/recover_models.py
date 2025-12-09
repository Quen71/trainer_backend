#!/usr/bin/env python3
"""
Script pour récupérer les fichiers du répertoire lib/models/ depuis le cache Cursor
"""
import json
import os
import shutil
from pathlib import Path
from datetime import datetime

# Chemin vers l'historique Cursor
HISTORY_DIR = Path.home() / "Library/Application Support/Cursor/User/History"

# Fichiers récupérés avec leurs métadonnées
recovered_files = []

print("🔍 Recherche des fichiers trainer_backend/lib/models/ dans le cache Cursor...\n")

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
        
        # Filtrer : seulement les fichiers de trainer_backend/lib/models/
        if 'trainer_backend/lib/models/' not in resource:
            continue
        
        # Exclure les fichiers générés
        if resource.endswith('.g.dart'):
            continue
        
        # Exclure .DS_Store
        if '.DS_Store' in resource:
            continue
        
        entries = data.get('entries', [])
        if not entries:
            continue
        
        # Trouver l'entrée la plus récente
        latest_entry = max(entries, key=lambda e: e.get('timestamp', 0))
        
        timestamp = latest_entry.get('timestamp', 0) / 1000  # Convertir ms en secondes
        file_date = datetime.fromtimestamp(timestamp)
        
        # Récupérer le contenu du fichier
        entry_id = latest_entry.get('id')
        content_file = history_folder / entry_id
        
        if not content_file.exists():
            continue
        
        with open(content_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Extraire le chemin relatif
        if 'trainer_backend/lib/models/' in resource:
            rel_path = resource.split('trainer_backend/lib/models/')[1]
        else:
            continue
        
        recovered_files.append({
            'path': rel_path,
            'full_resource': resource,
            'content': content,
            'date': file_date,
            'timestamp': timestamp,
            'source': latest_entry.get('source', 'Unknown')
        })
        
    except Exception as e:
        continue

# Trier par chemin
recovered_files.sort(key=lambda x: x['path'])

print(f"✅ {len(recovered_files)} fichiers trouvés dans le cache Cursor\n")
print("=" * 80)

# Afficher les fichiers récupérés
for i, file_info in enumerate(recovered_files, 1):
    print(f"\n📄 Fichier {i}/{len(recovered_files)}: lib/models/{file_info['path']}")
    print(f"   📅 Date: {file_info['date'].strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"   📝 Source: {file_info['source']}")
    print(f"   📏 Taille: {len(file_info['content'])} caractères")
    
    # Afficher les premières lignes pour vérification
    lines = file_info['content'].split('\n')[:5]
    print(f"   📋 Aperçu:")
    for line in lines:
        if line.strip():
            print(f"      {line[:80]}")

print("\n" + "=" * 80)
print(f"\n✅ Total: {len(recovered_files)} fichiers récupérés")

# Sauvegarder les résultats dans un JSON pour analyse
output_file = Path('/Users/quentinlebreton/git/trainer_backend/recovered_models_report.json')
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump([{
        'path': f['path'],
        'date': f['date'].strftime('%Y-%m-%d %H:%M:%S'),
        'timestamp': f['timestamp'],
        'source': f['source'],
        'content_preview': f['content'][:500] + '...' if len(f['content']) > 500 else f['content']
    } for f in recovered_files], f, indent=2, ensure_ascii=False)

print(f"\n📊 Rapport détaillé sauvegardé dans: {output_file}")

