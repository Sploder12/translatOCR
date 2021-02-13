extension UsefulMethods on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1);
  }

  String convertMathOperators(Map<String, String> mappings) {
    String result = this;
    mappings.forEach((key, value) => () {
          result.replaceAll(key, value);
        });
    return result;
  }

  bool isThereMathExpression() {
    return this.contains("*") ||
        this.contains("/") ||
        this.contains("+") ||
        this.contains("-");
  }

  bool isUserTryingToCalculate() {
    RegExp pattern = RegExp(r"\s*What does \d+.+\d+ equal to\s*");
    List<RegExpMatch> matches = pattern.allMatches(this).toList();
    return matches.isNotEmpty;
  }

  String findMathExpr() {
    RegExp pattern = RegExp(r"\d+.+\d+");
    List<RegExpMatch> matches = pattern.allMatches(this).toList();
    if (matches.isNotEmpty) {
      return matches.first.group(0);
    } else {
      throw("There should be at least one match!!!");
    }
  }
}


// Example: What is 3 times 5?
//speech -> text -> understand the text enough - > intentions -> calculate the expression
// (machine learning)
