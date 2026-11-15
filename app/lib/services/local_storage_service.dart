import 'dart:convert';
import 'package:app/models/models.dart';
import 'package:app/services/app_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDataSnapshot {
  const LocalDataSnapshot({
    required this.categories,
    required this.tasks,
    required this.notes,
    required this.totalPoints,
    required this.currentLevel,
    required this.streakDays,
    required this.unlockedBadges,
    this.connectedUser,
    required this.syncQueue,
    required this.syncedEntityIds,
    this.lastSyncedAt,
  });

  final List<Category> categories;
  final List<Task> tasks;
  final List<Note> notes;
  final int totalPoints;
  final int currentLevel;
  final int streakDays;
  final Map<String, String> unlockedBadges; // badgeId -> unlockedAt ISO
  final User? connectedUser;
  final List<SyncOperation> syncQueue;
  final Set<String> syncedEntityIds;
  final String? lastSyncedAt;
}

class LocalStorageService {
  LocalStorageService({AppDatabase? database})
    : _appDb = database ?? AppDatabase.instance;

  final AppDatabase _appDb;

  static const _kLegacyInitializedKey = 'offline_store_initialized_v1';
  static const _kCategoriesKey = 'offline_categories_v1';
  static const _kTasksKey = 'offline_tasks_v1';
  static const _kNotesKey = 'offline_notes_v1';
  static const _kPointsKey = 'offline_gamification_points_v1';
  static const _kLevelKey = 'offline_gamification_level_v1';
  static const _kStreakKey = 'offline_gamification_streak_v1';
  static const _kBadgesKey = 'offline_gamification_badges_v1';
  static const _kConnectedUserKey = 'offline_connected_user_v1';
  static const _kSyncQueueKey = 'offline_sync_queue_v1';
  static const _kSyncedIdsKey = 'offline_synced_ids_v1';
  static const _kLastSyncedAtKey = 'offline_last_synced_at_v1';

  Future<Database?> _tryGetSqlite() async {
    if (kIsWeb) return null;
    try {
      return await _appDb.database;
    } catch (_) {
      return null;
    }
  }

  Future<LocalDataSnapshot> loadSnapshot({
    required List<Category> defaultCategories,
    required List<Task> defaultTasks,
    required List<Note> defaultNotes,
    required Map<String, String> defaultUnlockedBadges,
  }) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      return _loadFromSqlite(
        db: db,
        defaultCategories: defaultCategories,
        defaultTasks: defaultTasks,
        defaultNotes: defaultNotes,
        defaultUnlockedBadges: defaultUnlockedBadges,
      );
    }

    return _loadFromPrefsFallback(
      defaultCategories: defaultCategories,
      defaultTasks: defaultTasks,
      defaultNotes: defaultNotes,
      defaultUnlockedBadges: defaultUnlockedBadges,
    );
  }

  Future<LocalDataSnapshot> _loadFromSqlite({
    required Database db,
    required List<Category> defaultCategories,
    required List<Task> defaultTasks,
    required List<Note> defaultNotes,
    required Map<String, String> defaultUnlockedBadges,
  }) async {
    final initRow = await db.query(
      'app_metadata',
      where: 'key = ?',
      whereArgs: const ['sqlite_initialized_v1'],
      limit: 1,
    );

    if (initRow.isEmpty) {
      // Verifica se já existem dados salvos anteriormente em SharedPreferences para migrar sem perda
      final prefs = await SharedPreferences.getInstance();
      final hadLegacyData = prefs.getBool(_kLegacyInitializedKey) ?? false;

      if (hadLegacyData) {
        final legacy = await _loadFromPrefsFallback(
          defaultCategories: defaultCategories,
          defaultTasks: defaultTasks,
          defaultNotes: defaultNotes,
          defaultUnlockedBadges: defaultUnlockedBadges,
        );
        await _seedSqliteTransaction(
          db: db,
          categories: legacy.categories,
          tasks: legacy.tasks,
          notes: legacy.notes,
          totalPoints: legacy.totalPoints,
          currentLevel: legacy.currentLevel,
          streakDays: legacy.streakDays,
          unlockedBadges: legacy.unlockedBadges,
          connectedUser: legacy.connectedUser,
          syncQueue: legacy.syncQueue,
          syncedIds: legacy.syncedEntityIds,
          lastSyncedAt: legacy.lastSyncedAt,
        );
        return legacy;
      }

      // Primeira abertura do app: popula defaults no SQLite
      await _seedSqliteTransaction(
        db: db,
        categories: defaultCategories,
        tasks: defaultTasks,
        notes: defaultNotes,
        totalPoints: 45,
        currentLevel: 1,
        streakDays: 3,
        unlockedBadges: defaultUnlockedBadges,
        connectedUser: null,
        syncQueue: const [],
        syncedIds: const {},
        lastSyncedAt: null,
      );

      return LocalDataSnapshot(
        categories: List<Category>.from(defaultCategories),
        tasks: List<Task>.from(defaultTasks),
        notes: List<Note>.from(defaultNotes),
        totalPoints: 45,
        currentLevel: 1,
        streakDays: 3,
        unlockedBadges: Map<String, String>.from(defaultUnlockedBadges),
        syncQueue: const [],
        syncedEntityIds: const {},
      );
    }

    // Carrega todas as tabelas do SQLite
    final catRows = await db.query('categories');
    final categories = catRows.map(_categoryFromSqliteRow).toList();

    final taskRows = await db.query('tasks', orderBy: 'created_at DESC');
    final tasks = taskRows.map(_taskFromSqliteRow).toList();

    final noteRows = await db.query('notes', orderBy: 'created_at DESC');
    final notes = noteRows.map(_noteFromSqliteRow).toList();

    final queueRows = await db.query('sync_queue');
    final syncQueue = queueRows.map(_syncOpFromSqliteRow).toList();

    final syncedRows = await db.query('synced_entities');
    final syncedIds = syncedRows
        .map((r) => r['entity_id']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toSet();

    final metaRows = await db.query('app_metadata');
    final meta = <String, String>{
      for (final r in metaRows)
        if (r['key'] != null && r['value'] != null)
          r['key'].toString(): r['value'].toString(),
    };

    final totalPoints = int.tryParse(meta['total_points'] ?? '') ?? 45;
    final currentLevel = int.tryParse(meta['current_level'] ?? '') ?? 1;
    final streakDays = int.tryParse(meta['streak_days'] ?? '') ?? 3;

    final unlockedBadges = <String, String>{};
    final rawBadges = meta['unlocked_badges'];
    if (rawBadges != null && rawBadges.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawBadges);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            if (entry.value is String) {
              unlockedBadges[entry.key.toString()] = entry.value as String;
            }
          }
        }
      } catch (_) {}
    } else {
      unlockedBadges.addAll(defaultUnlockedBadges);
    }

    User? connectedUser;
    final rawUser = meta['connected_user'];
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawUser);
        if (decoded is Map) {
          connectedUser = User.fromJson(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
    }

    return LocalDataSnapshot(
      categories: categories,
      tasks: tasks,
      notes: notes,
      totalPoints: totalPoints,
      currentLevel: currentLevel,
      streakDays: streakDays,
      unlockedBadges: unlockedBadges,
      connectedUser: connectedUser,
      syncQueue: syncQueue,
      syncedEntityIds: syncedIds,
      lastSyncedAt: meta['last_synced_at'],
    );
  }

  Future<void> _seedSqliteTransaction({
    required Database db,
    required List<Category> categories,
    required List<Task> tasks,
    required List<Note> notes,
    required int totalPoints,
    required int currentLevel,
    required int streakDays,
    required Map<String, String> unlockedBadges,
    required User? connectedUser,
    required List<SyncOperation> syncQueue,
    required Set<String> syncedIds,
    required String? lastSyncedAt,
  }) async {
    await db.transaction((txn) async {
      for (final c in categories) {
        await txn.insert(
          'categories',
          _categoryToSqliteRow(c),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final t in tasks) {
        await txn.insert(
          'tasks',
          _taskToSqliteRow(t),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final n in notes) {
        await txn.insert(
          'notes',
          _noteToSqliteRow(n),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final op in syncQueue) {
        await txn.insert(
          'sync_queue',
          _syncOpToSqliteRow(op),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final id in syncedIds) {
        await txn.insert(
          'synced_entities',
          {'entity_id': id},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await _putMetaTxn(txn, 'total_points', '$totalPoints');
      await _putMetaTxn(txn, 'current_level', '$currentLevel');
      await _putMetaTxn(txn, 'streak_days', '$streakDays');
      await _putMetaTxn(txn, 'unlocked_badges', jsonEncode(unlockedBadges));
      if (connectedUser != null) {
        await _putMetaTxn(
          txn,
          'connected_user',
          jsonEncode(connectedUser.toJson()),
        );
      }
      if (lastSyncedAt != null) {
        await _putMetaTxn(txn, 'last_synced_at', lastSyncedAt);
      }
      await _putMetaTxn(txn, 'sqlite_initialized_v1', 'true');
    });
  }

  Future<void> _putMetaTxn(
    DatabaseExecutor txn,
    String key,
    String value,
  ) async {
    await txn.insert(
      'app_metadata',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Map<String, Object?> _categoryToSqliteRow(Category c) => {
    'id': c.id,
    'name': c.name,
    'color': c.color,
    'icon': c.icon,
    'extra_json': jsonEncode(c.toJson()),
  };

  Category _categoryFromSqliteRow(Map<String, Object?> row) => Category(
    id: row['id']?.toString() ?? '',
    name: row['name']?.toString() ?? '',
    color: row['color']?.toString() ?? '#C0533A',
    icon: row['icon']?.toString() ?? 'Tag',
  );

  Map<String, Object?> _taskToSqliteRow(Task t) => {
    'id': t.id,
    'title': t.title,
    'description': t.description ?? '',
    'priority': t.priority.value,
    'status': t.status.value,
    'category_id': t.categoryId,
    'due_date': t.dueDate,
    'created_at': t.createdAt,
    'updated_at': t.updatedAt,
    'tags': jsonEncode(t.tags),
    'recurrence': t.recurrence != null
        ? jsonEncode(t.recurrence!.toJson())
        : null,
    'parent_task_id': t.parentTaskId,
    'occurrence_date': t.occurrenceDate,
    'subtasks': jsonEncode(t.subtasks.map((s) => s.toJson()).toList()),
    'extra_json': jsonEncode(t.toJson()),
  };

  Task _taskFromSqliteRow(Map<String, Object?> row) {
    return Task.fromJson({
      'id': row['id'],
      'title': row['title'],
      'description': row['description'],
      'priority': row['priority'],
      'status': row['status'],
      'categoryId': row['category_id'],
      'dueDate': row['due_date'],
      'createdAt': row['created_at'],
      'updatedAt': row['updated_at'],
      'tags': row['tags'],
      'recurrence': row['recurrence'],
      'parentTaskId': row['parent_task_id'],
      'occurrenceDate': row['occurrence_date'],
      'subtasks': row['subtasks'],
    });
  }

  Map<String, Object?> _noteToSqliteRow(Note n) => {
    'id': n.id,
    'title': n.title,
    'content': n.content,
    'category_id': n.categoryId,
    'created_at': n.createdAt,
    'updated_at': n.updatedAt,
    'tags': jsonEncode(n.tags),
    'pinned': n.pinned ? 1 : 0,
    'extra_json': jsonEncode(n.toJson()),
  };

  Note _noteFromSqliteRow(Map<String, Object?> row) {
    return Note.fromJson({
      'id': row['id'],
      'title': row['title'],
      'content': row['content'],
      'categoryId': row['category_id'],
      'createdAt': row['created_at'],
      'updatedAt': row['updated_at'],
      'tags': row['tags'],
      'pinned': row['pinned'],
    });
  }

  Map<String, Object?> _syncOpToSqliteRow(SyncOperation op) => {
    'id': op.id,
    'entity_type': op.entityType,
    'action': op.action,
    'entity_id': op.entityId,
    'payload': op.payload != null ? jsonEncode(op.payload) : null,
    'updated_at': op.updatedAt,
  };

  SyncOperation _syncOpFromSqliteRow(Map<String, Object?> row) {
    return SyncOperation.fromJson({
      'id': row['id'],
      'entityType': row['entity_type'],
      'action': row['action'],
      'entityId': row['entity_id'],
      'payload': row['payload'],
      'updatedAt': row['updated_at'],
    });
  }

  // --- Operações Granulares Atômicas no SQLite (sem apagar tabelas) ---

  Future<void> upsertCategory(Category category) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      await db.insert(
        'categories',
        _categoryToSqliteRow(category),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteCategoryById(String id) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> upsertTask(Task task) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      await db.insert(
        'tasks',
        _taskToSqliteRow(task),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteTaskById(String id) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> upsertNote(Note note) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      await db.insert(
        'notes',
        _noteToSqliteRow(note),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deleteNoteById(String id) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
    }
  }

  // --- Sincronização de Coleções (Transacional com Upsert + Remoção Seletiva) ---

  Future<void> saveCategories(
    List<Category> items, {
    SharedPreferences? prefs,
  }) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      await db.transaction((txn) async {
        final keepIds = items.map((e) => e.id).toSet();
        final existing = await txn.query('categories', columns: ['id']);
        for (final row in existing) {
          final id = row['id']?.toString();
          if (id != null && !keepIds.contains(id)) {
            await txn.delete('categories', where: 'id = ?', whereArgs: [id]);
          }
        }
        for (final c in items) {
          await txn.insert(
            'categories',
            _categoryToSqliteRow(c),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    }
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.setString(
      _kCategoriesKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> saveTasks(
    List<Task> items, {
    SharedPreferences? prefs,
  }) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      await db.transaction((txn) async {
        final keepIds = items.map((e) => e.id).toSet();
        final existing = await txn.query('tasks', columns: ['id']);
        for (final row in existing) {
          final id = row['id']?.toString();
          if (id != null && !keepIds.contains(id)) {
            await txn.delete('tasks', where: 'id = ?', whereArgs: [id]);
          }
        }
        for (final t in items) {
          await txn.insert(
            'tasks',
            _taskToSqliteRow(t),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    }
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.setString(
      _kTasksKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> saveNotes(
    List<Note> items, {
    SharedPreferences? prefs,
  }) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      await db.transaction((txn) async {
        final keepIds = items.map((e) => e.id).toSet();
        final existing = await txn.query('notes', columns: ['id']);
        for (final row in existing) {
          final id = row['id']?.toString();
          if (id != null && !keepIds.contains(id)) {
            await txn.delete('notes', where: 'id = ?', whereArgs: [id]);
          }
        }
        for (final n in items) {
          await txn.insert(
            'notes',
            _noteToSqliteRow(n),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    }
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.setString(
      _kNotesKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> saveGamification({
    required int totalPoints,
    required int currentLevel,
    required int streakDays,
    required Map<String, String> unlockedBadges,
    SharedPreferences? prefs,
  }) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      await db.transaction((txn) async {
        await _putMetaTxn(txn, 'total_points', '$totalPoints');
        await _putMetaTxn(txn, 'current_level', '$currentLevel');
        await _putMetaTxn(txn, 'streak_days', '$streakDays');
        await _putMetaTxn(txn, 'unlocked_badges', jsonEncode(unlockedBadges));
      });
    }
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.setInt(_kPointsKey, totalPoints);
    await p.setInt(_kLevelKey, currentLevel);
    await p.setInt(_kStreakKey, streakDays);
    await p.setString(_kBadgesKey, jsonEncode(unlockedBadges));
  }

  Future<void> saveConnectedUser(User? user) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      if (user == null) {
        await db.delete(
          'app_metadata',
          where: 'key = ?',
          whereArgs: const ['connected_user'],
        );
      } else {
        await _putMetaTxn(db, 'connected_user', jsonEncode(user.toJson()));
      }
    }
    final p = await SharedPreferences.getInstance();
    if (user == null) {
      await p.remove(_kConnectedUserKey);
    } else {
      await p.setString(_kConnectedUserKey, jsonEncode(user.toJson()));
    }
  }

  Future<void> saveSyncQueue(List<SyncOperation> queue) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      await db.transaction((txn) async {
        final keepIds = queue.map((e) => e.id).toSet();
        final existing = await txn.query('sync_queue', columns: ['id']);
        for (final row in existing) {
          final id = row['id']?.toString();
          if (id != null && !keepIds.contains(id)) {
            await txn.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
          }
        }
        for (final op in queue) {
          await txn.insert(
            'sync_queue',
            _syncOpToSqliteRow(op),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    }
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _kSyncQueueKey,
      jsonEncode(queue.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> saveSyncedEntityIds(Set<String> ids) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      await db.transaction((txn) async {
        final existing = await txn.query(
          'synced_entities',
          columns: ['entity_id'],
        );
        for (final row in existing) {
          final id = row['entity_id']?.toString();
          if (id != null && !ids.contains(id)) {
            await txn.delete(
              'synced_entities',
              where: 'entity_id = ?',
              whereArgs: [id],
            );
          }
        }
        for (final id in ids) {
          await txn.insert(
            'synced_entities',
            {'entity_id': id},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    }
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kSyncedIdsKey, ids.toList());
  }

  Future<void> saveLastSyncedAt(String? iso) async {
    final db = await _tryGetSqlite();
    if (db != null) {
      if (iso == null) {
        await db.delete(
          'app_metadata',
          where: 'key = ?',
          whereArgs: const ['last_synced_at'],
        );
      } else {
        await _putMetaTxn(db, 'last_synced_at', iso);
      }
    }
    final p = await SharedPreferences.getInstance();
    if (iso == null) {
      await p.remove(_kLastSyncedAtKey);
    } else {
      await p.setString(_kLastSyncedAtKey, iso);
    }
  }

  // --- Fallback / Migração Legada via SharedPreferences ---

  Future<LocalDataSnapshot> _loadFromPrefsFallback({
    required List<Category> defaultCategories,
    required List<Task> defaultTasks,
    required List<Note> defaultNotes,
    required Map<String, String> defaultUnlockedBadges,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final initialized = prefs.getBool(_kLegacyInitializedKey) ?? false;

    if (!initialized) {
      await prefs.setString(
        _kCategoriesKey,
        jsonEncode(defaultCategories.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(
        _kTasksKey,
        jsonEncode(defaultTasks.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(
        _kNotesKey,
        jsonEncode(defaultNotes.map((e) => e.toJson()).toList()),
      );
      await prefs.setInt(_kPointsKey, 45);
      await prefs.setInt(_kLevelKey, 1);
      await prefs.setInt(_kStreakKey, 3);
      await prefs.setString(_kBadgesKey, jsonEncode(defaultUnlockedBadges));
      await prefs.setBool(_kLegacyInitializedKey, true);

      return LocalDataSnapshot(
        categories: List<Category>.from(defaultCategories),
        tasks: List<Task>.from(defaultTasks),
        notes: List<Note>.from(defaultNotes),
        totalPoints: 45,
        currentLevel: 1,
        streakDays: 3,
        unlockedBadges: Map<String, String>.from(defaultUnlockedBadges),
        syncQueue: const [],
        syncedEntityIds: const {},
      );
    }

    final categories = _decodeList(
      prefs.getString(_kCategoriesKey),
      Category.fromJson,
    );
    final tasks = _decodeList(
      prefs.getString(_kTasksKey),
      Task.fromJson,
    );
    final notes = _decodeList(
      prefs.getString(_kNotesKey),
      Note.fromJson,
    );
    final syncQueue = _decodeList(
      prefs.getString(_kSyncQueueKey),
      SyncOperation.fromJson,
    );

    User? connectedUser;
    final rawUser = prefs.getString(_kConnectedUserKey);
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawUser);
        if (decoded is Map) {
          connectedUser = User.fromJson(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
    }

    final unlockedBadges = <String, String>{};
    final rawBadges = prefs.getString(_kBadgesKey);
    if (rawBadges != null && rawBadges.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawBadges);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            if (entry.value is String) {
              unlockedBadges[entry.key.toString()] = entry.value as String;
            }
          }
        }
      } catch (_) {}
    } else {
      unlockedBadges.addAll(defaultUnlockedBadges);
    }

    final syncedIds = (prefs.getStringList(_kSyncedIdsKey) ?? const []).toSet();

    return LocalDataSnapshot(
      categories: categories,
      tasks: tasks,
      notes: notes,
      totalPoints: prefs.getInt(_kPointsKey) ?? 45,
      currentLevel: prefs.getInt(_kLevelKey) ?? 1,
      streakDays: prefs.getInt(_kStreakKey) ?? 3,
      unlockedBadges: unlockedBadges,
      connectedUser: connectedUser,
      syncQueue: syncQueue,
      syncedEntityIds: syncedIds,
      lastSyncedAt: prefs.getString(_kLastSyncedAtKey),
    );
  }

  List<T> _decodeList<T>(
    String? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw == null || raw.isEmpty) return <T>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
    return <T>[];
  }
}
