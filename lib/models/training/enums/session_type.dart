/// Defines the protocol or format of a training session.
enum SessionType {
  /// A traditional session format, typically based on sets, reps, and rest.
  classic,

  /// 'Every Minute On the Minute' - a form of interval training.
  emom,

  /// 'High-Intensity Interval Training' - alternating between intense bursts and rest.
  hiit,

  /// 'As Many Rounds As Possible' - completing as many rounds as possible in a given time.
  amrap;

  /// Converts the enum to its JSON string representation (uppercase).
  String toJson() {
    switch (this) {
      case SessionType.classic:
        return 'CLASSIC';
      case SessionType.emom:
        return 'EMOM';
      case SessionType.hiit:
        return 'HIIT';
      case SessionType.amrap:
        return 'AMRAP';
    }
  }

  /// Creates a [SessionType] from its JSON string representation (uppercase).
  static SessionType fromJson(String value) {
    switch (value) {
      case 'CLASSIC':
        return SessionType.classic;
      case 'EMOM':
        return SessionType.emom;
      case 'HIIT':
        return SessionType.hiit;
      case 'AMRAP':
        return SessionType.amrap;
      default:
        throw ArgumentError.value(value, 'value', 'Invalid SessionType');
    }
  }
}
