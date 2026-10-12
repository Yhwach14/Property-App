import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../core/properties_repository.dart';
import '../models/property.dart';

class PropertyFormScreen extends StatefulWidget {
  final PropertyDetail? existing; // null = create mode

  const PropertyFormScreen({super.key, this.existing});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _pageController = PageController();
  final _repository = PropertiesRepository();

  int _step = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _currencyController;
  late final TextEditingController _cityController;
  late final TextEditingController _addressController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;
  late final TextEditingController _maxGuestsController;
  late final TextEditingController _contactEmailController;
  late final TextEditingController _contactPhoneController;

  String _type = 'APARTMENT';
  String _pricePeriod = 'PER_NIGHT';
  bool _isPublished = false;
  final Set<String> _selectedAmenityIds = {};

  List<Amenity> _amenities = [];
  bool _loadingAmenities = true;

  bool get _isEditMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;

    _titleController = TextEditingController(text: p?.title ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toString() : '',
    );
    _currencyController = TextEditingController(text: p?.currency ?? 'USD');
    _cityController = TextEditingController(text: p?.city ?? '');
    _addressController = TextEditingController(text: p?.address ?? '');
    _bedroomsController = TextEditingController(
      text: p != null ? p.bedrooms.toString() : '',
    );
    _bathroomsController = TextEditingController(
      text: p != null ? p.bathrooms.toString() : '',
    );
    _maxGuestsController = TextEditingController(
      text: p != null ? p.maxGuests.toString() : '',
    );
    _contactEmailController = TextEditingController(
      text: p?.contactEmail ?? '',
    );
    _contactPhoneController = TextEditingController(
      text: p?.contactPhone ?? '',
    );

    if (p != null) {
      _type = p.type;
      _pricePeriod = p.pricePeriod;
      _isPublished = p.isPublished ?? false;
      _selectedAmenityIds.addAll(p.amenities.map((a) => a.id));
    }

    _loadAmenities();
  }

  Future<void> _loadAmenities() async {
    try {
      final amenities = await _repository.fetchAmenities();
      if (!mounted) return;
      setState(() {
        _amenities = amenities;
        _loadingAmenities = false;
      });
    } on ApiException catch (_) {
      if (!mounted) return;
      setState(() => _loadingAmenities = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _maxGuestsController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  bool _validateBasicsStep() {
    if (_titleController.text.trim().length < 3) {
      _showStepError('Title must be at least 3 characters');
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showStepError('Description is required');
      return false;
    }
    final price = num.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      _showStepError('Enter a valid price');
      return false;
    }
    return true;
  }

  bool _validateLocationStep() {
    if (_cityController.text.trim().isEmpty) {
      _showStepError('City is required');
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      _showStepError('Address is required');
      return false;
    }
    if (int.tryParse(_bedroomsController.text.trim()) == null) {
      _showStepError('Enter a valid number of bedrooms');
      return false;
    }
    if (int.tryParse(_bathroomsController.text.trim()) == null) {
      _showStepError('Enter a valid number of bathrooms');
      return false;
    }
    final guests = int.tryParse(_maxGuestsController.text.trim());
    if (guests == null || guests < 1) {
      _showStepError('Enter a valid guest count');
      return false;
    }
    return true;
  }

  void _showStepError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_step == 0 && !_validateBasicsStep()) return;
    if (_step == 1 && !_validateLocationStep()) return;
    if (_step < 3) _goToStep(_step + 1);
  }

  void _back() {
    if (_step > 0) _goToStep(_step - 1);
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'type': _type,
      'pricePeriod': _pricePeriod,
      'price': num.parse(_priceController.text.trim()),
      'currency': _currencyController.text.trim().isEmpty
          ? 'USD'
          : _currencyController.text.trim().toUpperCase(),
      'city': _cityController.text.trim(),
      'address': _addressController.text.trim(),
      'bedrooms': int.parse(_bedroomsController.text.trim()),
      'bathrooms': int.parse(_bathroomsController.text.trim()),
      'maxGuests': int.parse(_maxGuestsController.text.trim()),
      if (_contactEmailController.text.trim().isNotEmpty)
        'contactEmail': _contactEmailController.text.trim(),
      if (_contactPhoneController.text.trim().isNotEmpty)
        'contactPhone': _contactPhoneController.text.trim(),
      'amenityIds': _selectedAmenityIds.toList(),
      'isPublished': _isPublished,
    };
  }

  Future<void> _submit() async {
    final token = context.read<AuthBloc>().state.token;
    if (token == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final payload = _buildPayload();
      if (_isEditMode) {
        await _repository.updateProperty(
          widget.existing!.id,
          payload,
          token: token,
        );
      } else {
        await _repository.createProperty(payload, token: token);
      }
      if (!mounted) return;
      Navigator.of(
        context,
      ).pop(true); // true = something changed, caller should refresh
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['Basics', 'Location', 'Amenities', 'Review'];

    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Listing' : 'Add Listing')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: List.generate(steps.length, (i) {
                final isActive = i == _step;
                final isDone = i < _step;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: i == steps.length - 1 ? 0 : 6,
                    ),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive || isDone
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Step ${_step + 1} of 4 — ${steps[_step]}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _step = i),
              children: [
                _buildBasicsStep(),
                _buildLocationStep(),
                _buildAmenitiesStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : _back,
                      child: const Text('Back'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : (_step < 3 ? _next : _submit),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _step < 3
                                ? 'Next'
                                : (_isEditMode
                                      ? 'Save Changes'
                                      : 'Publish Listing'),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Property type'),
            items: const [
              DropdownMenuItem(value: 'APARTMENT', child: Text('Apartment')),
              DropdownMenuItem(value: 'VILLA', child: Text('Villa')),
              DropdownMenuItem(value: 'MOTEL', child: Text('Motel')),
              DropdownMenuItem(value: 'CABIN', child: Text('Cabin')),
              DropdownMenuItem(value: 'OTHER', child: Text('Other')),
            ],
            onChanged: (value) => setState(() => _type = value!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _currencyController,
                  decoration: const InputDecoration(labelText: 'Currency'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _pricePeriod,
            decoration: const InputDecoration(labelText: 'Price period'),
            items: const [
              DropdownMenuItem(value: 'PER_NIGHT', child: Text('Per night')),
              DropdownMenuItem(value: 'PER_MONTH', child: Text('Per month')),
            ],
            onChanged: (value) => setState(() => _pricePeriod = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'City'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _bedroomsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Bedrooms'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _bathroomsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Bathrooms'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _maxGuestsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Max guests'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contactEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Contact email (optional)',
              helperText: 'Leave blank to use your account email',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contactPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Contact phone (optional)',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesStep() {
    if (_loadingAmenities) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_amenities.isEmpty) {
      return const Center(child: Text('No amenities available'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _amenities.map((amenity) {
          final isSelected = _selectedAmenityIds.contains(amenity.id);
          return FilterChip(
            label: Text(amenity.name),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedAmenityIds.add(amenity.id);
                } else {
                  _selectedAmenityIds.remove(amenity.id);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewStep() {
    final selectedAmenities = _amenities
        .where((a) => _selectedAmenityIds.contains(a.id))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titleController.text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('${_cityController.text} • ${_addressController.text}'),
          const SizedBox(height: 12),
          Text(
            '${_priceController.text} ${_currencyController.text} / ${_pricePeriod == 'PER_NIGHT' ? 'night' : 'month'}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('${_bedroomsController.text} bed'),
              const SizedBox(width: 12),
              Text('${_bathroomsController.text} bath'),
              const SizedBox(width: 12),
              Text('${_maxGuestsController.text} guests'),
            ],
          ),
          const SizedBox(height: 16),
          Text(_descriptionController.text),
          if (selectedAmenities.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Amenities',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedAmenities
                  .map((a) => Chip(label: Text(a.name)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Publish immediately'),
            subtitle: Text(
              _isPublished
                  ? 'Visible to everyone right away'
                  : 'Saved as a draft, not publicly visible yet',
            ),
            value: _isPublished,
            onChanged: (value) => setState(() => _isPublished = value),
          ),
          if (!_isEditMode) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can add photos right after this listing is created.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
