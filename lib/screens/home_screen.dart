import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/database_helper.dart';
import '../models/place_model.dart';
import 'add_place_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Place> _places = [];
  bool _loading = true;
  bool _grid = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final places = await DatabaseHelper.instance.getAllPlaces();
      if (mounted) setState(() { _places = places; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    }
  }

  Future<void> _add() async {
    final saved = await Navigator.push<bool>(context,
      MaterialPageRoute(builder: (_) => const AddPlaceScreen()));
    if (saved == true) await _load();
  }

  Future<void> _delete(Place place) async {
    if (place.id == null) return;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Xóa địa điểm?'), content: Text('Bạn muốn xóa ${place.name}?'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa'))]));
    if (confirmed != true) return;
    await DatabaseHelper.instance.deletePlace(place.id!);
    await _load();
  }

  Future<void> _open(Uri uri) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Không có ứng dụng phù hợp');
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được ứng dụng. Hãy kiểm tra thiết bị.')));
    }
  }

  Widget _placeCard(Place place, int index) => Card(
    color: Colors.white,
    elevation: 5,
    shadowColor: const Color(0x33009688),
    margin: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 8,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(
        color: Color(0xFFD6EFEB),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: const EdgeInsets.all(12), child: Column(
      mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(
          place.imagePath, height: _grid ? 95 : 125,
          width: double.infinity, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox(height: 95,
            child: Center(child: Icon(Icons.landscape, size: 45))))),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.place, color: Colors.teal, size: 20),
          const SizedBox(width: 5),
          Expanded(child: Text(place.name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          IconButton(tooltip: 'Xóa', visualDensity: VisualDensity.compact,
            onPressed: () => _delete(place), icon: const Icon(Icons.delete_outline, color: Colors.red)),
        ]),
        Row(children: [const Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 4), Text('${place.rating.toStringAsFixed(1)} sao')]),
        const SizedBox(height: 4),
        if (place.phone.trim().isNotEmpty) InkWell(onTap: () => _open(Uri(scheme: 'tel',
            path: place.phone)),
          child: Row(children: [const Icon(Icons.phone, size: 17),
            const SizedBox(width: 6),
            Expanded(child: Text(place.phone, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(decoration: TextDecoration.underline)))])),
        const SizedBox(height: 5),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.location_on_outlined, size: 18), const SizedBox(width: 5),
          Expanded(child: Text(place.address, maxLines: 2, overflow: TextOverflow.ellipsis)),
        ]),
        Align(alignment: Alignment.centerRight, child: TextButton.icon(
          onPressed: () => _open(Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(place.address)}')),
          icon: const Icon(Icons.map_outlined), label: const Text('Bản đồ'))),
      ],
    )),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sổ tay Địa điểm Du lịch'), actions: [
      IconButton(tooltip: _grid ? 'Xem danh sách' : 'Xem dạng lưới',
        onPressed: () => setState(() => _grid = !_grid),
        icon: Icon(_grid ? Icons.view_list : Icons.grid_view)),
      IconButton(tooltip: 'Làm mới', onPressed: _load, icon: const Icon(Icons.refresh)),
    ]),
    body: _loading ? const Center(child: CircularProgressIndicator())
      : _places.isEmpty ? const Center(child: Text('Chưa có địa điểm nào'))
      : _grid ? LayoutBuilder(builder: (context, constraints) => GridView.builder(
          padding: const EdgeInsets.all(10), itemCount: _places.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisExtent: 335, crossAxisSpacing: 6, mainAxisSpacing: 6),
          itemBuilder: (context, index) => _placeCard(_places[index], index)))
      : ListView.builder(padding: const EdgeInsets.all(10), itemCount: _places.length,
          itemBuilder: (context, index) => _placeCard(_places[index], index)),
    floatingActionButton: FloatingActionButton.extended(onPressed: _add,
      icon: const Icon(Icons.add), label: const Text('Thêm địa điểm')),
  );
}
