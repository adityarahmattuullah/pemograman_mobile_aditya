class ShoppingItem {
  String name;
  int quantity;
  String category;
  bool isBought;

  ShoppingItem({
    required this.name,
    required this.quantity,
    required this.category,
    this.isBought = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'category': category,
        'isBought': isBought,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      name: json['name'],
      quantity: json['quantity'],
      category: json['category'],
      isBought: json['isBought'],
    );
  }
}
