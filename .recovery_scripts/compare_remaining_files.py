#!/usr/bin/env python3
"""
Comparer les fichiers restants récupérés avec les versions actuelles
"""
import json
from pathlib import Path
import difflib

# Charger les fichiers récupérés
remaining_file = Path('/Users/quentinlebreton/git/trainer_backend/.recovery_scripts/remaining_files_ready_to_restore.json')
with open(remaining_file, 'r', encoding='utf-8') as f:
    recovered = json.load(f)

# Dossier racine du projet
project_root = Path('/Users/quentinlebreton/git/trainer_backend')

print("=" * 100)
print("🔍 COMPARAISON DES FICHIERS RESTANTS RÉCUPÉRÉS AVEC LES VERSIONS ACTUELLES")
print("=" * 100)
print()

files_to_restore = []
files_identical = []
files_new = []

total_files = len(recovered)
count = 0

# Grouper par catégorie
categories = {}
for path, file_info in recovered.items():
    category = file_info['category']
    if category not in categories:
        categories[category] = []
    categories[category].append(path)

for category in sorted(categories.keys()):
    paths = categories[category]
    
    print(f"\n{'='*100}")
    print(f"📁 {category}")
    print(f"{'='*100}\n")
    
    for rel_path in sorted(paths):
        count += 1
        file_info = recovered[rel_path]
        recovered_content = file_info['content']
        
        # Déterminer le chemin complet du fichier actuel
        if category == 'lib/clients/':
            # Corriger le double "clients/" dans le chemin
            clean_path = rel_path.replace('clients/', '', 1) if rel_path.startswith('clients/') else rel_path
            full_path = project_root / 'lib' / 'clients' / clean_path
        elif category == 'lib/':
            full_path = project_root / 'lib' / rel_path
        elif category == 'root/':
            full_path = project_root / rel_path
        else:
            full_path = project_root / rel_path
        
        print(f"\n[{count}/{total_files}] 📄 {category}{rel_path}")
        print("-" * 100)
        print(f"📅 Date cache: {file_info['date']}")
        print(f"📝 Source: {file_info['source']}")
        print(f"📏 Taille: {len(recovered_content)} caractères")
        
        # Vérifier si le fichier existe actuellement
        if not full_path.exists():
            print(f"🆕 NOUVEAU FICHIER (n'existe pas actuellement)")
            print()
            print("Contenu récupéré (aperçu):")
            lines = recovered_content.split('\n')[:15]
            for i, line in enumerate(lines, 1):
                print(f"  {i:3} │ {line}")
            total_lines = len(recovered_content.split('\n'))
            if total_lines > 15:
                print(f"  ... │ (+ {total_lines - 15} lignes)")
            files_new.append(f"{category}{rel_path}")
            print()
            print("✅ À RESTAURER")
        else:
            # Comparer avec la version actuelle
            with open(full_path, 'r', encoding='utf-8') as f:
                current_content = f.read()
            
            if current_content.strip() == recovered_content.strip():
                print("✅ IDENTIQUE à la version actuelle - Aucune modification nécessaire")
                files_identical.append(f"{category}{rel_path}")
            else:
                print("🔄 DIFFÉRENT de la version actuelle")
                print()
                
                # Calculer le diff
                current_lines = current_content.splitlines(keepends=True)
                recovered_lines = recovered_content.splitlines(keepends=True)
                
                diff = list(difflib.unified_diff(
                    current_lines,
                    recovered_lines,
                    fromfile=f'ACTUEL: {rel_path}',
                    tofile=f'RÉCUPÉRÉ: {rel_path}',
                    lineterm=''
                ))
                
                if len(diff) > 0:
                    print("📋 Différences (format unified diff):")
                    print()
                    # Afficher les 50 premières lignes du diff
                    for line in diff[:50]:
                        if line.startswith('+++') or line.startswith('---'):
                            print(f"  {line}")
                        elif line.startswith('+'):
                            print(f"  \033[32m{line}\033[0m")  # Vert
                        elif line.startswith('-'):
                            print(f"  \033[31m{line}\033[0m")  # Rouge
                        elif line.startswith('@@'):
                            print(f"  \033[36m{line}\033[0m")  # Cyan
                        else:
                            print(f"  {line}")
                    
                    if len(diff) > 50:
                        print(f"  ... (+{len(diff) - 50} lignes supplémentaires dans le diff)")
                
                print()
                print("✅ À RESTAURER")
                files_to_restore.append(f"{category}{rel_path}")
        
        print()

print("\n" + "=" * 100)
print("📊 RÉSUMÉ FINAL - Fichiers restants")
print("=" * 100)
print(f"\n  • {len(files_new)} nouveau(x) fichier(s) 🆕")
print(f"  • {len(files_to_restore)} fichier(s) modifié(s) 🔄")
print(f"  • {len(files_identical)} fichier(s) identique(s) ✅")
print(f"\n  Total: {len(recovered)} fichiers analysés")

if files_new:
    print(f"\n\n📝 Nouveaux fichiers à créer:")
    for f in files_new:
        print(f"     • {f}")

if files_to_restore:
    print(f"\n\n🔄 Fichiers à mettre à jour:")
    for f in files_to_restore:
        print(f"     • {f}")

if files_identical:
    print(f"\n\n✅ Fichiers déjà à jour (aucune action requise):")
    for f in files_identical:
        print(f"     • {f}")

print("\n" + "=" * 100)
print("\n⚠️  ATTENTION: Aucune modification n'a été appliquée.")
print("📋 Ce rapport est uniquement informatif.")
print("\n💡 Validez ce rapport avant de procéder à la restauration.")
print("=" * 100)

# Sauvegarder la liste des fichiers à restaurer
restore_list = {
    'new_files': files_new,
    'modified_files': files_to_restore,
    'identical_files': files_identical
}

restore_file = Path('/Users/quentinlebreton/git/trainer_backend/.recovery_scripts/remaining_files_restore_plan.json')
with open(restore_file, 'w', encoding='utf-8') as f:
    json.dump(restore_list, f, indent=2)

print(f"\n💾 Plan de restauration sauvegardé dans: {restore_file}")



