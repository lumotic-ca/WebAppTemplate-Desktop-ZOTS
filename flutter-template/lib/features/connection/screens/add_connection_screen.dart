import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webapp_template/core/utils/url_validator.dart';
import 'package:webapp_template/features/connection/models/saved_connection.dart';
import 'package:webapp_template/features/connection/providers/connection_providers.dart';

class AddConnectionScreen extends ConsumerStatefulWidget {
  const AddConnectionScreen({super.key, this.existing});

  final SavedConnection? existing;

  @override
  ConsumerState<AddConnectionScreen> createState() =>
      _AddConnectionScreenState();
}

class _AddConnectionScreenState extends ConsumerState<AddConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  var _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existing?.displayName ?? '',
    );
    _urlController = TextEditingController(
      text: widget.existing?.url ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        final validation = UrlValidator.validate(_urlController.text);
        if (!validation.isValid || validation.normalizedUrl == null) {
          throw StateError(validation.error ?? 'Invalid URL');
        }

        final updated = widget.existing!.copyWith(
          displayName: _nameController.text.trim().isEmpty
              ? UrlValidator.displayHost(validation.normalizedUrl!)
              : _nameController.text.trim(),
          url: validation.normalizedUrl,
        );
        await ref
            .read(connectionsProvider.notifier)
            .updateConnection(updated);
      } else {
        await ref.read(connectionsProvider.notifier).addConnection(
              displayName: _nameController.text,
              url: _urlController.text,
            );
      }

      if (mounted) {
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit server' : 'Add server'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isEditing
                        ? 'Update this saved server.'
                        : 'Enter the web app URL you want to wrap.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      hintText: 'My App Server',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'https://app.example.com',
                      helperText: 'http and https URLs are supported.',
                    ),
                    keyboardType: TextInputType.url,
                    autofillHints: const [AutofillHints.url],
                    validator: (value) {
                      final validation = UrlValidator.validate(value ?? '');
                      return validation.isValid ? null : validation.error;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Save changes' : 'Save server'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
