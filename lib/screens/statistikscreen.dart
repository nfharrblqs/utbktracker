import 'package:flutter/material.dart';
import 'package:utbktracker/services/statistik_service.dart';

class StatistikScreen extends StatefulWidget {
  final int userId;
  const StatistikScreen({super.key, required this.userId});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  final StatistikService _statistikService = StatistikService();

  List<Map<String, dynamic>> ptnList = [];
  List<Map<String, dynamic>> prodiList1 = [];
  List<Map<String, dynamic>> prodiList2 = [];
  List<Map<String, dynamic>> prodiList3 = [];

  int? selectedPtn1;
  int? selectedProdi1;
  int? selectedPtn2;
  int? selectedProdi2;
  int? selectedPtn3;
  int? selectedProdi3;

  int currentScore = 0;
  int targetScore1 = 0;
  int targetScore2 = 0;
  int targetScore3 = 0;

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await _loadCurrentScore();

      await _loadPTNData();

      await _loadExistingPilihan();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCurrentScore() async {
    try {
      final score = await _statistikService.getUserCurrentScore(widget.userId);
      setState(() {
        currentScore = score;
      });
      print('Current score loaded: $currentScore');
    } catch (e) {
      print('Error loading current score: $e');
    }
  }

  Future<void> _loadPTNData() async {
    final ptn = await _statistikService.getAllPTN();
    setState(() {
      ptnList = ptn;
    });
  }

  Future<void> _loadExistingPilihan() async {
    try {
      final pilihan = await _statistikService.getPilihanWithDetails(
        widget.userId,
      );

      for (var p in pilihan) {
        final urutan = p['urutan'] as int;
        final ptnId = p['ptn_id'] as int;
        final prodiId = p['prodi_id'] as int;
        final targetScore = p['target_score'] as int;

        final prodi = await _statistikService.getProdiByPTN(ptnId);

        setState(() {
          if (urutan == 1) {
            selectedPtn1 = ptnId;
            selectedProdi1 = prodiId;
            prodiList1 = prodi;
            targetScore1 = targetScore;
          } else if (urutan == 2) {
            selectedPtn2 = ptnId;
            selectedProdi2 = prodiId;
            prodiList2 = prodi;
            targetScore2 = targetScore;
          } else if (urutan == 3) {
            selectedPtn3 = ptnId;
            selectedProdi3 = prodiId;
            prodiList3 = prodi;
            targetScore3 = targetScore;
          }
        });
      }
    } catch (e) {
      print('Error loading existing pilihan: $e');
    }
  }

  Future<void> _loadProdiData(int ptnId, int pilihanIndex) async {
    final prodi = await _statistikService.getProdiByPTN(ptnId);
    setState(() {
      if (pilihanIndex == 1) {
        prodiList1 = prodi;
        selectedProdi1 = null;
      } else if (pilihanIndex == 2) {
        prodiList2 = prodi;
        selectedProdi2 = null;
      } else if (pilihanIndex == 3) {
        prodiList3 = prodi;
        selectedProdi3 = null;
      }
    });
  }

  Future<void> _updateTargetScore(int prodiId, int pilihanIndex) async {
    final prodi = await _statistikService.getProdiById(prodiId);
    if (prodi != null && prodi.containsKey('target_score')) {
      setState(() {
        int targetScore = prodi['target_score'] as int;
        if (pilihanIndex == 1) {
          targetScore1 = targetScore;
        } else if (pilihanIndex == 2) {
          targetScore2 = targetScore;
        } else if (pilihanIndex == 3) {
          targetScore3 = targetScore;
        }
      });
    }
  }

  Future<void> _savePilihan() async {
    if (selectedProdi1 == null &&
        selectedProdi2 == null &&
        selectedProdi3 == null) {
      _showErrorDialog('Minimal pilih 1 PTN/Prodi');
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (selectedPtn1 != null && selectedProdi1 != null) {
        await _statistikService.savePilihan(
          widget.userId,
          1,
          selectedPtn1!,
          selectedProdi1!,
        );
      }

      if (selectedPtn2 != null && selectedProdi2 != null) {
        await _statistikService.savePilihan(
          widget.userId,
          2,
          selectedPtn2!,
          selectedProdi2!,
        );
      }

      if (selectedPtn3 != null && selectedProdi3 != null) {
        await _statistikService.savePilihan(
          widget.userId,
          3,
          selectedPtn3!,
          selectedProdi3!,
        );
      }

      setState(() => _isSaving = false);
      _showSuccessDialog('Pilihan berhasil disimpan!');
    } catch (e) {
      setState(() => _isSaving = false);
      _showErrorDialog('Gagal menyimpan pilihan: $e');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Berhasil!',
              style: TextStyle(color: Colors.green),
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
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
            title: const Text('Error!', style: TextStyle(color: Colors.red)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
          'Statistik Peluang Masuk PTN',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black, blurRadius: 4),
                ],
              ),
              child: const Center(
                child: Text(
                  'Rasionalisasi TO UTBK SNBT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B4C7E),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Analisis Peluang",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B4C7E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Nilai: $currentScore",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B4C7E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    _statistikService.getRecommendation(
                      currentScore,
                      targetScore1 > 0 ? targetScore1 : 0,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _buildPilihanCard(
              'Pilihan Pertama',
              1,
              selectedPtn1,
              selectedProdi1,
              prodiList1,
              targetScore1,
            ),
            _buildPilihanCard(
              'Pilihan Kedua',
              2,
              selectedPtn2,
              selectedProdi2,
              prodiList2,
              targetScore2,
            ),
            _buildPilihanCard(
              'Pilihan Ketiga',
              3,
              selectedPtn3,
              selectedProdi3,
              prodiList3,
              targetScore3,
            ),
            const SizedBox(height: 20),
            _buildSaveButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _savePilihan,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2B4C7E),
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isSaving
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
                      'Simpan Pilihan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildPilihanCard(
    String title,
    int pilihanIndex,
    int? selectedPtn,
    int? selectedProdi,
    List<Map<String, dynamic>> prodiList,
    int targetScore,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B4C7E),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Perguruan Tinggi Negeri',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
          const SizedBox(height: 5),
          _buildPTNDropdown(pilihanIndex, selectedPtn),
          const SizedBox(height: 10),
          const Text(
            'Program Studi',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
          const SizedBox(height: 5),
          _buildProdiDropdown(pilihanIndex, selectedProdi, prodiList),
          if (selectedProdi != null && prodiList.isNotEmpty)
            _buildProdiDetails(selectedProdi, prodiList, targetScore),
        ],
      ),
    );
  }

  Widget _buildPTNDropdown(int pilihanIndex, int? selectedValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF9BC8EB).withOpacity(0.5),
        border: Border.all(color: Colors.blueGrey, width: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButton<int>(
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text(
          'Pilih PTN',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        value: selectedValue,
        items:
            ptnList.map((ptn) {
              return DropdownMenuItem<int>(
                value: ptn['id'] as int,
                child: Text('${ptn['nama']} - ${ptn['kota']}'),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            if (pilihanIndex == 1) {
              selectedPtn1 = value;
            } else if (pilihanIndex == 2) {
              selectedPtn2 = value;
            } else if (pilihanIndex == 3) {
              selectedPtn3 = value;
            }
          });
          if (value != null) {
            _loadProdiData(value, pilihanIndex);
          }
        },
      ),
    );
  }

  Widget _buildProdiDropdown(
    int pilihanIndex,
    int? selectedValue,
    List<Map<String, dynamic>> prodiList,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF9BC8EB).withOpacity(0.5),
        border: Border.all(color: Colors.blueGrey, width: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButton<int>(
        isExpanded: true,
        underline: const SizedBox(),
        hint: const Text(
          'Pilih Prodi',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        value: selectedValue,
        items:
            prodiList.map((prodi) {
              return DropdownMenuItem<int>(
                value: prodi['id'] as int,
                child: Text(prodi['nama'] as String),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            if (pilihanIndex == 1) {
              selectedProdi1 = value;
            } else if (pilihanIndex == 2) {
              selectedProdi2 = value;
            } else if (pilihanIndex == 3) {
              selectedProdi3 = value;
            }
          });

          if (value != null) {
            _updateTargetScore(value, pilihanIndex);
          }
        },
      ),
    );
  }

  Widget _buildProdiDetails(
    int prodiId,
    List<Map<String, dynamic>> prodiList,
    int targetScore,
  ) {
    final prodi = prodiList.firstWhere(
      (p) => p['id'] == prodiId,
      orElse: () => {},
    );

    if (prodi.isEmpty) {
      return const SizedBox.shrink();
    }

    final dayaTampung = prodi['daya_tampung'] as int;
    final peminat = prodi['peminat'] as int;
    final passingRate = _statistikService.calculatePassingRate(
      dayaTampung,
      peminat,
    );
    final peluangLolos = _statistikService.calculatePeluang(
      currentScore,
      targetScore,
    );

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Program Studi:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daya Tampung: $dayaTampung',
                style: const TextStyle(fontSize: 12),
              ),
              Text('Peminat: $peminat', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: passingRate / 100 > 1 ? 1 : passingRate / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              passingRate > 10
                  ? Colors.red
                  : passingRate > 5
                  ? Colors.orange
                  : Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tingkat Kelulusan: ${passingRate.toStringAsFixed(2)}%',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'Peluang Lolos: $peluangLolos',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color:
                    peluangLolos == 'Tinggi'
                        ? Colors.green
                        : peluangLolos == 'Cukup'
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
