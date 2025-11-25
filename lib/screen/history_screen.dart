import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text('History'),
        centerTitle: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ColorItem(
            color: Color(0xFF789623),
            name: 'Green',
            hex: '#789623',
            source: 'Captured from Camera',
          ),
          SizedBox(height: 16),
          ColorItem(
            color: Color(0xFF789623),
            name: 'Blue',
            hex: '#789623',
            source: 'Uploaded from Gallery',
          ),
          SizedBox(height: 16),
          ColorItem(
            color: Color(0xFF789623),
            name: 'Green',
            hex: '#789623',
            source: 'Captured from Camera',
          ),
        ],
      ),
    );
  }
}

class ColorItem extends StatelessWidget {
  final Color color;
  final String name;
  final String hex;
  final String source;

  const ColorItem({
    super.key,
    required this.color,
    required this.name,
    required this.hex,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.black, // Card background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
           
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name $hex',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white, // Text color
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      source,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400], // Lighter gray for source
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildTag('Hex'),
                _buildTag('Rai'),
                _buildTag('Pastelal'),
              ],
            ),

            const SizedBox(height: 16),

            // View Details button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.grey[850], // Dark background
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[800], // Dark tag background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white, // Tag text color
        ),
      ),
    );
  }
}
