import 'package:flutter/material.dart';
import '../utils/chemistry_utils.dart';
import '../utils/history_manager.dart';

class ReverseCalcPage extends StatefulWidget {
  // Fixed: Converted to super parameter
  const ReverseCalcPage({super.key});

  @override
  State<ReverseCalcPage> createState() => _ReverseCalcPageState();
}

class _ReverseCalcPageState extends State<ReverseCalcPage> {
  // Input Controllers
  final _coeffAController = TextEditingController(text: '');
  final _formulaAController = TextEditingController(text: '');
  final _coeffBController = TextEditingController(text: '');
  final _formulaBController = TextEditingController(text: '');
  final _coeffCController = TextEditingController(text: '');
  final _formulaCController = TextEditingController(text: '');

  // Target Product Input
  final _targetGramsController = TextEditingController(text: '');

  String _result = '';
  String _workLog = '';
  bool _hasError = false;

  void _calculateReverse() {
    setState(() {
      _hasError = false;

      // Extract Inputs
      String fA = _formulaAController.text.trim().toUpperCase();
      String fB = _formulaBController.text.trim().toUpperCase();
      String fC = _formulaCController.text.trim().toUpperCase();

      int cA = int.tryParse(_coeffAController.text) ?? 0;
      int cB = int.tryParse(_coeffBController.text) ?? 0;
      int cC = int.tryParse(_coeffCController.text) ?? 0;

      double targetGramsC =
          double.tryParse(_targetGramsController.text) ?? -1.0;

      // 1. Validation Checks
      if (cA <= 0 || cB <= 0 || cC <= 0 || targetGramsC <= 0) {
        _hasError = true;
        _workLog =
            "⚠️ Operational Error:\nAll coefficients and target mass figures must be positive numbers.";
        return;
      }

      double mmA = ChemistryUtils.calculateMolarMass(fA);
      double mmB = ChemistryUtils.calculateMolarMass(fB);
      double mmC = ChemistryUtils.calculateMolarMass(fC);

      if (mmA == 0.0 || mmB == 0.0 || mmC == 0.0) {
        _hasError = true;
        _workLog =
            "⚠️ Parsing Error:\nOne or more formulas could not be mapped to valid periodic properties.";
        return;
      }

      // 2. The Reverse Stoichiometry Math
      // target grams C -> moles C
      double molesC = targetGramsC / mmC;

      // Use ratio logic: moles reactant = moles product * (coeff reactant / coeff product)
      double requiredMolesA = molesC * (cA / cC);
      double requiredMolesB = molesC * (cB / cC);

      // Convert back to grams
      double requiredGramsA = requiredMolesA * mmA;
      double requiredGramsB = requiredMolesB * mmB;

      // 3. Update Results and Diagnostics
      _result =
          "• ${requiredGramsA.toStringAsFixed(2)} g of $fA\n"
          "• ${requiredGramsB.toStringAsFixed(2)} g of $fB";

      _workLog =
          "[REVERSE TARGET CALCULATION LOG]\n"
          "• Target Yield: $targetGramsC g of $fC\n"
          "• Target Moles of $fC: $targetGramsC / ${mmC.toStringAsFixed(3)} g/mol = ${molesC.toStringAsFixed(4)} mol\n\n"
          "Required Reactant calculations:\n"
          "• $fA moles needed: ${molesC.toStringAsFixed(4)} mol × ($cA/$cC ratio) = ${requiredMolesA.toStringAsFixed(4)} mol\n"
          "  - Mass needed: ${requiredMolesA.toStringAsFixed(4)} mol × ${mmA.toStringAsFixed(3)} g/mol = ${requiredGramsA.toStringAsFixed(2)} g\n\n"
          "• $fB moles needed: ${molesC.toStringAsFixed(4)} mol × ($cB/$cC ratio) = ${requiredMolesB.toStringAsFixed(4)} mol\n"
          "  - Mass needed: ${requiredMolesB.toStringAsFixed(4)} mol × ${mmB.toStringAsFixed(3)} g/mol = ${requiredGramsB.toStringAsFixed(2)} g";

      if (!_hasError) {
        HistoryManager.addRecord(
          title: "Target Prep",
          details: "Target: $targetGramsC g of $fC",
          result: _result,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Reverse Stoichiometry Engine",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Input your target product mass to find out exactly how much starting material you need to measure out.",
            ),
            const Divider(height: 32),

            // UI inputs for coefficients & formulas (similar to forward layout but optimized for space)
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _coeffAController,
                    'Coeff',
                    TextInputType.number,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: _buildTextField(_formulaAController, 'Reactant A'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('+'),
                ),
                Expanded(
                  child: _buildTextField(
                    _coeffBController,
                    'Coeff',
                    TextInputType.number,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: _buildTextField(_formulaBController, 'Reactant B'),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.arrow_downward, color: Colors.blueAccent),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildTextField(
                    _coeffCController,
                    'Coeff',
                    TextInputType.number,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: _buildTextField(_formulaCController, 'Product C'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Target Grams Input Card
            Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Target Yield Mass (g):",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _targetGramsController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _calculateReverse,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Calculate Required Reactants"),
            ),
            const SizedBox(height: 24),

            // Output Panels
            if (_result.isNotEmpty || _hasError) ...[
              Text(
                _hasError ? "Calculation Failed" : "Required Material",
                style: TextStyle(
                  fontSize: 18,
                  color: _hasError ? Colors.redAccent : Colors.greenAccent,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _hasError ? Colors.red : Colors.green,
                  ),
                ),
                child: Text(
                  _hasError ? _workLog : _result,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              if (!_hasError) ...[
                const Text(
                  "Calculation Log:",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.black45,
                  child: Text(
                    _workLog,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label, [
    TextInputType type = TextInputType.text,
  ]) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
