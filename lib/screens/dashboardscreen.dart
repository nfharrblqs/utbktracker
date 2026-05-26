import 'package:flutter/material.dart';
import 'package:utbktracker/screens/score_screen.dart';
import 'package:utbktracker/services/dashboard_service.dart';
import 'package:utbktracker/widgets/tryout_chart.dart';
import 'statistikscreen.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  final int? userId;

  const DashboardScreen({super.key, this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  List<Map<String, dynamic>> _userPilihan = [];
  List<Map<String, dynamic>> _riwayatTryout = [];
  bool _isLoading = true;
  int? _currentScore;
  int _expandedIndex = -1;

  final List<Map<String, dynamic>> _sesiList = [
    {'field': 'penalaran_umum', 'label': 'Penalaran Umum'},
    {
      'field': 'pengetahuan_pemahaman_umum',
      'label': 'Pengetahuan & Pemahaman Umum',
    },
    {
      'field': 'pemahaman_bacaan_menulis',
      'label': 'Pemahaman Bacaan & Menulis',
    },
    {'field': 'pengetahuan_kuantitatif', 'label': 'Pengetahuan Kuantitatif'},
    {
      'field': 'literasi_bahasa_indonesia',
      'label': 'Literasi Bahasa Indonesia',
    },
    {'field': 'literasi_bahasa_inggris', 'label': 'Literasi Bahasa Inggris'},
    {'field': 'penalaran_matematika', 'label': 'Penalaran Matematika'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserPilihan();
    _loadCurrentScore();
    _loadRiwayatTryout();
  }

  Future<void> _loadUserPilihan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUserId =
          widget.userId ?? AuthService.getCurrentUserId() ?? 1;
      final pilihan = await _dashboardService.getPilihanByUser(currentUserId);

      setState(() {
        _userPilihan = pilihan;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading pilihan: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentScore() async {
    try {
      final currentUserId =
          widget.userId ?? AuthService.getCurrentUserId() ?? 1;
      final score = await _dashboardService.getUserCurrentScore(currentUserId);
      setState(() {
        _currentScore = score;
      });
      print('Current score loaded: $_currentScore');
    } catch (e) {
      print('Error loading current score: $e');
    }
  }

  Future<void> _loadRiwayatTryout() async {
    try {
      final currentUserId =
          widget.userId ?? AuthService.getCurrentUserId() ?? 1;
      final riwayat = await _dashboardService.getUserScoreHistory(
        currentUserId,
      );
      setState(() {
        _riwayatTryout = riwayat;
      });
      print('Riwayat tryout loaded: ${riwayat.length} data');
    } catch (e) {
      print('Error loading riwayat tryout: $e');
    }
  }

  String _getDisplayText(Map<String, dynamic> pilihan) {
    final ptnNama = pilihan['ptn_nama'] ?? '';
    final prodiNama = pilihan['prodi_nama'] ?? '';
    return '$ptnNama ($prodiNama)';
  }

  String _formatDate(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  String _getCategoryName(int score) {
    if (score >= 800) return 'Sangat Baik';
    if (score >= 700) return 'Baik';
    if (score >= 600) return 'Cukup';
    if (score >= 500) return 'Kurang';
    return 'Perlu Perhatian';
  }

  Widget _buildDetailRows(Map<String, dynamic> tryout) {
    List<Widget> rows = [];

    for (var sesi in _sesiList) {
      final value = tryout[sesi['field']] as int? ?? 0;
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sesi['label'] as String,
                style: const TextStyle(fontSize: 11),
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    rows.add(const Divider());
    final totalScore = tryout['total_score'] as int? ?? 0;
    rows.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Score (Rata-rata)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              totalScore.toString(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = widget.userId ?? AuthService.getCurrentUserId() ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF2B4C7E)),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B5F8F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Welcome, ${AuthService.getCurrentUserName() ?? "User"}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9BC8EB),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'H - 100 UTBK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: CircularProgressIndicator(
                                        value:
                                            _currentScore != null
                                                ? _currentScore! / 1000
                                                : 0,
                                        strokeWidth: 10,
                                        backgroundColor: Colors.white30,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Color(0xFF2B4C7E),
                                            ),
                                      ),
                                    ),
                                    Text(
                                      _currentScore != null
                                          ? _currentScore.toString()
                                          : '-',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Nilai Terbaru',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9BC8EB).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pilihan Kampus',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                if (_isLoading)
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                    ),
                                  )
                                else if (_userPilihan.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Belum ada pilihan',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  )
                                else
                                  ..._userPilihan
                                      .map((pilihan) {
                                        return _KampusItem(
                                          _getDisplayText(pilihan),
                                        );
                                      })
                                      .take(3),

                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => StatistikScreen(
                                                userId: currentUserId,
                                              ),
                                        ),
                                      );

                                      if (result == true) {
                                        _loadUserPilihan();
                                      }
                                    },
                                    child: const Text(
                                      'Edit Pilihan',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ScoreScreen(userId: currentUserId),
                            ),
                          );

                          if (result == true) {
                            _loadCurrentScore();
                            _loadUserPilihan();
                            _loadRiwayatTryout();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B4C7E),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_note, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Input Score UTBK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TryoutChart(riwayatTryout: _riwayatTryout),

                    const SizedBox(height: 16),

                    const Row(
                      children: [
                        SizedBox(width: 8),
                        Text(
                          'Detail Riwayat Tryout',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF2B4C7E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_riwayatTryout.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            'Belum ada data tryout',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _riwayatTryout.length,
                        itemBuilder: (context, index) {
                          final tryout = _riwayatTryout[index];
                          final score = tryout['total_score'] as int? ?? 0;
                          final progressValue = score / 1000;
                          final isExpanded = _expandedIndex == index;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ],
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _expandedIndex = isExpanded ? -1 : index;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF2B4C7E,
                                                    ).withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${_riwayatTryout.length - index}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0xFF2B4C7E,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Tryout ke-${_riwayatTryout.length - index}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      _formatDate(
                                                        tryout['tanggal_input'] ??
                                                            '',
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  score.toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  _getCategoryName(score),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Progress',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                Text(
                                                  '${(progressValue * 100).toStringAsFixed(0)}%',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: LinearProgressIndicator(
                                                value: progressValue.clamp(
                                                  0.0,
                                                  1.0,
                                                ),
                                                backgroundColor:
                                                    Colors.grey[200],
                                                valueColor:
                                                    const AlwaysStoppedAnimation<
                                                      Color
                                                    >(Color(0xFF2B4C7E)),
                                                minHeight: 8,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              isExpanded
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isExpanded)
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Detail Nilai Per Sesi',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _buildDetailRows(tryout),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _KampusItem(String nama) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.school, size: 14, color: Colors.blueGrey),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              nama,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
