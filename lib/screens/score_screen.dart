import 'package:flutter/material.dart';
import 'package:utbktracker/services/score_service.dart';

class ScoreScreen extends StatefulWidget {
  final int userId;
  const ScoreScreen({super.key, required this.userId});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  final ScoreService scoreService = ScoreService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _penalaranUmumController;
  late TextEditingController _pengetahuanUmumController;
  late TextEditingController _pemahamanBacaanController;
  late TextEditingController _pengetahuanKuantitatifController;
  late TextEditingController _literasiBahasaIndonesiaController;
  late TextEditingController _literasiBahasaInggrisController;
  late TextEditingController _penalaranMatematikaController;

  int totalScore = 0;
  bool _isLoading = false;
  int _tryoutCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadTryoutCount();
  }

  void _initializeControllers() {
    _penalaranUmumController = TextEditingController();
    _pengetahuanUmumController = TextEditingController();
    _pemahamanBacaanController = TextEditingController();
    _pengetahuanKuantitatifController = TextEditingController();
    _literasiBahasaIndonesiaController = TextEditingController();
    _literasiBahasaInggrisController = TextEditingController();
    _penalaranMatematikaController = TextEditingController();
  }

  Future<void> _loadTryoutCount() async {
    final allScores = await scoreService.getAllScoreByUser(widget.userId);
    setState(() {
      _tryoutCount = allScores.length;
    });
  }

  void _calculateTotal() {
    int total = 0;
    int count = 0;

    final controllers = [
      _penalaranUmumController,
      _pengetahuanUmumController,
      _pemahamanBacaanController,
      _pengetahuanKuantitatifController,
      _literasiBahasaIndonesiaController,
      _literasiBahasaInggrisController,
      _penalaranMatematikaController,
    ];

    for (var controller in controllers) {
      if (controller.text.isNotEmpty) {
        total += int.parse(controller.text);
        count++;
      }
    }

    setState(() {
      totalScore = count > 0 ? (total ~/ count) : 0;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final scoreData = {
          'user_id': widget.userId,
          'penalaran_umum': int.parse(_penalaranUmumController.text),
          'pengetahuan_pemahaman_umum': int.parse(
            _pengetahuanUmumController.text,
          ),
          'pemahaman_bacaan_menulis': int.parse(
            _pemahamanBacaanController.text,
          ),
          'pengetahuan_kuantitatif': int.parse(
            _pengetahuanKuantitatifController.text,
          ),
          'literasi_bahasa_indonesia': int.parse(
            _literasiBahasaIndonesiaController.text,
          ),
          'literasi_bahasa_inggris': int.parse(
            _literasiBahasaInggrisController.text,
          ),
          'penalaran_matematika': int.parse(
            _penalaranMatematikaController.text,
          ),
        };

        final result = await scoreService.insertScore(scoreData);

        setState(() => _isLoading = false);

        if (result > 0) {
          await _showSuccessDialog(
            'Score tryout ke-${_tryoutCount + 1} berhasil disimpan!',
          );
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          _showErrorDialog('Gagal menyimpan score');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog('Terjadi kesalahan: $e');
      }
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Berhasil!',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Gagal!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _penalaranUmumController.dispose();
    _pengetahuanUmumController.dispose();
    _pemahamanBacaanController.dispose();
    _pengetahuanKuantitatifController.dispose();
    _literasiBahasaIndonesiaController.dispose();
    _literasiBahasaInggrisController.dispose();
    _penalaranMatematikaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE6F2FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Input Score UTBK',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, blurRadius: 4),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note_add,
                          color: const Color(0xFF2B4C7E),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Masukkan Score Tryout',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF2B4C7E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Score berkisar 0-1000',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 16,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tryout ke-${_tryoutCount + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildScoreInputField(
                'Penalaran Umum',
                _penalaranUmumController,
                'Kemampuan penalaran umum dan logika',
              ),
              _buildScoreInputField(
                'Pengetahuan & Pemahaman Umum',
                _pengetahuanUmumController,
                'Pengetahuan umum dan wawasan',
              ),
              _buildScoreInputField(
                'Pemahaman Bacaan & Menulis',
                _pemahamanBacaanController,
                'Kemampuan membaca dan menulis',
              ),
              _buildScoreInputField(
                'Pengetahuan Kuantitatif',
                _pengetahuanKuantitatifController,
                'Kemampuan kuantitatif dasar',
              ),
              _buildScoreInputField(
                'Literasi Bahasa Indonesia',
                _literasiBahasaIndonesiaController,
                'Kemampuan Bahasa Indonesia',
              ),
              _buildScoreInputField(
                'Literasi Bahasa Inggris',
                _literasiBahasaInggrisController,
                'Kemampuan Bahasa Inggris',
              ),
              _buildScoreInputField(
                'Penalaran Matematika',
                _penalaranMatematikaController,
                'Kemampuan penalaran matematika',
              ),
              const SizedBox(height: 20),
              _buildTotalScoreCard(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreInputField(
    String label,
    TextEditingController controller,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF2B4C7E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: (_) => _calculateTotal(),
            decoration: InputDecoration(
              hintText: 'Masukkan score (0-1000)',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF9BC8EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF9BC8EB),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF2B4C7E),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Score harus diisi';
              }
              try {
                int score = int.parse(value);
                if (!scoreService.validateScore(score)) {
                  return 'Score harus antara 0-1000';
                }
              } catch (e) {
                return 'Score harus berupa angka';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B4C7E), Color(0xFF5A7BA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        children: [
          const Text(
            'Total Score (Rata-rata)',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            totalScore.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getScoreStatus(totalScore),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreStatus(int score) {
    if (score >= 800) return 'Fenomenom!';
    if (score >= 700) return 'Perfecto!';
    if (score >= 600) return 'Cukup';
    if (score >= 500) return 'Perlu ditingkatkan';
    return 'Perlu belajar lebih giat';
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2B4C7E),
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
                : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Simpan Score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
