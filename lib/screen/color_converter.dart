import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ColorConverterScreen(),
  ));
}

class ColorConverterScreen extends StatelessWidget {
  const ColorConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const SizedBox(height: 20),
            const _ColorInputSection(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                ),
                child: const Text("Convert", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            const _ShadeInfoSection(),
            const SizedBox(height: 20),
            const _AIDescription(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 12),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        const Text(
          "Color Converter",
          style: TextStyle(
            color: Color(0xFF6C63FF),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _ColorInputSection extends StatelessWidget {
  const _ColorInputSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Enter Color",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Dropdown(type: "HEX"),
              const SizedBox(width: 12),
              Expanded(
                child: _InputBox(value: "#3C3C3C"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF6C63FF),
            child: Icon(Icons.sync_alt, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Converted to ?",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Dropdown(type: "RGB"),
              const SizedBox(width: 12),
              Expanded(
                child: _InputBox(value: "60 60 60 100%"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String type;

  const _Dropdown({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: type,
        underline: const SizedBox(),
        items: [type].map((e) {
          return DropdownMenuItem<String>(
            value: e,
            child: Text(e),
          );
        }).toList(),
        onChanged: (_) {},
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final String value;

  const _InputBox({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(value),
    );
  }
}

class _ShadeInfoSection extends StatelessWidget {
  const _ShadeInfoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Shade Info", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text("R: 60\nG: 60\nB: 60", style: TextStyle(color: Colors.white)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Density & Intensity", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text("C: 10%\nY: 74%\nC: 74%\nK: 0%", style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AIDescription extends StatelessWidget {
  const _AIDescription();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AI-Generated Description",
            style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text("• Warm red. A vibrant energetic color, often associated with passion and excitement.",
              style: TextStyle(color: Colors.white)),
          SizedBox(height: 6),
          Text("• Commonly used in industries like advertising, sports, and entertainment.",
              style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
