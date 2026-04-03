import 'package:flutter/material.dart';

class MathFormula extends StatelessWidget {
  final String latex;
  final double fontSize;
  
  const MathFormula({
    Key? key,
    required this.latex,
    this.fontSize = 16,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    String formula = latex;
    
    // 🔥 Convert LaTeX to readable format
    formula = formula.replaceAll(r'\frac', '');
    formula = formula.replaceAll(r'\sqrt', '√');
    formula = formula.replaceAll(r'\pm', '±');
    formula = formula.replaceAll(r'\(', '');
    formula = formula.replaceAll(r'\)', '');
    formula = formula.replaceAll(r'\[', '');
    formula = formula.replaceAll(r'\]', '');
    formula = formula.replaceAll('{', '(');
    formula = formula.replaceAll('}', ')');
    formula = formula.replaceAll('b^2', 'b²');
    formula = formula.replaceAll('a^2', 'a²');
    formula = formula.replaceAll('c^2', 'c²');
    formula = formula.replaceAll('^2', '²');
    
    // 🔥 Special case for quadratic formula
    if (formula.contains('-b') && formula.contains('4ac')) {
      formula = 'x = [-b ± √(b² - 4ac)] / 2a';
    }
    
    // 🔥 Remove extra spaces
    formula = formula.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        formula,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}