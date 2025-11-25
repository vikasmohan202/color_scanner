import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Palette Browser',
      theme: ThemeData.dark(),
      home: const BrowsePaletteScreen(),
    );
  }
}

class BrowsePaletteScreen extends StatelessWidget {
  const BrowsePaletteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, List<Color>>> allPalettes = [
      {
        'Red': [Colors.red.shade200, Colors.red.shade900]
      }.entries.first,
      {
        'Pink': [Colors.pink.shade200, Colors.pink.shade700]
      }.entries.first,
      {
        'Purple': [Colors.purple.shade200, Colors.purple.shade900]
      }.entries.first,
      {
        'Deep Purple': [Colors.deepPurple.shade200, Colors.deepPurple.shade900]
      }.entries.first,
      {
        'Indigo': [Colors.indigo.shade200, Colors.indigo.shade900]
      }.entries.first,
      {
        'Blue': [Colors.blue.shade200, Colors.blue.shade900]
      }.entries.first,
      {
        'Light Blue': [Colors.lightBlue.shade200, Colors.lightBlue.shade700]
      }.entries.first,
      {
        'Cyan': [Colors.cyan.shade200, Colors.cyan.shade700]
      }.entries.first,
      {
        'Teal': [Colors.teal.shade200, Colors.teal.shade700]
      }.entries.first,
      {
        'Green': [Colors.green.shade200, Colors.green.shade900]
      }.entries.first,
      {
        'Light Green': [Colors.lightGreen.shade200, Colors.lightGreen.shade700]
      }.entries.first,
      {
        'Lime': [Colors.lime.shade200, Colors.lime.shade700]
      }.entries.first,
      {
        'Yellow': [Colors.yellow.shade200, Colors.yellow.shade700]
      }.entries.first,
      {
        'Amber': [Colors.amber.shade200, Colors.amber.shade700]
      }.entries.first,
      {
        'Orange': [Colors.orange.shade200, Colors.orange.shade900]
      }.entries.first,
      {
        'Deep Orange': [Colors.deepOrange.shade200, Colors.deepOrange.shade900]
      }.entries.first,
      {
        'Brown': [Colors.brown.shade300, Colors.brown.shade800]
      }.entries.first,
      {
        'Grey': [Colors.grey.shade400, Colors.grey.shade800]
      }.entries.first,
      {
        'Blue Grey': [Colors.blueGrey.shade300, Colors.blueGrey.shade800]
      }.entries.first,
    ];

    final List<IconData> icons = [
      Icons.palette,
      Icons.brush,
      Icons.format_paint,
      Icons.color_lens,
      Icons.invert_colors,
      Icons.opacity,
      Icons.water,
      Icons.auto_awesome,
      Icons.blur_on,
      Icons.gradient,
      Icons.lens,
      Icons.star
    ];

    final List<ColorCardData> colorCards = List.generate(
      allPalettes.length,
      (index) => ColorCardData(
        icon: icons[index % icons.length],
        label: allPalettes[index].key,
        gradient: allPalettes[index].value,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Browse Palette',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // const Spacer(),
                  // const Icon(Icons.search, color: Colors.white),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  itemCount: colorCards.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemBuilder: (context, index) {
                    final card = colorCards[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PaletteDetailScreen(data: card),
                          ),
                        );
                      },
                      child: ColorCard(data: card),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorCardData {
  final IconData icon;
  final String label;
  final List<Color> gradient;

  ColorCardData({
    required this.icon,
    required this.label,
    required this.gradient,
  });
}

class ColorCard extends StatelessWidget {
  final ColorCardData data;

  const ColorCard({super.key, required this.data});

  String _toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: data.gradient),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: Colors.white, size: 28),
          const Spacer(),
          Text(
            data.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            _toHex(data.gradient[0]),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class PaletteDetailScreen extends StatelessWidget {
  final ColorCardData data;

  const PaletteDetailScreen({super.key, required this.data});

  String _toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          data.label,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [],
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: data.gradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: data.gradient.map((color) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _toHex(color),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'PALETTE INFORMATION',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...data.gradient.map((color) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            _toHex(color),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 30),
                  const Text(
                    'COLOR VALUES',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...data.gradient.map((color) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RGB: ${color.red}, ${color.green}, ${color.blue}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'HEX: ${_toHex(color)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
