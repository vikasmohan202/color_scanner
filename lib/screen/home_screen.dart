import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class ColorScannerHomeScreen extends StatefulWidget {
  const ColorScannerHomeScreen({super.key});

  @override
  State<ColorScannerHomeScreen> createState() => _ColorScannerHomeScreenState();
}

class _ColorScannerHomeScreenState extends State<ColorScannerHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _inputController = TextEditingController();
  String _inputFormat = 'HEX';
  String _outputFormat = 'RGB';
  String _outputValue = '60 60 60 100%';
  bool _showDetails = false;
  Color? _convertedColor;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  // Track input color for real-time preview
  Color? _inputColor;

  final List<Color> _gradientColors = [
    const Color(0xFFFF6B6B),
    const Color(0xFFFFE66D),
    const Color(0xFF4ECDC4),
    const Color(0xFF6A60FF),
    const Color(0xFFFF6B6B),
  ];

  @override
  void initState() {
    super.initState();
    _inputController.text = '#3C3C3C';
    _updateInputColor(_inputController.text);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: const Color(0xFF6A60FF),
      end: const Color(0xFF4ECDC4),
    ).animate(_animationController);

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateInputColor(String value) {
    try {
      if (_inputFormat == 'HEX') {
        _inputColor = _hexToColor(value);
      } else if (_inputFormat == 'RGB') {
        _inputColor = _rgbStringToColor(value);
      }
    } catch (e) {
      _inputColor = null;
    }
    setState(() {});
  }

  void _performConversion() {
    final input = _inputController.text.trim();
    String result = '';

    if (_inputFormat == 'HEX' && _outputFormat == 'RGB') {
      result = _hexToRgb(input);
    } else if (_inputFormat == 'RGB' && _outputFormat == 'HEX') {
      result = _rgbToHex(input);
    } else {
      result = input;
    }

    setState(() {
      _outputValue = result;
      _convertedColor = _parseColor(result);
      _showDetails = true;
    });
  }

  Color? _parseColor(String value) {
    try {
      if (_outputFormat == 'HEX') {
        return _hexToColor(value);
      } else {
        return _rgbStringToColor(value);
      }
    } catch (e) {
      return null;
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    throw FormatException('Invalid HEX color');
  }

  Color _rgbStringToColor(String rgb) {
    final parts =
        rgb.split(RegExp(r'[\s,]+')).where((s) => s.isNotEmpty).toList();
    if (parts.length >= 3) {
      final r = int.parse(parts[0]);
      final g = int.parse(parts[1]);
      final b = int.parse(parts[2]);
      return Color.fromRGBO(r, g, b, 1);
    }
    throw FormatException('Invalid RGB color');
  }

  String _hexToRgb(String hex) {
    hex = hex.replaceAll('#', '');

    if (hex.length == 3) {
      hex = hex.split('').map((c) => c + c).join();
    }

    if (hex.length != 6) {
      return 'Invalid HEX format';
    }

    try {
      final r = int.parse(hex.substring(0, 2), radix: 16);
      final g = int.parse(hex.substring(2, 4), radix: 16);
      final b = int.parse(hex.substring(4, 6), radix: 16);
      return '$r $g $b 100%';
    } catch (e) {
      return 'Invalid HEX format';
    }
  }

  String _rgbToHex(String rgb) {
    final parts =
        rgb.split(RegExp(r'[\s,]+')).where((s) => s.isNotEmpty).toList();

    if (parts.length < 3) {
      return 'Invalid RGB format';
    }

    try {
      final r = int.parse(parts[0]).clamp(0, 255);
      final g = int.parse(parts[1]).clamp(0, 255);
      final b = int.parse(parts[2]).clamp(0, 255);

      return '#${r.toRadixString(16).padLeft(2, '0')}'
              '${g.toRadixString(16).padLeft(2, '0')}'
              '${b.toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
    } catch (e) {
      return 'Invalid RGB format';
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _outputValue));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard!'),
        backgroundColor: _convertedColor ?? const Color(0xFF6A60FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _swapFormats() {
    setState(() {
      final temp = _inputFormat;
      _inputFormat = _outputFormat;
      _outputFormat = temp;

      final tempValue = _inputController.text;
      _inputController.text = _outputValue;
      _outputValue = tempValue;

      // Update input color preview after swap
      _updateInputColor(_inputController.text);
      _showDetails = false;
    });
  }

  String _getInputHint() {
    switch (_inputFormat) {
      case 'HEX':
        return 'Enter HEX (e.g., #3C3C3C or 3C3C3C)';
      case 'RGB':
        return 'Enter RGB (e.g., 60 60 60 or 60,60,60)';
      default:
        return 'Enter color value';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.grey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Animated gradient header
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  gradient: SweepGradient(
                    colors: _gradientColors,
                    center: FractionalOffset.center,
                    startAngle: 0.0,
                    endAngle: pi * 2,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Color Scanner",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.8,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black26,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _colorAnimation,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.palette,
                                  color: _colorAnimation.value, size: 26),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Convert colors between formats",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Converter box with depth
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueGrey.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 10),
                                )
                              ],
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.grey.shade100],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Input section with clear label
                                _buildInputSection(),
                                const SizedBox(height: 24),

                                // Swap button
                                AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _animationController.value * pi,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF6A60FF)
                                                  .withOpacity(0.3),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                            )
                                          ],
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF6A60FF),
                                              const Color(0xFF4ECDC4),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 26,
                                          backgroundColor: Colors.transparent,
                                          child: IconButton(
                                            icon: const Icon(Icons.swap_vert,
                                                color: Colors.white, size: 28),
                                            onPressed: _swapFormats,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Output section with clear label
                                _buildOutputSection(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 25),

                    // Convert button
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6A60FF),
                              const Color(0xFF4ECDC4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5B50FF).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _performConversion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Convert Color',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Color details card
                    if (_showDetails && _convertedColor != null)
                      _buildColorDetailsCard(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input label with format
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 4),
          child: Row(
            children: [
              Text(
                "INPUT",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A60FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _inputFormat,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6A60FF),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Input field with color preview
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _inputColor != null
                  ? const Color(0xFF6A60FF).withOpacity(0.3)
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Color preview
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _inputColor ?? Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: _inputColor == null
                    ? Icon(Icons.color_lens, color: Colors.grey.shade500)
                    : null,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: _getInputHint(),
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: _updateInputColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getInputHint(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Output label with format
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 4),
          child: Row(
            children: [
              Text(
                "OUTPUT",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _outputFormat,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4ECDC4),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Output field with color preview and copy button
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _convertedColor != null
                  ? const Color(0xFF4ECDC4).withOpacity(0.3)
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Color preview
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _convertedColor ?? Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: _convertedColor == null
                    ? Icon(Icons.color_lens, color: Colors.grey.shade500)
                    : null,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _outputValue,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Converted ${_outputFormat} value",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Copy button
              if (_convertedColor != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          const Icon(Icons.copy, color: Colors.white, size: 20),
                    ),
                    onPressed: _copyToClipboard,
                    tooltip: 'Copy to clipboard',
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorDetailsCard(BuildContext context) {
    final textColor =
        _convertedColor!.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Color Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy, size: 24, color: _convertedColor),
                onPressed: _copyToClipboard,
                tooltip: 'Copy to clipboard',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Color preview with shadow
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _convertedColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _convertedColor!.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Center(
              child: Text(
                _outputValue,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.3),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Color info grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildInfoTile("Format", _outputFormat, Icons.format_paint),
              _buildInfoTile("Value", _outputValue, Icons.text_fields),
              _buildInfoTile(
                  "Red", _convertedColor!.red.toString(), Icons.circle,
                  color: Colors.red),
              _buildInfoTile(
                  "Green", _convertedColor!.green.toString(), Icons.circle,
                  color: Colors.green),
              _buildInfoTile(
                  "Blue", _convertedColor!.blue.toString(), Icons.circle,
                  color: Colors.blue),
              _buildInfoTile(
                  "Alpha", "${_convertedColor!.alpha ~/ 2.55}%", Icons.opacity),
            ],
          ),
          const SizedBox(height: 25),

          // Tags section
          const Text(
            "COLOR TAGS",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6A60FF),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildColorTag("Primary", _convertedColor!),
              _buildColorTag("Accent", _convertedColor!.withRed(200)),
              _buildColorTag("Background", _convertedColor!.withGreen(200)),
              _buildColorTag("Surface", _convertedColor!.withBlue(200)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon,
      {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? const Color(0xFF6A60FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTag(String label, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: backgroundColor.computeLuminance() > 0.5
              ? Colors.black
              : Colors.white,
          fontWeight: FontWeight.w600,
          shadows: backgroundColor.computeLuminance() > 0.5
              ? []
              : [const Shadow(blurRadius: 4, color: Colors.black45)],
        ),
      ),
    );
  }
}
