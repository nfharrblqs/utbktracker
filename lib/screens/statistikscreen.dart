import 'package:flutter/material.dart';
import 'package:utbktracker/services/statistik_service.dart';

class StatistikScreen extends StatefulWidget {
  final int userId;
  const StatistikScreen({super.key, required this.userId});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  Color _getColorFromHex(String hexColor) {
    try {
      String cleanedColor = hexColor.replaceAll('#', '');
      if (cleanedColor.length == 6) {
        return Color(int.parse('FF$cleanedColor', radix: 16));
      } else if (cleanedColor.length == 8) {
        return Color(int.parse(cleanedColor, radix: 16));
      } else {
        return Colors.green;
      }
    } catch (e) {
      print('Error parsing color: $e, value: $hexColor');
      return Colors.green;
    }
  }

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

  int? currentScore;
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
      final score = await _statistikService.loadCurrentScore(widget.userId);
      setState(() {
        currentScore = score;
      });
      print('Current score loaded: $currentScore');
    } catch (e) {
      print('Error loading current score: $e');
    }
  }

  Future<void> _loadPTNData() async {
    final ptn = await _statistikService.loadPTNList();
    setState(() {
      ptnList = ptn;
    });
  }

  Future<void> _loadExistingPilihan() async {
    try {
      final pilihan = await _statistikService.loadUserPilihan(widget.userId);

      for (var p in pilihan) {
        final urutan = p['urutan'] as int;
        final ptnId = p['ptn_id'] as int;
        final prodiId = p['prodi_id'] as int;
        final targetScore = p['target_score'] as int;

        final prodi = await _statistikService.loadProdiByPTN(ptnId);

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
    final prodi = await _statistikService.loadProdiByPTN(ptnId);
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
    final targetScore = await _statistikService.getTargetScoreByProdiId(
      prodiId,
    );
    if (targetScore != null) {
      setState(() {
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
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Rasionalisasi TO UTBK SNBT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B4C7E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B4C7E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentScore != null
                          ? "Nilai UTBK: $currentScore"
                          : "Nilai UTBK: Belum diisi",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B4C7E),
                        fontSize: 12,
                      ),
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
    String prodiNama = '';
    String ptnNama = '';
    if (selectedProdi != null) {
      final prodi = prodiList.firstWhere(
        (p) => p['id'] == selectedProdi,
        orElse: () => {},
      );
      if (prodi.isNotEmpty) {
        prodiNama = prodi['nama'] as String;
        final ptn = ptnList.firstWhere(
          (p) => p['id'] == selectedPtn,
          orElse: () => {},
        );
        ptnNama = ptn.isNotEmpty ? (ptn['nama'] as String) : '';
      }
    }

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
                fontSize: 16,
                color: Color(0xFF2B4C7E),
              ),
            ),
          ),

          const SizedBox(height: 8),

          if (selectedProdi != null && targetScore > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF2B4C7E), const Color(0xFF5A7BA8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TARGET SCORE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statistikService.calculatePeluang(
                            currentScore ?? 0,
                            targetScore,
                          ),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$targetScore',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Minimal nilai yang dibutuhkan untuk $prodiNama - $ptnNama',
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),

                  if (currentScore != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Selisih dengan nilai Anda:',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            _getSelisihText(currentScore!, targetScore),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  currentScore! >= targetScore
                                      ? Colors.white
                                      : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (selectedProdi == null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pilih PTN dan Program Studi untuk melihat target score',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                ],
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

  String _getSelisihText(int currentScore, int targetScore) {
    int selisih = targetScore - currentScore;
    if (selisih <= 0) {
      return '+${selisih.abs()} poin (melebihi target)';
    } else {
      return '-$selisih poin (kurang dari target)';
    }
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

    if (currentScore == null) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Column(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
            SizedBox(height: 8),
            Text(
              'Anda belum mengisi score UTBK',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Silakan input score UTBK terlebih dahulu di halaman Dashboard',
              style: TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return FutureBuilder(
      future: _statistikService.calculatePeluangStatistika(
        currentScore: currentScore!,
        targetScore: targetScore,
        userId: widget.userId,
        dayaTampung: dayaTampung,
        peminat: peminat,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!;
        final passingRate = _statistikService.calculatePassingRate(
          dayaTampung,
          peminat,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Target Score:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B4C7E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$targetScore',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF2B4C7E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              const Text(
                'Analisis Statistika',
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
                  Text(
                    'Peminat: $peminat',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 8),

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
              Text(
                'Tingkat Kelulusan: ${passingRate.toStringAsFixed(2)}%',
                style: const TextStyle(fontSize: 11),
              ),

              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Peluang Lolos:', style: TextStyle(fontSize: 12)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getColorFromHex(
                        data['color'] ?? '#4CAF50',
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${data['persentase'] ?? '0'}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getColorFromHex(data['color'] ?? '#4CAF50'),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                'Kategori: ${data['peluang'] ?? 'Tidak tersedia'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getColorFromHex(data['color'] ?? '#4CAF50'),
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Faktor Penilaian:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Nilai: ${data['faktorNilai']}%',
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      '• Trend: ${data['faktorTrend']}%',
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      '• Konsistensi: ${data['faktorKonsistensi']}%',
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      '• Persaingan: ${data['faktorPersaingan']}%',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data['rekomendasi'],
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
