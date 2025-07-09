// lib/search_criteria.dart

class SearchCriteria {
  final String? deceasedName;
  final String? deceasedDod; // User's input string "DD/MM/YYYY"
  final String? state;
  final String? area;
  final String? category;
  final String? graveLot;
  final String? graveAddress;

  SearchCriteria({
    this.deceasedName,
    this.deceasedDod,
    this.state,
    this.area,
    this.category,
    this.graveLot,
    this.graveAddress,
  });

  // Check if any text field (excluding DoD which can be complex) has input
  // or if state/area are selected.
  bool get isEffectivelyEmpty {
    bool isStringEmpty(String? s) => s == null || s.trim().isEmpty;

    return isStringEmpty(deceasedName) &&
        isStringEmpty(deceasedDod) && // DoD can be empty
        isStringEmpty(state) &&       // State can be unselected
        isStringEmpty(area) &&        // Area can be unselected
        isStringEmpty(category) &&
        isStringEmpty(graveLot) &&
        isStringEmpty(graveAddress);
  }
}