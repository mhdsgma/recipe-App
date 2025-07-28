class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String imageUrl;
  final String categoryId;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? servings;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.imageUrl,
    required this.categoryId,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
  });


  factory Recipe.fromJson(Map<String, dynamic> json, String id) {
    return Recipe(
      id: id,
      name: json["name"] ?? "",
      description: json["description"] ?? "",

      ingredients: List<String>.from(json["ingredients"] ?? []),
      instructions: List<String>.from(json["instructions"] ?? []),
      imageUrl: json["imageUrl"] ?? "",
      categoryId: json["categoryId"] ?? "",
      prepTimeMinutes: json["prepTimeMinutes"] as int?,
      cookTimeMinutes: json["cookTimeMinutes"] as int?,
      servings: json["servings"] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "ingredients": ingredients,
      "instructions": instructions,
      "imageUrl": imageUrl,
      "categoryId": categoryId,
      "prepTimeMinutes": prepTimeMinutes,
      "cookTimeMinutes": cookTimeMinutes,
      "servings": servings,
    };
  }
}


