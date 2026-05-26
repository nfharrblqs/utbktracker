import 'package:flutter/material.dart';
import 'package:utbktracker/screens/score_screen.dart';
import 'package:utbktracker/services/dashboard_service.dart';
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
  bool _isLoading = true;
  int _currentScore = 0;

  @override
  void initState() {
    super.initState();
    _loadUserPilihan();
    _loadCurrentScore();
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

  String _getDisplayText(Map<String, dynamic> pilihan) {
    final ptnNama = pilihan['ptn_nama'] ?? '';
    final prodiNama = pilihan['prodi_nama'] ?? '';
    return '$ptnNama ($prodiNama)';
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
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF3B5F8F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Welcome User #$currentUserId',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
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
                                value: 0.6,
                                strokeWidth: 10,
                                backgroundColor: Colors.white30,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue[900]!,
                                ),
                              ),
                            ),
                            Text(
                              _currentScore.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Rata-rata Tryout',
                          style: TextStyle(fontSize: 11, color: Colors.white),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
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
                                return _KampusItem(_getDisplayText(pilihan));
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
                      builder: (context) => ScoreScreen(userId: currentUserId),
                    ),
                  );

                  if (result == true) {
                    _loadCurrentScore();
                    _loadUserPilihan();
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
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9BC8EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 6,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
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
            ),
          ),
        ],
      ),
    );
  }
}
