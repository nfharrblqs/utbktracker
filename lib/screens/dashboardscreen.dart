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
  Map<String, dynamic>? _userData;

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
    _loadUserData();
    _loadUserPilihan();
    _loadCurrentScore();
    _loadRiwayatTryout();
  }

  Future<void> _loadUserPilihan() async {
    setState(() => _isLoading = true);
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCurrentScore() async {
    try {
      final currentUserId =
          widget.userId ?? AuthService.getCurrentUserId() ?? 1;
      final score = await _dashboardService.getUserCurrentScore(currentUserId);
      setState(() => _currentScore = score);
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
      setState(() => _riwayatTryout = riwayat);
      print('Riwayat tryout loaded: ${riwayat.length} data');
    } catch (e) {
      print('Error loading riwayat tryout: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final currentUserId =
          widget.userId ?? AuthService.getCurrentUserId() ?? 1;
      final userData = await _dashboardService.getUserDataById(currentUserId);
      setState(() {
        _userData = userData;
      });
      print('User data loaded: ${userData?['nama']}');
    } catch (e) {
      print('Error loading user data: $e');
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
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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

  Color _getScoreColor(int score) {
    if (score >= 800) return Colors.green.shade600;
    if (score >= 700) return Colors.blue.shade600;
    if (score >= 600) return Colors.orange.shade600;
    if (score >= 500) return Colors.deepOrange.shade600;
    return Colors.red.shade600;
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
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2B4C7E), Color(0xFF4A7A9E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      child: Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang,',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          AuthService.getCurrentUserName() ?? "User",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _userData?['email'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2B4C7E), Color(0xFF3D6B9E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nilai UTBK',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      _currentScore != null
                                          ? _currentScore.toString()
                                          : '-',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '/ 1000',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value:
                                        _currentScore != null
                                            ? _currentScore! / 1000
                                            : 0,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.3,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _currentScore != null
                                      ? '${((_currentScore! / 1000) * 100).toStringAsFixed(0)}% dari target'
                                      : 'Belum ada data',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF2B4C7E,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.school_outlined,
                                        size: 14,
                                        color: Color(0xFF2B4C7E),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'Pilihan Kampus',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: Color(0xFF2B4C7E),
                                        ),
                                      ),
                                    ),
                                    if (_userPilihan.isNotEmpty)
                                      TextButton.icon(
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
                                          if (result == true)
                                            _loadUserPilihan();
                                        },
                                        icon: const Icon(Icons.edit, size: 12),
                                        label: const Text(
                                          'Edit',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (_isLoading)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  )
                                else if (_userPilihan.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Belum ada pilihan',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ..._userPilihan.take(3).map((pilihan) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 3,
                                            height: 3,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF2B4C7E),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _getDisplayText(pilihan),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
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
                        icon: const Icon(Icons.edit_note, size: 18),
                        label: const Text(
                          'Input Score UTBK',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B4C7E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TryoutChart(riwayatTryout: _riwayatTryout),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2B4C7E,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.history,
                                  size: 18,
                                  color: Color(0xFF2B4C7E),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Riwayat Tryout',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF2B4C7E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_riwayatTryout.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              child: const Center(
                                child: Text(
                                  'Belum ada data tryout',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
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
                                final score =
                                    tryout['total_score'] as int? ?? 0;
                                final isExpanded = _expandedIndex == index;
                                return Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: InkWell(
                                        onTap:
                                            () => setState(
                                              () =>
                                                  _expandedIndex =
                                                      isExpanded ? -1 : index,
                                            ),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${_riwayatTryout.length - index}',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color: Colors.black
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Tryout ke-${_riwayatTryout.length - index}',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 13,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          _formatDate(
                                                            tryout['tanggal_input'] ??
                                                                '',
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      score.toString(),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors.black
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Icon(
                                                    isExpanded
                                                        ? Icons
                                                            .keyboard_arrow_up
                                                        : Icons
                                                            .keyboard_arrow_down,
                                                    size: 18,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                ],
                                              ),
                                              if (!isExpanded) ...[
                                                const SizedBox(height: 10),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: LinearProgressIndicator(
                                                    value: score / 1000,
                                                    backgroundColor:
                                                        Colors.grey.shade200,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(
                                                          _getScoreColor(score),
                                                        ),
                                                    minHeight: 4,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isExpanded)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: _buildDetailRows(tryout),
                                      ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
