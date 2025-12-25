import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../viewmodels/note_provider.dart';
import '../../commands/note_commands.dart';
import '../../constants/app_constants.dart';
import '../../utils/helpers.dart';

/// Màn hình thêm/sửa ghi chú
/// Có 2 chế độ: Add Mode (note = null) và Edit Mode (note != null)
class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  bool _isEditMode = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.note != null;

    // Pre-fill nếu edit mode
    _titleController = TextEditingController(
      text: widget.note?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _tagController = TextEditingController(
      text: widget.note?.tag ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  /// Kiểm tra xem có thay đổi chưa được lưu không
  bool _hasChanges() {
    if (!_isEditMode) {
      // Add mode: check nếu có input nào
      return _titleController.text.isNotEmpty ||
          _contentController.text.isNotEmpty ||
          _tagController.text.isNotEmpty;
    } else {
      // Edit mode: check nếu khác với original
      return _titleController.text != widget.note!.title ||
          _contentController.text != widget.note!.content ||
          _tagController.text != (widget.note!.tag ?? '');
    }
  }

  /// Hiển thị dialog xác nhận hủy thay đổi
  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hủy thay đổi?'),
            content: const Text('Các thay đổi chưa được lưu sẽ bị mất'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Tiếp tục chỉnh sửa'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hủy'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Xử lý khi nhấn back
  Future<bool> _onWillPop() async {
    if (_hasChanges()) {
      return await _showDiscardDialog();
    }
    return true;
  }

  /// Xử lý lưu ghi chú
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    bool success;

    try {
      if (_isEditMode) {
        // Update existing note
        final command = UpdateNoteCommand(
          provider: noteProvider,
          id: widget.note!.id!,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          tag: _tagController.text.trim().isEmpty
              ? null
              : _tagController.text.trim(),
          createdAt: widget.note!.createdAt,
        );
        success = await command.execute();
      } else {
        // Add new note
        final command = AddNoteCommand(
          provider: noteProvider,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          tag: _tagController.text.trim().isEmpty
              ? null
              : _tagController.text.trim(),
        );
        success = await command.execute();
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditMode ? AppStrings.noteUpdated : AppStrings.noteAdded),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.error)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isEditMode ? AppStrings.editNote : AppStrings.addNote),
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _handleSave,
            tooltip: 'Lưu',
          ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                hintText: 'Nhập tiêu đề ghi chú',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.titleRequired;
                }
                if (value.length > 100) {
                  return 'Tiêu đề không được quá 100 ký tự';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),

            // Content Field
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung',
                hintText: 'Nhập nội dung ghi chú...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              minLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.contentRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.paddingMedium),

            // Tag Field
            TextFormField(
              controller: _tagController,
              decoration: const InputDecoration(
                labelText: 'Tag (tùy chọn)',
                hintText: 'work, personal, study...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Info (Created/Updated Date) - Edit mode only
            if (_isEditMode && widget.note != null) _buildMetadataInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Ngày tạo: ${DateTimeHelper.formatDateTime(widget.note!.createdAt)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Sửa lần cuối: ${DateTimeHelper.formatDateTime(widget.note!.updatedAt)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
