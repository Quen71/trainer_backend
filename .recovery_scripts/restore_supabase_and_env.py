#!/usr/bin/env python3
"""
Restaurer tous les fichiers supabase/ et .env depuis le cache Cursor
"""
import json
from pathlib import Path

# Charger les fichiers récupérés
supabase_file = Path('/Users/quentinlebreton/git/trainer_backend/.recovery_scripts/supabase_and_env_ready_to_restore.json')
with open(supabase_file, 'r', encoding='utf-8') as f:
    recovered = json.load(f)

# Charger le plan de restauration pour savoir quels fichiers restaurer
plan_file = Path('/Users/quentinlebreton/git/trainer_backend/.recovery_scripts/supabase_and_env_restore_plan.json')
with open(plan_file, 'r', encoding='utf-8') as f:
    plan = json.load(f)

# Fichiers à restaurer (nouveaux + modifiés)
files_to_restore = []

# Parser les noms de fichiers depuis le plan
for file_path in plan['new_files'] + plan['modified_files']:
    # Extraire le chemin relatif depuis le display path
    if file_path == '.env':
        files_to_restore.append(('.env', 'root'))
    elif file_path.startswith('supabase/'):
        rel_path = file_path.replace('supabase/', '', 1)
        files_to_restore.append((rel_path, 'supabase'))

# Dossier racine du projet
project_root = Path('/Users/quentinlebreton/git/trainer_backend')

print("=" * 100)
print("🔄 RESTAURATION DES FICHIERS SUPABASE ET .ENV")
print("=" * 100)
print()

restored_count = 0
failed_count = 0

for rel_path, category in files_to_restore:
    if rel_path not in recovered:
        print(f"❌ {rel_path} - Non trouvé dans les fichiers récupérés")
        failed_count += 1
        continue
    
    file_info = recovered[rel_path]
    content = file_info['content']
    
    # Déterminer le chemin complet
    if category == 'root':
        full_path = project_root / rel_path
        display_path = rel_path
    else:
        full_path = project_root / 'supabase' / rel_path
        display_path = f"supabase/{rel_path}"
    
    # Créer les dossiers parents si nécessaire
    full_path.parent.mkdir(parents=True, exist_ok=True)
    
    try:
        # Écrire le fichier
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        # Affichage différent pour .env (sensible)
        if rel_path == '.env':
            print(f"✅ {display_path}")
            print(f"   📅 Date: {file_info['date']}")
            print(f"   🔒 Fichier sensible restauré (clés API)")
        else:
            print(f"✅ {display_path}")
            print(f"   📅 Date: {file_info['date']}")
            print(f"   📏 {len(content)} caractères restaurés")
        
        print()
        restored_count += 1
        
    except Exception as e:
        print(f"❌ {display_path} - Erreur: {e}")
        failed_count += 1

print("=" * 100)
print(f"📊 RÉSUMÉ:")
print(f"   ✅ {restored_count} fichier(s) restauré(s) avec succès")
if failed_count > 0:
    print(f"   ❌ {failed_count} fichier(s) en échec")
print("=" * 100)

if restored_count > 0:
    print()
    print("🎉 RESTAURATION TERMINÉE AVEC SUCCÈS!")
    print()
    print("⚠️  IMPORTANT - Fichier .env:")
    print("   Le fichier .env contient vos clés API Supabase.")
    print("   Vérifiez qu'il est bien listé dans .gitignore pour ne pas le commiter.")
    print()
    print("📋 Migrations SQL:")
    print(f"   {restored_count - 1} migration(s) SQL restaurée(s).")
    print("   Ces migrations documentent l'évolution de votre schéma de base de données.")



