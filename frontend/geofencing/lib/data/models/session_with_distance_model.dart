class SessionWithDistanceModel {
  final String sessionId;
  final String name;
  final String teacherName;
  final String zoneName;
  final double zoneLatitude;
  final double zoneLongitude;
  final int radiusMeters;
  final double distanceInMeters;
  final bool withinZone;
  final String? qrToken;
  final DateTime startTime;
  final DateTime? endTime;
  final bool active;

  SessionWithDistanceModel({
    required this.sessionId,
    required this.name,
    required this.teacherName,
    required this.zoneName,
    required this.zoneLatitude,
    required this.zoneLongitude,
    required this.radiusMeters,
    required this.distanceInMeters,
    required this.withinZone,
    this.qrToken,
    required this.startTime,
    this.endTime,
    required this.active,
  });

  factory SessionWithDistanceModel.fromJson(Map<String, dynamic> json) {
    return SessionWithDistanceModel(
      sessionId: json['sessionId'],
      name: json['name'],
      teacherName: json['teacherName'],
      zoneName: json['zoneName'],
      zoneLatitude: (json['zoneLatitude'] as num).toDouble(),
      zoneLongitude: (json['zoneLongitude'] as num).toDouble(),
      radiusMeters: json['radiusMeters'],
      distanceInMeters: (json['distanceInMeters'] as num).toDouble(),
      withinZone: json['withinZone'],
      qrToken: json['qrToken'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      active: json['active'],
    );
  }

  String getDistanceText() {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }

  String getProximityEmoji() {
    if (withinZone) return '✅';
    if (distanceInMeters <= 10) return '🟢';
    if (distanceInMeters <= 50) return '🟡';
    if (distanceInMeters <= 100) return '🟠';
    return '🔴';
  }

  String getProximityMessage() {
    if (withinZone) return 'Dentro de la zona';
    if (distanceInMeters <= 10) return 'Muy cerca';
    if (distanceInMeters <= 50) return 'Cerca';
    if (distanceInMeters <= 100) return 'A poca distancia';
    return 'Lejos';
  }

  bool canScanQR() {
    // Permitir escanear solo si está dentro de la zona o muy cerca (dentro del radio + 50m de tolerancia)
    return distanceInMeters <= (radiusMeters + 50);
  }
}
