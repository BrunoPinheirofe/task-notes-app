import 'package:app/components/drawer_app.dart';
import 'package:app/components/notification_panel.dart';
import 'package:app/components/task_dialog.dart';
import 'package:app/models/models.dart';
import 'package:app/pages/achievements_page.dart';
import 'package:app/pages/auth_page.dart';
import 'package:app/pages/categories_page.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/notes_page.dart';
import 'package:app/pages/reports_page.dart';
import 'package:app/pages/tasks_page.dart';
import 'package:app/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _isLoggedIn = true;
  String _username = 'nomedocabra@logado.com';

  late List<Category> _categories;
  late List<Task> _tasks;
  late List<Note> _notes;
  late List<AchievementBadge> _badges;
  int _totalPoints = 45;
  int _currentLevel = 1;
  int _pointsToNextLevel = 55;
  final int _streakDays = 3;

  @override
  void initState() {
    super.initState();
    _initDefaultData();
  }

  void _initDefaultData() {
    final now = DateTime.now();
    _categories = [
      const Category(
        id: 'cat-1',
        name: 'Trabalho',
        color: '#C0533A',
        icon: 'Briefcase',
      ),
      const Category(
        id: 'cat-2',
        name: 'Pessoal',
        color: '#4A7C59',
        icon: 'User',
      ),
      const Category(
        id: 'cat-3',
        name: 'Estudos',
        color: '#3A5A7C',
        icon: 'BookOpen',
      ),
    ];

    _tasks = [
      Task(
        id: 'task-1',
        title: 'Finalizar telas do aplicativo Meu Caderno',
        description: 'Implementar todas as telas baseadas na versão Web.',
        priority: Priority.high,
        status: TaskStatus.inProgress,
        categoryId: 'cat-1',
        dueDate: now.add(const Duration(hours: 5)).toIso8601String(),
        createdAt: now.subtract(const Duration(days: 1)).toIso8601String(),
        updatedAt: now.toIso8601String(),
        tags: const ['flutter', 'mobile'],
        subtasks: const [
          Subtask(
            id: 'sub-1',
            title: 'Configurar tema Warm Paper Notebook',
            completed: true,
            priority: Priority.high,
          ),
          Subtask(
            id: 'sub-2',
            title: 'Criar telas de Tarefas, Notas e Relatórios',
            completed: false,
            priority: Priority.medium,
          ),
        ],
      ),
      Task(
        id: 'task-2',
        title: 'Revisar documentação da API Express',
        description: 'Verificar endpoints de tarefas, categorias e notas.',
        priority: Priority.medium,
        status: TaskStatus.done,
        categoryId: 'cat-3',
        dueDate: now.toIso8601String(),
        createdAt: now.subtract(const Duration(days: 2)).toIso8601String(),
        updatedAt: now.toIso8601String(),
        tags: const ['api', 'backend'],
      ),
      Task(
        id: 'task-3',
        title: 'Planejamento semanal de metas',
        priority: Priority.low,
        status: TaskStatus.pending,
        categoryId: 'cat-2',
        dueDate: now.add(const Duration(days: 1)).toIso8601String(),
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
        recurrence: const RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
          maxOccurrences: 12,
        ),
      ),
    ];

    _notes = [
      Note(
        id: 'note-1',
        title: 'Ideias para o Design do Caderno',
        content:
            'Usar paleta pergaminho (#FDF6E3), terracota (#C0533A) e tipografia clássica com Playfair Display, Lora e Caveat.',
        categoryId: 'cat-1',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
        tags: const ['design', 'ui'],
        pinned: true,
      ),
      Note(
        id: 'note-2',
        title: 'Resumo de Estudos',
        content:
            'Anotações sobre gerenciamento de estado, persistência local e gráficos com fl_chart.',
        categoryId: 'cat-3',
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
        tags: const ['estudo'],
        pinned: false,
      ),
    ];

    _badges = kAllBadgeDefinitions.map((b) {
      if (b.id == 'first_task' ||
          b.id == 'first_completion' ||
          b.id == 'streak_3_days') {
        return b.copyWith(unlockedAt: now.toIso8601String());
      }
      return b;
    }).toList();
  }

  List<TaskNotification> get _notifications {
    final now = DateTime.now();
    final result = <TaskNotification>[];
    for (final t in _tasks) {
      if (t.status == TaskStatus.done || t.dueDate == null) continue;
      final due = DateTime.tryParse(t.dueDate!);
      if (due == null) continue;
      final hours = due.difference(now).inHours;
      if (hours > 48) continue;

      if (hours < 0) {
        result.add(
          TaskNotification(
            taskId: t.id,
            title: t.title,
            dueDate: t.dueDate!,
            hoursUntilDue: hours,
            urgency: NotificationUrgency.critical,
            message: 'Tarefa em atraso',
          ),
        );
      } else if (hours <= 1) {
        result.add(
          TaskNotification(
            taskId: t.id,
            title: t.title,
            dueDate: t.dueDate!,
            hoursUntilDue: hours,
            urgency: NotificationUrgency.critical,
            message: 'Vence em menos de 1 hora',
          ),
        );
      } else if (hours <= 6) {
        result.add(
          TaskNotification(
            taskId: t.id,
            title: t.title,
            dueDate: t.dueDate!,
            hoursUntilDue: hours,
            urgency: NotificationUrgency.high,
            message: 'Vence em ${hours}h',
          ),
        );
      } else if (hours <= 24) {
        result.add(
          TaskNotification(
            taskId: t.id,
            title: t.title,
            dueDate: t.dueDate!,
            hoursUntilDue: hours,
            urgency: NotificationUrgency.medium,
            message: 'Vence hoje',
          ),
        );
      } else {
        result.add(
          TaskNotification(
            taskId: t.id,
            title: t.title,
            dueDate: t.dueDate!,
            hoursUntilDue: hours,
            urgency: NotificationUrgency.low,
            message: 'Vence amanhã',
          ),
        );
      }
    }
    return result;
  }

  void _addTask(Task task) {
    setState(() => _tasks.insert(0, task));
  }

  void _updateTask(Task updated) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == updated.id);
      if (idx != -1) {
        _tasks[idx] = updated;
      }
    });
  }

  void _deleteTask(String id) {
    setState(() => _tasks.removeWhere((t) => t.id == id));
  }

  void _toggleTaskStatus(String id) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == id);
      if (idx == -1) return;
      final current = _tasks[idx];
      final next = current.status == TaskStatus.done
          ? TaskStatus.pending
          : TaskStatus.done;
      _tasks[idx] = current.copyWith(
        status: next,
        updatedAt: DateTime.now().toIso8601String(),
      );
      if (next == TaskStatus.done) {
        _totalPoints += 15;
        if (_totalPoints >= _currentLevel * 100) {
          _currentLevel++;
        }
        _pointsToNextLevel = (_currentLevel * 100) - _totalPoints;
      }
    });
  }

  void _toggleSubtask(String taskId, String subtaskId) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == taskId);
      if (idx == -1) return;
      final task = _tasks[idx];
      final updatedSubs = task.subtasks.map((s) {
        if (s.id == subtaskId) {
          return s.copyWith(completed: !s.completed);
        }
        return s;
      }).toList();
      final allDone =
          updatedSubs.isNotEmpty && updatedSubs.every((s) => s.completed);
      var nextStatus = task.status;
      if (allDone && task.status != TaskStatus.done) {
        nextStatus = TaskStatus.done;
      } else if (!allDone && task.status == TaskStatus.done) {
        nextStatus = TaskStatus.inProgress;
      }
      _tasks[idx] = task.copyWith(
        subtasks: updatedSubs,
        status: nextStatus,
        updatedAt: DateTime.now().toIso8601String(),
      );
    });
  }

  Widget _buildActivePage() {
    return switch (_selectedIndex) {
      0 => HomePage(
        tasks: _tasks,
        notes: _notes,
        categories: _categories,
        notifications: _notifications,
        onNavigateToTab: (i) => setState(() => _selectedIndex = i),
        onQuickCreateTask: () {
          showTaskDialog(
            context,
            categories: _categories,
            onSave: _addTask,
          );
        },
        onResetData: () => setState(_initDefaultData),
      ),
      1 => TasksPage(
        tasks: _tasks,
        categories: _categories,
        onAddTask: _addTask,
        onUpdateTask: _updateTask,
        onDeleteTask: _deleteTask,
        onToggleTaskStatus: _toggleTaskStatus,
        onToggleSubtask: _toggleSubtask,
      ),
      2 => NotesPage(
        notes: _notes,
        categories: _categories,
        onAddNote: (n) => setState(() => _notes.insert(0, n)),
        onUpdateNote: (n) {
          setState(() {
            final idx = _notes.indexWhere((item) => item.id == n.id);
            if (idx != -1) _notes[idx] = n;
          });
        },
        onDeleteNote: (id) =>
            setState(() => _notes.removeWhere((n) => n.id == id)),
        onTogglePin: (id) {
          setState(() {
            final idx = _notes.indexWhere((n) => n.id == id);
            if (idx != -1) {
              _notes[idx] = _notes[idx].copyWith(pinned: !_notes[idx].pinned);
            }
          });
        },
      ),
      3 => CategoriesPage(
        categories: _categories,
        tasks: _tasks,
        notes: _notes,
        onAddCategory: (c) => setState(() => _categories.add(c)),
        onDeleteCategory: (id) =>
            setState(() => _categories.removeWhere((c) => c.id == id)),
      ),
      4 => ReportsPage(tasks: _tasks, categories: _categories),
      5 => AchievementsPage(
        tasks: _tasks,
        badges: _badges,
        totalPoints: _totalPoints,
        currentLevel: _currentLevel,
        pointsToNextLevel: _pointsToNextLevel,
        streakDays: _streakDays,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return AuthPage(
        onAuthenticated: (user) {
          setState(() {
            _username = user;
            _isLoggedIn = true;
          });
        },
      );
    }

    final notifs = _notifications;
    final urgentCount = notifs
        .where(
          (n) =>
              n.urgency == NotificationUrgency.critical ||
              n.urgency == NotificationUrgency.high,
        )
        .length;

    return Scaffold(
      drawer: DrawerApp(
        selectedIndex: _selectedIndex,
        onSelectIndex: (index) => setState(() => _selectedIndex = index),
        username: _username,
        urgentBadgeCount: urgentCount,
        onLogout: () => setState(() => _isLoggedIn = false),
      ),
      appBar: AppBar(
        animateColor: true,
        centerTitle: true,
        actionsPadding: const EdgeInsets.only(right: 12),
        elevation: 1,
        shape: Border(
          bottom: BorderSide(
            color: AppColors.secondary.withAlpha(70),
            width: 1.5,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  showNotificationPanelDialog(
                    context,
                    notifications: notifs,
                  );
                },
                tooltip: 'Notificações',
                icon: const Icon(LucideIcons.bell, size: 20),
              ),
              if (urgentCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.destructive,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
        title: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Icon(
              LucideIcons.bookOpen,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            Text(
              'Meu Caderno',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontWeight: .bold,
                fontSize: MediaQuery.of(context).textScaler.scale(20),
              ),
            ),
          ],
        ),
      ),
      body: _buildActivePage(),
    );
  }
}
