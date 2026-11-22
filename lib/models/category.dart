/// Data model representing a product category in `public.categories`.
class CategoryRecord {
  final int id;
  final String name;

  const CategoryRecord({
    required this.id,
    required this.name,
  });

  /// Deserializes a category row returned from Supabase PostgREST.
  factory CategoryRecord.fromJson(Map<String, dynamic> json) {
    return CategoryRecord(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  /// Serializes the category record into a key-value map.
  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id': id,
      'name': name,
    };
  }

  CategoryRecord copyWith({
    int? id,
    String? name,
  }) {
    return CategoryRecord(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryRecord && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}
