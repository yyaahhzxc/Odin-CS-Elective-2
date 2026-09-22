import 'dart:async';
import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';
import '../widgets/profile_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  // Future stored once in initState to avoid re-triggering on rebuilds.
  late Future<Profile> _profileFuture;

  // StreamController used to broadcast live 'last seen' counter events.
  late final StreamController<int> _lastSeenController;
  StreamSubscription<int>? _periodicSubscription;

  bool _simulateError = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();

    _lastSeenController = StreamController<int>.broadcast();
    _initLastSeenStream();
  }

  Future<Profile> _loadProfile() async {
    try {
      return await _profileService.fetchProfile(simulateError: _simulateError);
    } catch (e) {
      // Allow the FutureBuilder to capture and render the error state.
      rethrow;
    }
  }

  void _initLastSeenStream() {
    // Generates periodic ticks every 1 second and pipes them into the StreamController.
    _periodicSubscription = Stream.periodic(
      const Duration(seconds: 1),
      (count) => count + 1,
    ).listen(
      (seconds) {
        if (!_lastSeenController.isClosed) {
          _lastSeenController.add(seconds);
        }
      },
      onError: (error) {
        if (!_lastSeenController.isClosed) {
          _lastSeenController.addError(error);
        }
      },
    );
  }

  void _reloadProfile() {
    if (!mounted) return;
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  @override
  void dispose() {
    // Harden: Cancel subscription and close StreamController to prevent memory leaks.
    _periodicSubscription?.cancel();
    _lastSeenController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Async Profile'),
        actions: [
          IconButton(
            tooltip: _simulateError ? 'Switch to Normal Mode' : 'Simulate Error',
            icon: Icon(
              _simulateError ? Icons.warning_amber_rounded : Icons.bug_report_outlined,
              color: _simulateError ? theme.colorScheme.error : null,
            ),
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _simulateError = !_simulateError;
              });
              _reloadProfile();
            },
          ),
          IconButton(
            tooltip: 'Reload Profile',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _reloadProfile,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<Profile>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState(theme);
              }

              if (snapshot.hasError) {
                return _buildErrorState(theme, snapshot.error);
              }

              if (snapshot.hasData) {
                return ProfileCard(
                  profile: snapshot.data!,
                  statusWidget: _buildStreamStatusBadge(theme),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Fetching profile data...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme, Object? error) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 44,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to Load Profile',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString().replaceFirst('Exception: ', ''),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: _reloadProfile,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamStatusBadge(ThemeData theme) {
    return StreamBuilder<int>(
      stream: _lastSeenController.stream,
      initialData: 0,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Live feed error',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          );
        }

        final seconds = snapshot.data ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Active • last seen $seconds second${seconds == 1 ? '' : 's'} ago',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
