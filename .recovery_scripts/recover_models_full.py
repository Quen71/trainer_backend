#!/usr/bin/env python3
"""
Script pour récupérer les fichiers COMPLETS du répertoire lib/models/ depuis le cache Cursor
"""
import json
import os
from pathlib import Path
from datetime import datetime
from collections import defaultdict

# Chemin vers l'historique Cursor
HISTORY_DIR = Path.home() / "Library/Application Support/Cursor/User/History"

# Fichiers récupérés avec leurs métadonnées
all_recovered = []

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
        
        timestamp = latest_entry.get('timestamp', 0) / 1000
        file_date = datetime.fromtimestamp(timestamp)
        
        # Récupérer le contenu COMPLET du fichier
        entry_id = latest_entry.get('id')
        content_file = history_folder / entry_id
        
        if not content_file.exists():
            continue
        
        with open(content_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Ignorer les fichiers vides (anciens)
        if len(content) <= 1:
            continue
        
        # Extraire le chemin relatif
        if 'trainer_backend/lib/models/' in resource:
            rel_path = resource.split('trainer_backend/lib/models/')[1]
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

# Grouper par catégorie pour l'affichage
categories = {
    'models/api/': [],
    'models/auth/enums/': [],
    'models/auth/state/': [],
    'models/auth/': [],
    'models/history/': [],
    'models/training/converters/': [],
    'models/training/enums/': [],
    'models/training/parameters/': [],
    'models/training/': [],
    'models/': []
}

for path in sorted(latest_files.keys()):
    if path.startswith('api/'):
        categories['models/api/'].append(path)
    elif path.startswith('auth/enums/'):
        categories['models/auth/enums/'].append(path)
    elif path.startswith('auth/state/'):
        categories['models/auth/state/'].append(path)
    elif path.startswith('auth/'):
        categories['models/auth/'].append(path)
    elif path.startswith('history/'):
        categories['models/history/'].append(path)
    elif path.startswith('training/converters/'):
        categories['models/training/converters/'].append(path)
    elif path.startswith('training/enums/'):
        categories['models/training/enums/'].append(path)
    elif path.startswith('training/parameters/'):
        categories['models/training/parameters/'].append(path)
    elif path.startswith('training/'):
        categories['models/training/'].append(path)
    else:
        categories['models/'].append(path)

# Afficher chaque fichier avec analyse
valid_count = 0
invalid_count = 0

for category, paths in categories.items():
    if not paths:
        continue
    
    print(f"\n\n📁 lib/{category}")
    print("=" * 100)
    
    for path in paths:
        file_info = latest_files[path]
        content = file_info['content']
        
        # Analyser le contenu pour détecter les mélanges
        is_valid = True
        warning = ""
        
        # Vérifier les imports
        first_lines = '\n'.join(content.split('\n')[:10])
        
        # Détecter les fichiers avec du contenu mélangé
        if path not in ['history/session_log.dart', 'history/round_log.dart', 'history/exercise_log.dart']:
            if 'sealed class SessionLog' in content or 'class RoundLog' in first_lines and 'round_log' not in path:
                is_valid = False
                warning = "⚠️  CONTENU MÉLANGÉ (semble être session_log.dart)"
        
        # Vérifier les imports correspondent au nom du fichier
        expected_part = f"part '{path.split('/')[-1].replace('.dart', '.g.dart')}';"
        if '@JsonSerializable' in content or '@CopyWith' in content:
            if expected_part not in content:
                # C'est peut-être un fichier enum sans génération
                if 'enum ' not in content[:200]:
                    warning += " ⚠️  Directive 'part' manquante ou incorrecte"
        
        status = "✅ VALIDE" if is_valid else "❌ INVALIDE"
        if is_valid:
            valid_count += 1
        else:
            invalid_count += 1
        
        print(f"\n  {status} │ lib/models/{path}")
        print(f"           │ 📅 {file_info['date'].strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"           │ 📏 {file_info['size']} caractères")
        if warning:
            print(f"           │ {warning}")
        
        # Afficher un aperçu du contenu
        preview_lines = [l for l in content.split('\n')[:6] if l.strip()][:3]
        for line in preview_lines:
            print(f"           │ {line[:90]}")

print("\n\n" + "=" * 100)
print(f"\n📊 RÉSUMÉ:")
print(f"   • {len(latest_files)} fichiers uniques récupérés")
print(f"   • {valid_count} fichiers valides ✅")
print(f"   • {invalid_count} fichiers avec problèmes ❌")
print("\n" + "=" * 100)

# Sauvegarder les fichiers valides AVEC leur contenu complet
valid_files_for_restore = {}
for path, file_info in latest_files.items():
    content = file_info['content']
    
    # Vérifier validité
    is_valid = True
    if path not in ['history/session_log.dart', 'history/round_log.dart', 'history/exercise_log.dart']:
        if 'sealed class SessionLog' in content:
            is_valid = False
    
    if is_valid:
        valid_files_for_restore[path] = {
            'content': content,
            'date': file_info['date'].strftime('%Y-%m-%d %H:%M:%S'),
            'timestamp': file_info['timestamp'],
            'source': file_info['source']
        }

output_file = Path('/Users/quentinlebreton/git/trainer_backend/models_ready_to_restore.json')
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(valid_files_for_restore, f, indent=2, ensure_ascii=False)

print(f"\n💾 Fichiers prêts à restaurer sauvegardés dans:")
print(f"   {output_file}")
print(f"\n✅ Prêt pour la restauration de {len(valid_files_for_restore)} fichiers valides!")

