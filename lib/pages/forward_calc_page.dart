import 'package:flutter/material.dart';
import '../utils/chemistry_utils.dart';
import '../utils/history_manager.dart';
import '../utils/color_design.dart';

// Smart Auto-Capitalizer
String smartCapitalize(String input) {
  if (input.isEmpty) return input;
  if (input.contains(RegExp(r'[A-Z]'))) {
    return input;
  }
  const commonTwoLetterElements = {
    'he',
    'li',
    'be',
    'ne',
    'na',
    'mg',
    'al',
    'si',
    'cl',
    'ar',
    'ca',
    'ti',
    'cr',
    'mn',
    'fe',
    'ni',
    'cu',
    'zn',
    'as',
    'br',
    'kr',
    'sr',
    'ag',
    'cd',
    'sn',
    'ba',
    'pt',
    'au',
    'hg',
    'pb',
  };
  String lower = input.toLowerCase().replaceAll(' ', '');
  StringBuffer fixed = StringBuffer();
  int i = 0;
  while (i < lower.length) {
    String char = lower[i];
    if (RegExp(r'[0-9()\[\]]').hasMatch(char)) {
      fixed.write(char);
      i++;
      continue;
    }
    if (RegExp(r'[a-z]').hasMatch(char)) {
      if (char == 'c' && i + 1 < lower.length && lower[i + 1] == 'o') {
        if (i + 2 < lower.length && RegExp(r'[a-z]').hasMatch(lower[i + 2])) {
          fixed.write('Co');
        } else {
          fixed.write('CO');
        }
        i += 2;
        continue;
      }
      if (i + 1 < lower.length && RegExp(r'[a-z]').hasMatch(lower[i + 1])) {
        String testPair = char + lower[i + 1];
        if (commonTwoLetterElements.contains(testPair)) {
          fixed.write(testPair[0].toUpperCase() + testPair[1]);
          i += 2;
          continue;
        }
      }
      fixed.write(char.toUpperCase());
      i++;
    } else {
      fixed.write(char);
      i++;
    }
  }
  return fixed.toString();
}

// Validates tokens against actual Periodic Table
bool isValidChemicalFormula(String formula) {
  if (formula.isEmpty) return false;
  const realElements = {
    'H',
    'He',
    'Li',
    'Be',
    'B',
    'C',
    'N',
    'O',
    'F',
    'Ne',
    'Na',
    'Mg',
    'Al',
    'Si',
    'P',
    'S',
    'Cl',
    'Ar',
    'K',
    'Ca',
    'Sc',
    'Ti',
    'V',
    'Cr',
    'Mn',
    'Fe',
    'Co',
    'Ni',
    'Cu',
    'Zn',
    'Ga',
    'Ge',
    'As',
    'Se',
    'Br',
    'Kr',
    'Rb',
    'Sr',
    'Y',
    'Zr',
    'Nb',
    'Mo',
    'Tc',
    'Ru',
    'Rh',
    'Pd',
    'Ag',
    'Cd',
    'In',
    'Sn',
    'Sb',
    'Te',
    'I',
    'Xe',
    'Cs',
    'Ba',
    'La',
    'Ce',
    'Pr',
    'Nd',
    'Pm',
    'Sm',
    'Eu',
    'Gd',
    'Tb',
    'Dy',
    'Ho',
    'Er',
    'Tm',
    'Yb',
    'Lu',
    'Hf',
    'Ta',
    'W',
    'Re',
    'Os',
    'Ir',
    'Pt',
    'Au',
    'Hg',
    'Tl',
    'Pb',
    'Bi',
    'Po',
    'At',
    'Rn',
    'Fr',
    'Ra',
    'Ac',
    'Th',
    'Pa',
    'U',
    'Np',
    'Pu',
    'Am',
    'Cm',
    'Bk',
    'Cf',
    'Es',
    'Fm',
    'Md',
    'No',
    'Lr',
    'Rf',
    'Db',
    'Sg',
    'Bh',
    'Hs',
    'Mt',
    'Ds',
    'Rg',
    'Cn',
    'Nh',
    'Fl',
    'Mc',
    'Lv',
    'Ts',
    'Og',
  };
  final tokenRegex = RegExp(r'([A-Z][a-z]?|[0-9]+|[()\[\]])');
  int totalValidLength = 0;
  for (final match in tokenRegex.allMatches(formula)) {
    final token = match.group(0)!;
    if (RegExp(r'^[A-Za-z]+$').hasMatch(token)) {
      if (!realElements.contains(token)) {
        return false;
      }
    }
    totalValidLength += token.length;
  }
  return totalValidLength == formula.length;
}

// Global Unicode Subscript Formatter Utility
String formatChemicalFormula(String input) {
  final Map<String, String> subscripts = {
    '0': '₀',
    '1': '₁',
    '2': '₂',
    '3': '₃',
    '4': '₄',
    '5': '₅',
    '6': '₆',
    '7': '₇',
    '8': '₈',
    '9': '₉',
  };
  return input.split('').map((char) => subscripts[char] ?? char).join('');
}

// ==========================================
// PAGE 1: MOLAR MASS CALCULATOR PAGE
// ==========================================
class MolarMassPage extends StatefulWidget {
  const MolarMassPage({super.key});
  @override
  State<MolarMassPage> createState() => _MolarMassPageState();
}

class _MolarMassPageState extends State<MolarMassPage> {
  final TextEditingController _autocompleteController = TextEditingController();
  double _calculatedMass = 0.0;

  // NOTE: If "compounds" and "molarMasses" are defined in another file, make sure to import it!
  // If they were global variables in your old main.dart, paste them at the bottom of this file.
  static const List<String> compounds = [
    'H2O',
    'CO2',
    'NaCl',
    'HCl',
    'H2SO4',
    'NaOH',
  ];
  static const Map<String, double> molarMasses = {
    'H2O': 18.015,
    'CO2': 44.009,
    'NaCl': 58.44,
    'HCl': 36.46,
    'H2SO4': 98.079,
    'NaOH': 39.997,
  };

  void _clearAll() {
    setState(() {
      _autocompleteController.clear();
      _calculatedMass = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    String typedText = _autocompleteController.text.trim();
    bool isInvalid = _calculatedMass == 0.0 && typedText.isNotEmpty;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Compound (Case-Insensitive)",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') return compounds;
                      return compounds.where(
                        (compound) => compound.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                    },
                    onSelected: (String selection) {
                      setState(() {
                        _autocompleteController.text = selection;
                        String processed = smartCapitalize(selection);
                        if (isValidChemicalFormula(processed)) {
                          _calculatedMass =
                              molarMasses[selection] ??
                              ChemistryUtils.calculateMolarMass(processed);
                        } else {
                          _calculatedMass = 0.0;
                        }
                      });
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                          if (_autocompleteController.text != controller.text &&
                              _autocompleteController.text.isEmpty) {
                            controller.text = _autocompleteController.text;
                          }
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onEditingComplete: onEditingComplete,
                            onChanged: (value) {
                              _autocompleteController.text = value;
                              setState(() {
                                String processed = smartCapitalize(value);
                                if (isValidChemicalFormula(processed)) {
                                  _calculatedMass =
                                      ChemistryUtils.calculateMolarMass(
                                        processed,
                                      );
                                } else {
                                  _calculatedMass = 0.0;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'e.g., HCl, H2O, Ca(OH)2...',
                              prefixIcon: const Icon(Icons.science),
                              border: const OutlineInputBorder(),
                              enabledBorder: isInvalid
                                  ? const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.redAccent,
                                        width: 2,
                                      ),
                                    )
                                  : null,
                              focusedBorder: isInvalid
                                  ? const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.redAccent,
                                        width: 2,
                                      ),
                                    )
                                  : null,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          );
                        },
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.redAccent),
                  onPressed: _clearAll,
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              "Calculated Molar Mass:",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isInvalid
                      ? Colors.redAccent.withValues(alpha: 0.5)
                      : (_calculatedMass > 0
                            ? Colors.greenAccent.withValues(alpha: 0.5)
                            : Colors.grey.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isInvalid
                        ? "Unknown Formula"
                        : _calculatedMass.toStringAsFixed(3),
                    style: TextStyle(
                      color: isInvalid ? Colors.redAccent : Colors.greenAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isInvalid ? "⚠️ Check Input" : 'g/mol',
                    style: TextStyle(
                      color: isInvalid ? Colors.redAccent : Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PAGE 2: ADAPTIVE REACTION MATRIX PAGE
// ==========================================
class ReactionPage extends StatefulWidget {
  const ReactionPage({super.key});
  @override
  State<ReactionPage> createState() => _ReactionPageState();
}

class _ReactionPageState extends State<ReactionPage> {
  final _coeffAController = TextEditingController();
  final _formulaAController = TextEditingController();
  final _coeffBController = TextEditingController();
  final _formulaBController = TextEditingController();
  final _coeffCController = TextEditingController();
  final _formulaCController = TextEditingController();
  final _coeffDController = TextEditingController();
  final _formulaDController = TextEditingController();
  final _gramsAController = TextEditingController();
  final _gramsBController = TextEditingController();
  String _limitingReactantResult = 'Single Target Mode';
  String _theoreticalYieldResult = '0.00';
  String _workLog = 'Populate system rows and execute computation.';
  bool _hasError = false;

  void _calculateReaction() async {
    setState(() {
      _hasError = false;
      String fA = smartCapitalize(_formulaAController.text.trim());
      String fB = smartCapitalize(_formulaBController.text.trim());
      String fC = smartCapitalize(_formulaCController.text.trim());
      String fD = smartCapitalize(_formulaDController.text.trim());
      int cA = int.tryParse(_coeffAController.text) ?? 0;
      int cC = int.tryParse(_coeffCController.text) ?? 0;
      double gA = double.tryParse(_gramsAController.text) ?? -1.0;
      bool isSingleMode =
          fB.isEmpty ||
          _gramsBController.text.trim().isEmpty ||
          _coeffBController.text.trim().isEmpty;
      bool hasProductD =
          fD.isNotEmpty && _coeffDController.text.trim().isNotEmpty;
      int cD = 0;
      double mmD = 0.0;

      if (hasProductD) {
        cD = int.tryParse(_coeffDController.text) ?? 0;
        if (cD <= 0) {
          _hasError = true;
          _workLog =
              "⚠️ Operational Error:\nProduct D coefficient must be a positive integer.";
          return;
        }
        if (!isValidChemicalFormula(fD)) {
          _hasError = true;
          _workLog =
              "⚠️ Parsing Error:\nProduct D contains unrecognized or invalid element symbols.";
          return;
        }
        mmD = ChemistryUtils.calculateMolarMass(fD);
        if (mmD == 0.0) {
          _hasError = true;
          _workLog =
              "⚠️ Parsing Error:\nProduct D formula could not be mapped to valid periodic properties.";
          return;
        }
      }
      if (cA <= 0 || cC <= 0 || gA < 0 || fA.isEmpty || fC.isEmpty) {
        _hasError = true;
        _workLog =
            "⚠️ Operational Error:\nCoefficients and active reactant mass figures must be valid positive values.";
        return;
      }
      if (!isValidChemicalFormula(fA) ||
          !isValidChemicalFormula(fC) ||
          (!isSingleMode && !isValidChemicalFormula(fB))) {
        _hasError = true;
        _workLog =
            "⚠️ Parsing Error:\nOne or more compound entries contain completely unrecognized or invalid element symbols.";
        return;
      }
      double mmA = ChemistryUtils.calculateMolarMass(fA);
      double mmC = ChemistryUtils.calculateMolarMass(fC);
      if (mmA == 0.0 || mmC == 0.0) {
        _hasError = true;
        _workLog =
            "⚠️ Parsing Error:\nFormulas could not be mapped to valid periodic properties.";
        return;
      }

      if (isSingleMode) {
        double molesA = gA / mmA;
        double yieldMassC = molesA * (cC / cA) * mmC;
        _limitingReactantResult = "N/A (Single Mode)";
        if (hasProductD) {
          double yieldMassD = molesA * (cD / cA) * mmD;
          _theoreticalYieldResult =
              "${yieldMassC.toStringAsFixed(2)} g of ${formatChemicalFormula(fC)}\n+ ${yieldMassD.toStringAsFixed(2)} g of ${formatChemicalFormula(fD)}";
          _workLog =
              "[SINGLE REACTANT PATHWAY SYSTEM]\n"
              "• $gA g ${formatChemicalFormula(fA)} / ${mmA.toStringAsFixed(3)} g/mol = ${molesA.toStringAsFixed(3)} mol ${formatChemicalFormula(fA)}\n"
              "• Yield of ${formatChemicalFormula(fC)}: ${molesA.toStringAsFixed(3)} mol × ($cC/$cA Ratio) × ${mmC.toStringAsFixed(3)} g/mol = ${yieldMassC.toStringAsFixed(2)} g\n"
              "• Yield of ${formatChemicalFormula(fD)}: ${molesA.toStringAsFixed(3)} mol × ($cD/$cA Ratio) × ${mmD.toStringAsFixed(3)} g/mol = ${yieldMassD.toStringAsFixed(2)} g\n\n"
              "Theoretical Yield Outcome = ${yieldMassC.toStringAsFixed(2)} g ${formatChemicalFormula(fC)} + ${yieldMassD.toStringAsFixed(2)} g ${formatChemicalFormula(fD)}";
        } else {
          _theoreticalYieldResult =
              "${yieldMassC.toStringAsFixed(2)} g of ${formatChemicalFormula(fC)}";
          _workLog =
              "[SINGLE REACTANT PATHWAY SYSTEM]\n"
              "• $gA g ${formatChemicalFormula(fA)} / ${mmA.toStringAsFixed(3)} g/mol = ${molesA.toStringAsFixed(3)} mol ${formatChemicalFormula(fA)}\n"
              "• ${molesA.toStringAsFixed(3)} mol ${formatChemicalFormula(fA)} × ($cC mol / $cA mol Ratio) × ${mmC.toStringAsFixed(3)} g/mol\n\n"
              "Theoretical Yield Outcome = $_theoreticalYieldResult";
        }
      } else {
        int cB = int.tryParse(_coeffBController.text) ?? 0;
        double gB = double.tryParse(_gramsBController.text) ?? -1.0;
        double mmB = ChemistryUtils.calculateMolarMass(fB);
        if (cB <= 0 || gB < 0 || mmB == 0.0) {
          _hasError = true;
          _workLog =
              "⚠️ Matrix Failure:\nReactant B contains corrupted parameters or unmapped compound configurations.";
          return;
        }
        double molesA = gA / mmA;
        double molesB = gB / mmB;
        double ratioA = molesA / cA;
        double ratioB = molesB / cB;
        String bottleneckFormula;
        double limitMoles;
        int limitCoeff;
        bool isPerfectRatio = (ratioA - ratioB).abs() < 1e-5;
        if (isPerfectRatio) {
          _limitingReactantResult = "None (Perfect Stoichiometric Mixture)";
          bottleneckFormula = "None";
          limitMoles = molesA;
          limitCoeff = cA;
        } else if (ratioA < ratioB) {
          _limitingReactantResult =
              "${formatChemicalFormula(fA)} (Runs out first)";
          bottleneckFormula = fA;
          limitMoles = molesA;
          limitCoeff = cA;
        } else {
          _limitingReactantResult =
              "${formatChemicalFormula(fB)} (Runs out first)";
          bottleneckFormula = fB;
          limitMoles = molesB;
          limitCoeff = cB;
        }
        double finalYieldC = limitMoles * (cC / limitCoeff) * mmC;
        if (hasProductD) {
          double finalYieldD = limitMoles * (cD / limitCoeff) * mmD;
          _theoreticalYieldResult =
              "${finalYieldC.toStringAsFixed(2)} g of ${formatChemicalFormula(fC)}\n+ ${finalYieldD.toStringAsFixed(2)} g of ${formatChemicalFormula(fD)}";
          _workLog =
              "[DUAL ENGINE BOTTLE-NECK ANALYSIS]\n• Reactant A ($fA):\n  - Moles available: ${molesA.toStringAsFixed(3)} mol\n  - Stoichiometric Unit Ratio ($fA / $cA): ${ratioA.toStringAsFixed(4)}\n\n• Reactant B ($fB):\n  - Moles available: ${molesB.toStringAsFixed(3)} mol\n  - Stoichiometric Unit Ratio ($fB / $cB): ${ratioB.toStringAsFixed(4)}\n\nConclusion:\n• ${isPerfectRatio ? "Perfect stoichiometric ratio!\nBoth reactants will be consumed entirely." : "${formatChemicalFormula(bottleneckFormula)} is the limiting reactant (lowest ratio value)."}\n• Yield of ${formatChemicalFormula(fC)} = ${finalYieldC.toStringAsFixed(2)} g\n• Yield of ${formatChemicalFormula(fD)} = ${finalYieldD.toStringAsFixed(2)} g";
        } else {
          _theoreticalYieldResult =
              "${finalYieldC.toStringAsFixed(2)} g of ${formatChemicalFormula(fC)}";
          _workLog =
              "[DUAL ENGINE BOTTLE-NECK ANALYSIS]\n• Reactant A ($fA):\n  - Moles available: ${molesA.toStringAsFixed(3)} mol\n  - Stoichiometric Unit Ratio ($fA / $cA): ${ratioA.toStringAsFixed(4)}\n\n• Reactant B ($fB):\n  - Moles available: ${molesB.toStringAsFixed(3)} mol\n  - Stoichiometric Unit Ratio ($fB / $cB): ${ratioB.toStringAsFixed(4)}\n\nConclusion:\n• ${isPerfectRatio ? "Perfect stoichiometric ratio!\nBoth reactants will be consumed entirely." : "${formatChemicalFormula(bottleneckFormula)} is the limiting reactant (lowest ratio value)."}\n• Yield of ${formatChemicalFormula(fC)} = ${finalYieldC.toStringAsFixed(2)} g";
        }
        if (!_hasError) {
          HistoryManager.addRecord(
            title: "Yield Matrix",
            details: "$cA$fA + $cB$fB ➔ $cC$fC",
            result: _theoreticalYieldResult,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    String subA = formatChemicalFormula(
      smartCapitalize(
        _formulaAController.text.isEmpty ? "A" : _formulaAController.text,
      ),
    );
    String subB = formatChemicalFormula(
      smartCapitalize(
        _formulaBController.text.isEmpty
            ? "Reactant B"
            : _formulaBController.text,
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reaction Vector Matrix Configuration",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _coeffAController,
                    decoration: const InputDecoration(
                      labelText: 'Coeff',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _formulaAController,
                    decoration: const InputDecoration(
                      labelText: 'Reactant A',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '+',
                    style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _coeffBController,
                    decoration: const InputDecoration(
                      labelText: 'Coeff',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _formulaBController,
                    decoration: const InputDecoration(
                      labelText: 'Reactant B',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '➔',
                    style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _coeffCController,
                    decoration: const InputDecoration(
                      labelText: 'Coeff',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _formulaCController,
                    decoration: const InputDecoration(
                      labelText: 'Product C',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '+',
                    style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _coeffDController,
                    decoration: const InputDecoration(
                      labelText: 'Coeff',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _formulaDController,
                    decoration: const InputDecoration(
                      labelText: 'Product D',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _gramsAController,
                    decoration: InputDecoration(
                      labelText: 'Grams of $subA',
                      suffixText: 'g',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _gramsBController,
                    decoration: InputDecoration(
                      labelText: 'Grams of $subB',
                      hintText: 'Optional Line',
                      suffixText: 'g',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.analytics, color: Colors.black),
                label: const Text(
                  'Compute Reaction Yield Metrics',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: _calculateReaction,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Limiting Bottleneck:",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _hasError
                                ? Colors.redAccent.withValues(alpha: 0.3)
                                : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                          ),
                        ),
                        child: Text(
                          _hasError ? "Error" : _limitingReactantResult,
                          style: TextStyle(
                            color: _hasError
                                ? Colors.redAccent
                                : (isDark
                                      ? Colors.amberAccent
                                      : Colors.amber.shade800),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Theoretical Yield:",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _hasError
                                ? Colors.redAccent.withValues(alpha: 0.3)
                                : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                          ),
                        ),
                        child: Text(
                          _hasError ? "Invalid Setup" : _theoreticalYieldResult,
                          style: TextStyle(
                            color: _hasError
                                ? Colors.redAccent
                                : (isDark
                                      ? AppColors.darkSuccess
                                      : AppColors.lightSuccess),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              "Analytical Diagnostic Logs:",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _hasError
                      ? Colors.redAccent.withValues(alpha: 0.2)
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              child: Text(
                _workLog,
                style: TextStyle(
                  color: _hasError
                      ? Colors.redAccent
                      : (isDark
                            ? AppColors.darkSuccess
                            : AppColors.lightSuccess),
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
