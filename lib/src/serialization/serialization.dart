/// identifiers from 11000
abstract class SerializationIdentifier {
  /// Identifier id must be grather than 258 for custom types.
  int get id;
  bool isValid(int? tag);
}
