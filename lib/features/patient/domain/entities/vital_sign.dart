import 'package:equatable/equatable.dart';

class VitalSign extends Equatable {
  final DateTime timestamp;
  final int spo2; // Oxygen Saturation %
  final int bpm;  // Heart Rate Beats Per Minute
  final double temperature; // Celsius

  const VitalSign({
    required this.timestamp,
    required this.spo2,
    required this.bpm,
    required this.temperature,
  });

  @override
  List<Object?> get props => [timestamp, spo2, bpm, temperature];

  factory VitalSign.fromJson(Map<String, dynamic> json) {
    return VitalSign(
      timestamp: DateTime.now(),
      spo2: (json['spo2'] as num?)?.toInt() ?? 0,
      bpm: (json['bpm'] as num?)?.toInt() ?? 0,
      temperature: (json['temp'] as num?)?.toDouble() ?? 0.0,
    );
  }

  bool get isCritical {
    return spo2 < 90 || bpm > 120 || bpm < 40 || temperature > 38.0;
  }
  
  bool get isWarning {
    return !isCritical && (spo2 < 95 || bpm > 100 || temperature > 37.5);
  }
}
