import 'package:flutter/material.dart';

// =====================================================
// =============== MODEL OOP TRANSPORTASI ===============
// =====================================================
abstract class Transportasi {
  String id;
  String nama;
  double _tarifDasar;
  int kapasitas;

  Transportasi(this.id, this.nama, this._tarifDasar, this.kapasitas);

  double get tarifDasar => _tarifDasar;
  double hitungTarif(int jumlahPenumpang);
  void tampilInfo();
}

class Taksi extends Transportasi {
  double jarak;
  Taksi(String id, String nama, double tarifDasar, int kapasitas, this.jarak)
    : super(id, nama, tarifDasar, kapasitas);

  @override
  double hitungTarif(int jumlahPenumpang) => tarifDasar * jarak;

  @override
  void tampilInfo() {
    print("Taksi $nama - Jarak $jarak km");
  }
}

class Bus extends Transportasi {
  bool adaWifi;
  Bus(String id, String nama, double tarifDasar, int kapasitas, this.adaWifi)
    : super(id, nama, tarifDasar, kapasitas);

  @override
  double hitungTarif(int jumlahPenumpang) =>
      (tarifDasar * jumlahPenumpang) + (adaWifi ? 5000 : 0);

  @override
  void tampilInfo() {
    print("Bus $nama - Wifi: ${adaWifi ? 'Ya' : 'Tidak'}");
  }
}

class Pesawat extends Transportasi {
  String kelasPenerbangan;
  Pesawat(
    String id,
    String nama,
    double tarifDasar,
    int kapasitas,
    this.kelasPenerbangan,
  ) : super(id, nama, tarifDasar, kapasitas);

  @override
  double hitungTarif(int jumlahPenumpang) =>
      tarifDasar * jumlahPenumpang * (kelasPenerbangan == "Bisnis" ? 1.5 : 1.0);

  @override
  void tampilInfo() {
    print("Pesawat $nama - Kelas $kelasPenerbangan");
  }
}

// =====================================================
// =============== MODEL PEMESANAN ======================
// =====================================================
class Pemesanan {
  String idPemesanan;
  String namaPelanggan;
  Transportasi transportasi;
  int jumlahPenumpang;
  double totalTarif;

  Pemesanan(
    this.idPemesanan,
    this.namaPelanggan,
    this.transportasi,
    this.jumlahPenumpang,
    this.totalTarif,
  );
}

// =====================================================
// =============== FUNGSI GLOBAL ========================
// =====================================================
Pemesanan buatPemesanan(Transportasi t, String nama, int jumlahPenumpang) {
  double total = t.hitungTarif(jumlahPenumpang);
  return Pemesanan(
    "PSN${DateTime.now().millisecondsSinceEpoch}",
    nama,
    t,
    jumlahPenumpang,
    total,
  );
}

// =====================================================
// =============== FLUTTER APP ==========================
// =====================================================
void main() {
  runApp(const SmartRideApp());
}

class SmartRideApp extends StatefulWidget {
  const SmartRideApp({super.key});

  @override
  State<SmartRideApp> createState() => _SmartRideAppState();
}

class _SmartRideAppState extends State<SmartRideApp> {
  final _namaController = TextEditingController();
  final _penumpangController = TextEditingController();

  Transportasi? _selectedTransport;
  final List<Pemesanan> _daftarPemesanan = [];

  // Daftar transportasi
  final List<Transportasi> _transportasi = [
    Taksi("T01", "Taksi BlueBird", 7000, 4, 10),
    Bus("B01", "Bus TransJakarta", 5000, 40, true),
    Pesawat("P01", "Garuda Indonesia", 1500000, 180, "Bisnis"),
  ];

  void _buatPemesanan() {
    if (_selectedTransport == null ||
        _namaController.text.isEmpty ||
        _penumpangController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi semua data terlebih dahulu!")),
      );
      return;
    }

    int jumlah = int.tryParse(_penumpangController.text) ?? 1;
    var pemesanan = buatPemesanan(
      _selectedTransport!,
      _namaController.text,
      jumlah,
    );

    setState(() {
      _daftarPemesanan.add(pemesanan);
    });

    _namaController.clear();
    _penumpangController.clear();
    _selectedTransport = null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("SmartRide - Pemesanan Transportasi"),
          backgroundColor: Colors.blueAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Form Pemesanan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: "Nama Pelanggan",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _penumpangController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Jumlah Penumpang",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Transportasi>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Pilih Transportasi",
                ),
                value: _selectedTransport,
                items: _transportasi
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.nama)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTransport = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Buat Pemesanan"),
                onPressed: _buatPemesanan,
              ),
              const SizedBox(height: 20),
              const Text(
                "Daftar Pemesanan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: _daftarPemesanan.isEmpty
                    ? const Center(child: Text("Belum ada pemesanan"))
                    : ListView.builder(
                        itemCount: _daftarPemesanan.length,
                        itemBuilder: (context, index) {
                          var p = _daftarPemesanan[index];
                          return Card(
                            child: ListTile(
                              title: Text(p.namaPelanggan),
                              subtitle: Text(
                                "${p.transportasi.nama} - ${p.jumlahPenumpang} org",
                              ),
                              trailing: Text(
                                "Rp${p.totalTarif.toStringAsFixed(0)}",
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
