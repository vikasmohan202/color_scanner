import 'package:flutter/material.dart';

class ColorConverterScreen extends StatelessWidget {
  const ColorConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Converter Details'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color information table
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  children: [
                    _buildHeaderCell('Shade Info'),
                    _buildHeaderCell('Density & Intensity'),
                    const TableCell(child: SizedBox.shrink()),
                  ],
                ),
                // Data rows
                _buildDataRow('R: 217', 'C: 10%', 'C: 74%'),
                _buildDataRow('G: 94', 'Y: 74%', 'K: 0%'),
                _buildDataRow('B: 34', '', ''),
              ],
            ),
            const SizedBox(height: 24),
            // AI-generated description
            const Text(
              'AI-Generated Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildBulletPoint(
              'Warm red. A vibrant energetic color, often associated with passion and excitement.',
            ),
            _buildBulletPoint(
              'Commonly used in industries like advertising, sports, and entertainment.',
            ),
          ],
        ),
      ),
    );
  }

  TableCell _buildHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  TableRow _buildDataRow(String shade, String density1, String density2) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
          child: Text(shade),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
          child: Text(density1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
          child: Text(density2),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3.0, right: 8),
            child: Text('•', style: TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
