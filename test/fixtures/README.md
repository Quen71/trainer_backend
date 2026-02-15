# Fixtures de Test

Ce dossier contient les fixtures utilisées pour créer des données de test standardisées.

## test_programs.dart

La classe `TestPrograms` fournit des méthodes utilitaires pour créer des programmes d'entraînement correctement formatés pour les tests.

### Méthodes Principales

#### Programmes Simples

```dart
// Crée un programme simple avec une seule session Classic
final program = TestPrograms.createSimpleProgram(
  name: 'Mon Programme',
  sessionName: 'Session 1',
  style: SessionStyle.weights,
  exerciseCount: 5,
);
```

#### Programmes avec Plusieurs Sessions

```dart
// Crée un programme avec N sessions du même type
final program = TestPrograms.createProgramWithMultipleSessions(
  name: 'Programme Complet',
  sessionCount: 5,
  exercisesPerSession: 3,
  style: SessionStyle.weights,
);
```

#### Programmes avec Types de Sessions Mixtes

```dart
// Crée un programme avec différents types de sessions (Classic, AMRAP, EMOM, HIIT)
final program = TestPrograms.createMixedTypeProgram(
  name: 'Programme Mixte',
  includeClassic: true,
  includeAmrap: true,
  includeEmom: true,
  includeHiit: true,
  exercisesPerSession: 2,
);
```

### Test des Limites

#### Test de Limite de Sessions

```dart
// Crée un programme avec exactement N sessions pour tester les limites
final program = TestPrograms.createProgramForSessionLimitTest(
  name: 'Test Limites',
  sessionCount: 10,
  sessionType: 'classic', // 'classic', 'amrap', 'emom', 'hiit'
  exercisesPerSession: 1,
);
```

#### Test de Limite d'Exercices

```dart
// Crée un programme avec exactement N exercices pour tester les limites
final program = TestPrograms.createProgramForExerciseLimitTest(
  name: 'Test Limites Exercices',
  exerciseCount: 15,
  sessionType: 'classic',
);
```

### Création de Sessions Individuelles

Vous pouvez également créer des sessions individuelles pour les ajouter à des programmes existants :

```dart
// Session Classic
final classicSession = TestPrograms.createClassicSession(
  name: 'Ma Session',
  orderInProgram: 1,
  style: SessionStyle.weights,
  exerciseCount: 5,
);

// Session AMRAP
final amrapSession = TestPrograms.createAmrapSession(
  name: 'Session AMRAP',
  orderInProgram: 2,
  duration: Duration(minutes: 20),
  style: SessionStyle.bodyweight,
  exerciseCount: 3,
);

// Session EMOM
final emomSession = TestPrograms.createEmomSession(
  name: 'Session EMOM',
  orderInProgram: 3,
  roundNumber: 10,
  style: SessionStyle.bodyweight,
  exerciseCount: 4,
);

// Session HIIT
final hiitSession = TestPrograms.createHiitSession(
  name: 'Session HIIT',
  orderInProgram: 4,
  roundNumber: 8,
  style: SessionStyle.bodyweight,
  exerciseCount: 2,
);
```

## test_accounts.dart

Contient les comptes de test pour différents types d'abonnements.

### Utilisation

```dart
// Connexion avec un compte Basic
await supabase.auth.signInWithPassword(
  email: TestAccounts.basicUser.email,
  password: TestAccounts.basicUser.password,
);

// Connexion avec un compte Premium
await supabase.auth.signInWithPassword(
  email: TestAccounts.premiumUser.email,
  password: TestAccounts.premiumUser.password,
);
```

## Bonnes Pratiques

1. **Utiliser les fixtures** : Toujours utiliser les fixtures pour créer des données de test plutôt que de créer manuellement des objets. Cela garantit la cohérence et facilite la maintenance.

2. **Nommer explicitement** : Donnez des noms explicites à vos programmes de test pour faciliter le débogage.

3. **Paramètres configurables** : Utilisez les paramètres optionnels pour personnaliser les fixtures selon vos besoins de test.

4. **Tests de limites** : Utilisez les méthodes dédiées (`createProgramForSessionLimitTest`, `createProgramForExerciseLimitTest`) pour tester les limites d'abonnement.

## Exemples d'Utilisation

### Test de Création de Programme

```dart
test('should create a program successfully', () async {
  final program = TestPrograms.createSimpleProgram(name: 'Test Program');
  final created = await ProgramsService.createFullProgram(program);
  
  expect(created.id, greaterThan(0));
  expect(created.name, equals('Test Program'));
});
```

### Test de Limite de Sessions

```dart
test('should enforce session limit', () async {
  final program = TestPrograms.createProgramForSessionLimitTest(
    name: 'Max Sessions Program',
    sessionCount: 10,
  );
  
  await ProgramsService.createFullProgram(program);
  
  // Tenter d'ajouter une session supplémentaire devrait échouer
  final newSession = TestPrograms.createClassicSession(
    name: 'Extra Session',
    orderInProgram: 11,
  );
  
  expect(
    () => ProgramsService.addSessionToProgram(
      programId: program.id,
      session: newSession,
    ),
    throwsA(isA<PostgrestException>()),
  );
});
```

### Test de Programme Mixte

```dart
test('should create mixed type program', () async {
  final program = TestPrograms.createMixedTypeProgram(
    name: 'Programme Complet',
    exercisesPerSession: 3,
  );
  
  final created = await ProgramsService.createFullProgram(program);
  
  expect(created.sessions.length, equals(4));
  expect(created.sessions[0], isA<ClassicSession>());
  expect(created.sessions[1], isA<AmrapSession>());
  expect(created.sessions[2], isA<EmomSession>());
  expect(created.sessions[3], isA<HiitSession>());
});
```
