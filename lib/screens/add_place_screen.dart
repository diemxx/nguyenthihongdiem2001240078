import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/place_model.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});
  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _rating = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _saving = false;
  String _selectedImage = 'assets/images/1.jpg';

  @override
  void dispose() {
    _name.dispose(); _rating.dispose(); _phone.dispose(); _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      await DatabaseHelper.instance.insertPlace(Place(
        name: _name.text.trim(),
        rating: double.parse(_rating.text.trim().replaceAll(',', '.')),
        phone: _phone.text.trim(), address: _address.text.trim(),
        imagePath: _selectedImage,
      ));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không lưu được địa điểm: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Thêm địa điểm')),
    body: Form(key: _formKey, child: ListView(
      padding: const EdgeInsets.all(18), children: [
        const Text('Thông tin địa điểm', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        TextFormField(controller: _name, decoration: const InputDecoration(
          labelText: 'Tên địa điểm', prefixIcon: Icon(Icons.place_outlined), border: OutlineInputBorder()),
          validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tên địa điểm' : null),
        const SizedBox(height: 14),
        TextFormField(controller: _rating, keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Điểm đánh giá (1.0 - 5.0)',
            prefixIcon: Icon(Icons.star_border), border: OutlineInputBorder()),
          validator: (v) {
            final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
            if (n == null || !n.isFinite || n < 1 || n > 5) return 'Điểm phải là số từ 1.0 đến 5.0';
            return null;
          }),
        const SizedBox(height: 14),
        TextFormField(controller: _phone, keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Số điện thoại liên hệ',
            prefixIcon: Icon(Icons.phone_outlined), border: OutlineInputBorder()),
          validator: (v) {
            final p = (v ?? '').trim();
            if (p.isEmpty) return 'Vui lòng nhập số điện thoại';
            if (!RegExp(r'^\d{10,}$').hasMatch(p)) return 'Số điện thoại phải có ít nhất 10 chữ số';
            return null;
          }),
        const SizedBox(height: 14),
        TextFormField(controller: _address, maxLines: 2,
          decoration: const InputDecoration(labelText: 'Địa chỉ',
            prefixIcon: Icon(Icons.location_on_outlined), border: OutlineInputBorder()),
          validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập địa chỉ' : null),
        const SizedBox(height: 20),
        const Text('Chọn ảnh địa điểm', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.25),
          itemCount: 12,
          itemBuilder: (context, index) {
            final path = 'assets/images/${index + 1}.jpg';
            final selected = path == _selectedImage;
            return InkWell(
              onTap: () => setState(() => _selectedImage = path),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: selected ? Colors.teal : Colors.transparent, width: 3),
                  borderRadius: BorderRadius.circular(10)),
                clipBehavior: Clip.antiAlias,
                child: Stack(fit: StackFit.expand, children: [
                  Image.asset(path, fit: BoxFit.cover),
                  if (selected) const Align(alignment: Alignment.topRight,
                    child: Icon(Icons.check_circle, color: Colors.teal)),
                ]),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        FilledButton.icon(onPressed: _saving ? null : _save,
          icon: _saving ? const SizedBox(width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
          label: Text(_saving ? 'Đang lưu...' : 'Lưu địa điểm'),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16))),
      ],
    )),
  );
}
