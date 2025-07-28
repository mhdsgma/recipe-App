
class ParsedIngredient {
  final double? quantity;
  final String? unit;
  final String name;
  final String originalString;

  ParsedIngredient({
    this.quantity,
    this.unit,
    required this.name,
    required this.originalString,
  });
  ParsedIngredient scale(double factor) {
    return ParsedIngredient(
      quantity: quantity != null ? quantity! * factor : null,
      unit: unit,
      name: name,
      originalString: originalString,
    );
  }
  String format() {
    String quantityStr = "";
    if (quantity != null) {
      if (quantity == quantity!.toInt()) {
        quantityStr = quantity!.toInt().toString();
      } else {
        quantityStr = quantity!.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), ''); // Remove trailing .0 or .00
      }
    }
    String unitStr = unit ?? "";

    return "${quantityStr.isNotEmpty ? '$quantityStr ' : ''}${unitStr.isNotEmpty ? '$unitStr ' : ''}$name".trim();
  }
}
class IngredientParser {
  static ParsedIngredient parse(String ingredientString) {
    ingredientString = ingredientString.trim();
    final original = ingredientString;


    final regex = RegExp(r'^(\d*\.?\d+|\d+\/\d+)?\s*([a-zA-Z]+)?\s*(.*)');
    final match = regex.firstMatch(ingredientString);

    double? quantity;
    String? unit;
    String name = ingredientString;

    if (match != null) {
      String? quantityPart = match.group(1);
      String? unitPart = match.group(2);
      String? namePart = match.group(3);

      if (quantityPart != null && quantityPart.isNotEmpty) {
        quantity = _parseQuantity(quantityPart);
      }

      // Basic unit handling (could be expanded with a known list)
      if (unitPart != null && unitPart.isNotEmpty) {
        unit = unitPart;
      }

      if (namePart != null && namePart.isNotEmpty) {
        name = namePart.trim();
      } else if (unitPart != null && quantityPart == null) {
        name = "$unitPart ${namePart ?? ''}".trim();
        unit = null;
      }
    }

    return ParsedIngredient(
      quantity: quantity,
      unit: unit,
      name: name,
      originalString: original,
    );
  }

  static double? _parseQuantity(String quantityStr) {
    try {
      if (quantityStr.contains('/')) {
        final parts = quantityStr.split('/');
        if (parts.length == 2) {
          final numerator = double.tryParse(parts[0]);
          final denominator = double.tryParse(parts[1]);
          if (numerator != null && denominator != null && denominator != 0) {
            return numerator / denominator;
          }
        }
      } else {
        return double.tryParse(quantityStr);
      }
    } catch (e) {
      print("Error parsing quantity '$quantityStr': $e");
    }
    return null;
  }
}

