import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';

class ReportingIncidentScreen extends StatefulWidget {
  const ReportingIncidentScreen({super.key});

  @override
  State<ReportingIncidentScreen> createState() =>
      _ReportingIncidentScreenState();
}

class _ReportingIncidentScreenState extends State<ReportingIncidentScreen> {
  final _descController = TextEditingController();
  String _type = 'safety';
  bool _submitting = false;

  // Cloudinary URLs collected from _AttachBox taps (future extension)
  final List<String> _photoUrls = [];
  final List<String> _screenshotUrls = [];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final desc = _descController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the incident first.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final token = UserSession.instance.token ?? '';
      final result = await AuthService.submitIncident(
        token: token,
        description: desc,
        type: _type,
        photoUrls: _photoUrls,
        messageScreenshots: _screenshotUrls,
      );

      if (!mounted) return;
      _descController.clear();

      // Show confirmation dialog with case number
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: const Color(0xFFFFFCF5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF006972),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Report Submitted',
                  style: TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontSize: 24, fontWeight: FontWeight.w700,
                    color: Color(0xFF23130A),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Our team will review your report and respond within 24 hours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 14, color: Color(0xFF4F4540), height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Case #${result['caseNumber']}',
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: Color(0xFF006972), letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
                      Navigator.of(context).pop(); // go back
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006972),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white, fontSize: 16,
                        fontFamily: 'HankenGrotesk', fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF6EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A1B12)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reporting an Incident',
          style: TextStyle(
            color: Color(0xFF23130A),
            fontSize: 28,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Hero image with overlay
            Stack(
              children: [
                Image.asset(
                  'assets/images/safehousing.png',
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0xFF2A1B12).withOpacity(0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'SAFETY FIRST',
                        style: TextStyle(
                          color: Color(0xFF98F0FB),
                          fontSize: 11,
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.54,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your security is our highest priority.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'CormorantGaramond',
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1
                  _StepItem(
                    number: '1',
                    title: 'Ensure safety first',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'If you are in immediate danger, please reach out to local emergency services or authorities right away. Your physical well-being is the most urgent priority before beginning the report process.',
                          style: _bodyStyle,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _TagChip(label: 'LOCAL HELP'),
                            const SizedBox(width: 8),
                            _TagChip(label: 'EMERGENCY'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Step 2
                  _StepItem(
                    number: '2',
                    title: 'Document everything',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Keep a thorough record of the incident. This includes taking clear photos of any physical damage, preserving screenshots of all messages exchanged on the platform, and noting down exact times and dates.',
                          style: _bodyStyle,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _AttachBox(
                                icon: Icons.camera_alt_outlined,
                                label: 'PHOTOS',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AttachBox(
                                icon: Icons.chat_bubble_outline,
                                label: 'MESSAGES',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Step 3
                  _StepItem(
                    number: '3',
                    title: 'Contact AKRILI Support',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Use our dedicated Help Center or click the safety team link to submit your documentation. Our specialized safety officers are trained to handle sensitive incidents with discretion and empathy.',
                          style: _bodyStyle,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            Text(
                              'Visit Help Center',
                              style: TextStyle(
                                color: Color(0xFF006972),
                                fontSize: 13,
                                fontFamily: 'HankenGrotesk',
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF006972),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.open_in_new,
                                color: Color(0xFF006972), size: 14),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Step 4
                  _StepItem(
                    number: '4',
                    title: 'Follow up',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Once submitted, our internal review board will assess the details of your claim. You will receive an initial response and a dedicated case number via email within 24 hours.',
                          style: _bodyStyle,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F4F4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Icon(Icons.info_outline,
                                  color: Color(0xFF006972), size: 16),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Responses may be delayed during peak seasonal travel periods, but every safety concern is prioritized.',
                                  style: TextStyle(
                                    color: Color(0xFF006972),
                                    fontSize: 12,
                                    fontFamily: 'HankenGrotesk',
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            // Description field + Report Now button — scrolls with content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Describe the incident',
                    style: TextStyle(
                      color: Color(0xFF23130A),
                      fontSize: 15,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tell us what happened...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9B8C7E),
                        fontFamily: 'HankenGrotesk',
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFFFCF6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD3C3BD)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD3C3BD)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF006972), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006972),
                        disabledBackgroundColor: const Color(0xFF006972).withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Report Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'HankenGrotesk',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, color: Color(0xFF9B8C7E), size: 12),
                      SizedBox(width: 4),
                      Text(
                        'SECURE ENCRYPTED SUBMISSION',
                        style: TextStyle(
                          color: Color(0xFF81756F),
                          fontSize: 12,
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String title;
  final Widget content;

  const _StepItem({
    required this.number,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number circle
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF6),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEFE6D6), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFF006972),
              fontSize: 20,
              fontFamily: 'HankenGrotesk',
              fontWeight: FontWeight.w700,
              height: 1.5, // 30px / 20px
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF23130A),
                  fontSize: 20,
                  fontFamily: 'HankenGrotesk',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              content,
            ],
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6EF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD3C3BD)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4F4540),
          fontSize: 10,
          fontFamily: 'HankenGrotesk',
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

const TextStyle _bodyStyle = TextStyle(
  color: Color(0xFF4F4540),
  fontSize: 15,
  fontFamily: 'HankenGrotesk',
  fontWeight: FontWeight.w400,
  height: 1.6,
);

class _AttachBox extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AttachBox({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: const Color(0xFFD3C3BD),
          strokeWidth: 1.5,
          gap: 5,
          radius: 12,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF7A6A62), size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7A6A62),
                fontSize: 11,
                fontFamily: 'HankenGrotesk',
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
          size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashPath = Path();
    final metrices = path.computeMetrics();
    for (final metric in metrices) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        const dashLength = 6.0;
        if (draw) {
          dashPath.addPath(
            metric.extractPath(distance, distance + dashLength),
            Offset.zero,
          );
        }
        distance += draw ? dashLength : gap;
        draw = !draw;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => false;
}