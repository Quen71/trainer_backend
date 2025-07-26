/// Defines the style or focus of a training session.
enum SessionStyle {
  /// A session focused on bodyweight exercises.
  bodyweight,

  /// A session focused on training with weights.
  weights,

  /// A session focused on stretching and mobility work.
  stretchingMobility;

  /// Converts the enum to its JSON string representation.
  String toJson() {
    switch (this) {
      case SessionStyle.bodyweight:
        return 'bodyweight';
      case SessionStyle.weights:
        return 'weights';
      case SessionStyle.stretchingMobility:
        return 'stretching_mobility';
    }
  }

  /// Creates a [SessionStyle] from its JSON string representation.
  static SessionStyle fromJson(String value) {
    switch (value) {
      case 'bodyweight':
        return SessionStyle.bodyweight;
      case 'weights':
        return SessionStyle.weights;
      case 'stretching_mobility':
        return SessionStyle.stretchingMobility;
      default:
        throw ArgumentError.value(value, 'value', 'Invalid SessionStyle');
    }
  }
}
