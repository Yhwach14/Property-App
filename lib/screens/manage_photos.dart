import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/auth_bloc.dart';
import '../core/properties_repository.dart';
import '../models/property.dart';

class ManagePhotosScreen extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;

  const ManagePhotosScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<ManagePhotosScreen> createState() => _ManagePhotosScreenState();
}

class _ManagePhotosScreenState extends State<ManagePhotosScreen> {
  final _repository = PropertiesRepository();
  final _picker = ImagePicker();

  List<PropertyImage> _images = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final token = context.read<AuthBloc>().state.token;
    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Not logged in';
      });
      return;
    }
    try {
      final detail = await _repository.fetchMyPropertyDetail(
        widget.propertyId,
        token: token,
      );
      setState(() {
        _images = [...detail.images]
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    }
  }

  Future<void> _pickAndUpload() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;

    final token = context.read<AuthBloc>().state.token;
    if (token == null) return;

    if (_images.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A property can have at most 10 photos')),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final image = await _repository.uploadImage(
        widget.propertyId,
        File(picked.path),
        token: token,
      );
      setState(() {
        _images.add(image);
        _isUploading = false;
      });
    } on ApiException catch (e) {
      setState(() => _isUploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _setCover(PropertyImage image) async {
    if (image.isCover) return;
    final token = context.read<AuthBloc>().state.token;
    if (token == null) return;

    try {
      await _repository.setImageCover(
        widget.propertyId,
        image.id,
        token: token,
      );
      setState(() {
        _images = _images
            .map(
              (img) => PropertyImage(
                id: img.id,
                url: img.url,
                sortOrder: img.sortOrder,
                isCover: img.id == image.id,
              ),
            )
            .toList();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _deleteImage(PropertyImage image) async {
    final token = context.read<AuthBloc>().state.token;
    if (token == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete photo?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repository.deleteImage(widget.propertyId, image.id, token: token);
      await _loadImages(); // reload — deleting the cover promotes another image server-side
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photos — ${widget.propertyTitle}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : RefreshIndicator(
              onRefresh: _loadImages,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final image = _images[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(image.url, fit: BoxFit.cover),
                      ),
                      if (image.isCover)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Cover',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Row(
                          children: [
                            if (!image.isCover)
                              _RoundIconButton(
                                icon: Icons.star_border,
                                tooltip: 'Set as cover',
                                onTap: () => _setCover(image),
                              ),
                            _RoundIconButton(
                              icon: Icons.delete_outline,
                              tooltip: 'Delete',
                              onTap: () => _deleteImage(image),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _pickAndUpload,
        icon: _isUploading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_a_photo_outlined),
        label: Text(_isUploading ? 'Uploading...' : 'Add photo'),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: Colors.black54,
        shape: const CircleBorder(),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 18),
          tooltip: tooltip,
          onPressed: onTap,
        ),
      ),
    );
  }
}
