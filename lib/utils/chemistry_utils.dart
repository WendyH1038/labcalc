import '../compound_data.dart';

class ChemistryUtils {
  static double calculateMolarMass(String formula) {
    if (formula.isEmpty) return 0.0;

    try {
      List<double> massStack = [0.0];
      int i = 0;

      while (i < formula.length) {
        String char = formula[i];

        if (char == '(') {
          massStack.add(0.0);
          i++;
        } else if (char == ')') {
          i++;
          // Read the multiplier number right after the closing parenthesis
          String multiplierStr = '';
          while (i < formula.length && RegExp(r'\d').hasMatch(formula[i])) {
            multiplierStr += formula[i];
            i++;
          }
          int multiplier = multiplierStr.isEmpty ? 1 : int.parse(multiplierStr);
          if (massStack.length > 1) {
            double poppedMass = massStack.removeLast();
            massStack[massStack.length - 1] += poppedMass * multiplier;
          }
        } else if (RegExp(r'[A-Z]').hasMatch(char)) {
          // Parse Element Name (Capital letter + optional lowercase letter)
          String element = char;
          i++;
          if (i < formula.length && RegExp(r'[a-z]').hasMatch(formula[i])) {
            element += formula[i];
            i++;
          }

          // Parse Element Subscript Number
          String countStr = '';
          while (i < formula.length && RegExp(r'\d').hasMatch(formula[i])) {
            countStr += formula[i];
            i++;
          }
          int count = countStr.isEmpty ? 1 : int.parse(countStr);

          // Look up element mass and add it to the current active layer mass
          if (atomicWeights.containsKey(element)) {
            massStack[massStack.length - 1] += atomicWeights[element]! * count;
          }
        } else {
          i++; // Skip invalid characters
        }
      }

      return massStack.first;
    } catch (e) {
      return 0.0; // Return 0 if the user types malformed chemical brackets
    }
  }
}
