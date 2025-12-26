import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/note_provider.dart';
import '../../viewmodels/auth_provider.dart';
import '../../constants/app_constants.dart';
import 'add_edit_note_screen.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/note_list_widget.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteProvider>(context, listen: false).loadNotes();
    });
  }

  void _openFilter(BuildContext context) {
    showFilterBottomSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(
            onOpenFilter: () => _openFilter(context),
          ),
          const Expanded(child: NoteListWidget()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
