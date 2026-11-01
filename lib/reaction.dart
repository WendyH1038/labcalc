import 'utils/chemistry_utils.dart'; // Add this import!

class StoichResult {
  final double molesA;
  final double molesB;
  final double gramsB;
  final String stepByStep;

  StoichResult({
    required this.molesA,
    required this.molesB,
    required this.gramsB,
    required this.stepByStep,
  });
}

StoichResult calculateStoichiometry({
  required String formulaA,
  required double gramsA,
  required int coeffA,
  required String formulaB,
  required int coeffB,
}) {
  // Step A: Get MR by the stored file
  double mmA = ChemistryUtils.calculateMolarMass(formulaA);
  double mmB = ChemistryUtils.calculateMolarMass(formulaB);

  // Safety check to avoid dividing by zero if formula is empty/invalid
  if (mmA == 0 || mmB == 0) {
    return StoichResult(
      molesA: 0,
      molesB: 0,
      gramsB: 0,
      stepByStep: "Invalid Formula",
    );
  }

  // Step B: Grams A -> Moles A
  double molesA = gramsA / mmA;

  // Step C: Moles A -> Moles B (The Mole Ratio)
  double molesB = molesA * (coeffB / coeffA);

  // Step D: Moles B -> Grams B
  double gramsB = molesB * mmB;

  String work =
      """
1. $gramsA g of $formulaA / ${mmA.toStringAsFixed(3)} g/mol = ${molesA.toStringAsFixed(3)} mol $formulaA
2. Ratio: ${molesA.toStringAsFixed(3)} mol * ($coeffB / $coeffA) = ${molesB.toStringAsFixed(3)} mol $formulaB
3. ${molesB.toStringAsFixed(3)} mol * ${mmB.toStringAsFixed(3)} g/mol = ${gramsB.toStringAsFixed(2)} g $formulaB
""";

  return StoichResult(
    molesA: molesA,
    molesB: molesB,
    gramsB: gramsB,
    stepByStep: work,
  );
}
