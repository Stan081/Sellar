import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellar/src/features/products/data/product_repository.dart';
import 'package:sellar/src/features/products/data/upload_repository.dart';
import 'package:sellar/src/services/app_services.dart';
import 'package:sellar/src/theme/app_colors.dart';

class _ProductImageItem {
  _ProductImageItem({required this.file, this.isUploading});

  final File file;
  String? uploadedUrl;
  bool? isUploading;
}

/// Screen for adding a new product
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _tagController = TextEditingController();

  String _selectedCategory = 'Electronics';
  String _selectedCurrency = 'USD';
  final List<String> _tags = [];
  bool _isSaving = false;

  final List<_ProductImageItem> _images = [];

  late final ProductRepository _repo;
  late final UploadRepository _uploadRepo;

  bool get _isUploadingAnyImage => _images.any((i) => (i.isUploading ?? false));

  List<String> get _uploadedImageUrls => _images
      .map((i) => i.uploadedUrl)
      .whereType<String>()
      .where((u) => u.isNotEmpty)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _repo = ProductRepository(apiService: AppServices.api);
    _uploadRepo = UploadRepository(apiService: AppServices.api);
  }

  static const List<String> _categories = [
    'Electronics',
    'Accessories',
    'Clothing',
    'Food & Beverage',
    'Fitness',
    'Home & Office',
    'Footwear',
    'Stationery',
    'Beauty & Health',
    'Other',
  ];

  static const List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'NGN',
    'GHS',
    'KES',
    'ZAR',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _addAndUploadImages(List<File> files) async {
    if (files.isEmpty) return;

    final startIndex = _images.length;
    setState(() {
      for (final f in files) {
        _images.add(_ProductImageItem(file: f, isUploading: true));
      }
    });

    for (var idx = startIndex; idx < startIndex + files.length; idx++) {
      final item = _images[idx];
      try {
        final url = await _uploadRepo.uploadImage(item.file);
        if (!mounted) return;
        setState(() {
          item.uploadedUrl = url;
          item.isUploading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _images.remove(item);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImagesFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked.isEmpty) return;

    await _addAndUploadImages(picked.map((p) => File(p.path)).toList());
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;

    await _addAndUploadImages([File(picked.path)]);
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text('Add Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImagesFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addTag(String value) {
    final tag = value.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 8) {
      setState(() => _tags.add(tag));
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _saveProduct() async {
    if (_isUploadingAnyImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please wait for images to finish uploading')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final product = await _repo.createProduct(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        price: double.parse(_priceController.text.trim()),
        quantity: _quantityController.text.trim().isNotEmpty
            ? int.tryParse(_quantityController.text.trim())
            : null,
        tags: List.from(_tags),
        images: _uploadedImageUrls,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context, product);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        actions: [
          TextButton(
            onPressed:
                (_isSaving || _isUploadingAnyImage) ? null : _saveProduct,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImagePicker(),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Product Info',
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Product Name',
                  hint: 'e.g. Wireless Headphones',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Describe your product...',
                  maxLines: 4,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Description is required'
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Pricing',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _priceController,
                        label: 'Price',
                        hint: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Price is required';
                          }
                          if (double.tryParse(v.trim()) == null) {
                            return 'Enter a valid price';
                          }
                          if (double.parse(v.trim()) <= 0) {
                            return 'Price must be > 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Currency',
                        value: _selectedCurrency,
                        items: _currencies,
                        onChanged: (v) =>
                            setState(() => _selectedCurrency = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _quantityController,
                  label: 'Quantity (optional)',
                  hint: 'Leave blank for unlimited',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Category',
              children: [
                _buildDropdown(
                  label: 'Category',
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Tags',
              subtitle: 'Add up to 8 tags to help customers find your product',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          hintText: 'e.g. wireless, bluetooth',
                          hintStyle: const TextStyle(color: AppColors.textHint),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _addTag(_tagController.text),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: _addTag,
                      ),
                    ),
                  ],
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _removeTag(tag),
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            labelStyle: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_isSaving || _isUploadingAnyImage) ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Product'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    if (_images.isNotEmpty) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.2,
        ),
        itemCount: _images.length + 1,
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          final item = _images[index];
          final isUploading = item.isUploading ?? false;
          final uploaded = (item.uploadedUrl ?? '').isNotEmpty;

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  item.file,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              if (!isUploading)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _images.removeAt(index);
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
              if (uploaded)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('Uploaded',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add Product Photos',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap to upload from gallery or camera',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
