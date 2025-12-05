import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_dustbin/Screens/login_screen.dart';
import 'package:smart_dustbin/services/firestore.dart';
// import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService firestoreService = FirestoreService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    // Start pulsing animation for alert banner
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getColorForLevel(double percentage) {
    // CRITICAL is >= 85%
    if (percentage >= 0.85) {
      return const Color(0xFFE53935); // Red - CRITICAL
    }
    // HIGH is >= 60%
    else if (percentage >= 0.60) {
      return const Color(0xFFFF9800); // Orange - HIGH
    }
    // MODERATE is >= 30%
    else if (percentage >= 0.30) {
      return const Color(0xFF4CAF50); // Green - MODERATE
    }
    // LOW is < 30%
    else {
      return const Color(0xFF2E7D32); // Dark Green - LOW
    }
  }

  String _getStatusText(double percentage) {
    if (percentage >= 0.85) {
      return 'CRITICAL';
    } else if (percentage >= 0.60) {
      return 'HIGH';
    } else if (percentage >= 0.30) {
      return 'MODERATE';
    } else {
      return 'LOW';
    }
  }

  Widget _buildDustbinVisualizer(double percentage, Color color) {
    const double maxFillHeight = 240.0;
    final fillHeight = maxFillHeight * percentage;
    // Use the rounded percentage value for display
    final statusText = (percentage * 100).toStringAsFixed(0);

    return Container(
      width: 200,
      height: 320,
      // Use a more distinct background color and rounded shape
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          // Inner shadow for depth effect
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            offset: const Offset(-5, -5),
            blurRadius: 10,
          ),
          // Outer shadow for lift effect
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(5, 5),
            blurRadius: 15,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background fill animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            height: fillHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: const Radius.circular(28),
                top: percentage >= 0.95
                    ? const Radius.circular(28)
                    : Radius.zero,
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                // Add a slightly darker color at the bottom for realism
                colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
              ),
            ),
          ),

          // Outer Rim (The border is now internal and looks like an opening)
          Container(
            width: 200,
            height: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
          ),

          // Central Status Text
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$statusText%',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    // Dynamic text color for visibility
                    color: percentage > 0.45 ? Colors.white : Colors.black87,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black.withOpacity(
                          percentage > 0.45 ? 0.3 : 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(percentage),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    // Dynamic text color for visibility
                    color: percentage > 0.45
                        ? Colors.white70
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFC62828), const Color(0xFFE53935)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53935).withOpacity(0.6),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IMMEDIATE ACTION REQUIRED',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dustbin is almost full. Schedule immediate collection.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusContent(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final levelValue = data['level'];
    double fillPercentage;

    if (levelValue is num) {
      fillPercentage = levelValue.toDouble();
      fillPercentage /= 100.0;
    } else if (levelValue is String) {
      fillPercentage = double.tryParse(levelValue) ?? 0.0;
      fillPercentage /= 100.0;
    } else {
      fillPercentage = 0.0;
    }

    // Ensure the percentage is between 0.0 and 1.0
    fillPercentage = fillPercentage.clamp(0.0, 1.0);

    // 🌟 FIX APPLIED HERE 🌟
    // Round the percentage to handle potential floating-point errors
    // when comparing exact values like 0.85 (85%).
    final roundedFillPercentage =
        (fillPercentage * 100).roundToDouble() / 100.0;

    // final Timestamp? timestamp = data['createdAt'];
    // final lastUpdateTime = timestamp?.toDate() ?? DateTime.now();

    final levelColor = _getColorForLevel(roundedFillPercentage);
    // Use the rounded percentage for the critical check
    final isCritical = roundedFillPercentage >= 0.85;

    // final formattedTime = DateFormat('HH:mm a').format(lastUpdateTime);
    // final formattedDate = DateFormat('MMM dd, yyyy').format(lastUpdateTime);

    return LayoutBuilder(
      builder: (context, constraints) {
        // final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              elevation: 6,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    'Smart Dustbin Status',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black38,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  centerTitle: false,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Logout',
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (isCritical) _buildAlertBanner(),

                  // Location and ID Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['location'] ?? 'Location N/A',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: levelColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: levelColor, width: 1),
                              ),
                              child: Text(
                                // Use the rounded percentage for display
                                _getStatusText(roundedFillPercentage),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: levelColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.pin_drop_rounded,
                              color: Colors.grey.shade500,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ID: ${doc.id.substring(0, doc.id.length > 8 ? 8 : doc.id.length)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 36),

                        // Dustbin Visualizer Section
                        Center(
                          child: _buildDustbinVisualizer(
                            roundedFillPercentage,
                            levelColor,
                          ),
                        ),

                        const SizedBox(height: 36),

                        const SizedBox(height: 24),

                        // Sensor Info (Data Source)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.cloud_done_rounded,
                                color: Colors.blue.shade800,
                                size: 12,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DATA STATUS',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  Text(
                                    'Pre-calculated Level from DB (Live)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getDustbinStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue.shade600),
                  const SizedBox(height: 16),
                  Text(
                    'Loading dustbin status...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red.shade600,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Connection Error',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your internet connection and try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    color: Colors.grey.shade400,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Data Available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waiting for data from the database...',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          final latestDocument = snapshot.data!.docs.first;
          return _buildStatusContent(latestDocument);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
