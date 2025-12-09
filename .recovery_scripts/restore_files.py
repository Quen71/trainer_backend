#!/usr/bin/env python3
"""
Restaurer les fichiers sélectionnés depuis le cache Cursor
"""
import json
from pathlib import Path

# Charger les fichiers récupérés
models_file = Path('/Users/quentinlebreton/git/trainer_backend/models_ready_to_restore.json')
with open(models_file, 'r', encoding='utf-8') as f:
    recovered = json.load(f)

# Fichiers à restaurer
files_to_restore = [
    'history/exercise_log.dart',
    'history/session_log.dart'
]

# Dossier racine
base_dir = Path('/Users/quentinlebreton/git/trainer_backend/lib/models')

print("=" * 100)
print("🔄 RESTAURATION DES FICHIERS MODIFIÉS")
print("=" * 100)
print()

restored_count = 0
failed_count = 0

for rel_path in files_to_restore:
    if rel_path not in recovered:
        print(f"❌ {rel_path} - Non trouvé dans les fichiers récupérés")
        failed_count += 1
        continue
    
    file_info = recovered[rel_path]
    content = file_info['content']
    full_path = base_dir / rel_path
    
    # Créer les dossiers parents si nécessaire
    full_path.parent.mkdir(parents=True, exist_ok=True)
    
    try:
        # Écrire le fichier
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ lib/models/{rel_path}")
        print(f"   📅 Date: {file_info['date']}")
        print(f"   📏 {len(content)} caractères restaurés")
        print()
        restored_count += 1
        
    except Exception as e:
        print(f"❌ {rel_path} - Erreur: {e}")
        failed_count += 1

print("=" * 100)
print(f"📊 RÉSUMÉ:")
print(f"   ✅ {restored_count} fichier(s) restauré(s) avec succès")
if failed_count > 0:
    print(f"   ❌ {failed_count} fichier(s) en échec")
print("=" * 100)

