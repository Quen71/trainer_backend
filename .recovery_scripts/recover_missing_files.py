#!/usr/bin/env python3
"""
Récupérer les bonnes versions des 4 fichiers problématiques
"""
import json
import os
from pathlib import Path
from datetime import datetime
from collections import defaultdict

# Chemin vers l'historique Cursor
HISTORY_DIR = Path.home() / "Library/Application Support/Cursor/User/History"

# Fichiers problématiques à récupérer (avec une version antérieure à octobre)
PROBLEMATIC_FILES = [
    'training/enums/session_style.dart',
    'training/enums/session_type.dart',
    'training/parameters/exercise_parameters.dart',
    'training/session.dart'
]

all_versions = defaultdict(list)

print("🔍 Recherche des versions antérieures des 4 fichiers problématiques...\n")

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
        
        # Chercher seulement les fichiers problématiques
        found = False
        for prob_file in PROBLEMATIC_FILES:
            if resource.endswith(prob_file):
                found = True
                target_file = prob_file
                break
        
        if not found:
            continue
        
        entries = data.get('entries', [])
        
        # Récupérer TOUTES les versions
        for entry in entries:
            timestamp = entry.get('timestamp', 0) / 1000
            file_date = datetime.fromtimestamp(timestamp)
            
            # Seulement les versions avant octobre 2025
            if file_date.month >= 10 and file_date.year == 2025:
                continue
            
            entry_id = entry.get('id')
            content_file = history_folder / entry_id
            
            if not content_file.exists():
                continue
            
            with open(content_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Ignorer les fichiers vides
            if len(content) <= 1:
                continue
            
            # Ignorer les fichiers avec contenu mélangé
            if 'sealed class SessionLog' in content and 'session_log' not in target_file:
                continue
            
            all_versions[target_file].append({
                'content': content,
                'date': file_date,
                'timestamp': timestamp,
                'source': entry.get('source', 'Unknown'),
                'size': len(content)
            })
        
    except Exception as e:
        continue

print("=" * 100)
print("📋 VERSIONS VALIDES TROUVÉES")
print("=" * 100)

best_versions = {}

for file_path in PROBLEMATIC_FILES:
    versions = all_versions.get(file_path, [])
    
    print(f"\n\n📄 {file_path}")
    print("-" * 100)
    
    if not versions:
        print("  ❌ Aucune version valide trouvée")
        continue
    
    # Trier par timestamp décroissant
    versions.sort(key=lambda x: x['timestamp'], reverse=True)
    
    print(f"  ✅ {len(versions)} version(s) valide(s) trouvée(s)")
    
    # Afficher les 3 versions les plus récentes
    for i, version in enumerate(versions[:3], 1):
        print(f"\n  Version {i}:")
        print(f"    📅 Date: {version['date'].strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"    📏 Taille: {version['size']} caractères")
        print(f"    📝 Source: {version['source']}")
        
        # Aperçu
        lines = [l for l in version['content'].split('\n')[:6] if l.strip()][:3]
        for line in lines:
            print(f"         {line[:80]}")
    
    # Garder la version la plus récente
    best = versions[0]
    best_versions[file_path] = best
    print(f"\n  ✓ Version la plus récente sélectionnée: {best['date'].strftime('%Y-%m-%d %H:%M:%S')}")

print("\n\n" + "=" * 100)
print(f"📊 RÉSUMÉ: {len(best_versions)}/{len(PROBLEMATIC_FILES)} fichiers récupérés avec succès")
print("=" * 100)

# Charger les fichiers déjà valides
existing_file = Path('/Users/quentinlebreton/git/trainer_backend/models_ready_to_restore.json')
with open(existing_file, 'r', encoding='utf-8') as f:
    ready_files = json.load(f)

# Ajouter les fichiers récupérés
for file_path, version in best_versions.items():
    ready_files[file_path] = {
        'content': version['content'],
        'date': version['date'].strftime('%Y-%m-%d %H:%M:%S'),
        'timestamp': version['timestamp'],
        'source': version['source']
    }

# Sauvegarder
with open(existing_file, 'w', encoding='utf-8') as f:
    json.dump(ready_files, f, indent=2, ensure_ascii=False)

print(f"\n💾 Fichiers mis à jour dans: {existing_file}")
print(f"✅ Total prêt pour restauration: {len(ready_files)} fichiers")

