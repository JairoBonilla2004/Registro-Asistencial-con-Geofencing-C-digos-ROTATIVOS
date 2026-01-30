import 'package:intl/intl.dart';

/// Utilidades para formateo de fechas
class DateUtils {
  /// Formatea una fecha a formato legible: "26 de diciembre de 2025"
  static String formatDate(DateTime date) {
    return DateFormat('d \'de\' MMMM \'de\' yyyy', 'es').format(date);
  }

  /// Formatea una fecha y hora: "26/12/2025 10:05"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Formatea solo la hora: "10:05"
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Formatea fecha corta: "26/12/2025"
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Retorna tiempo relativo: "hace 5 minutos", "hace 2 horas", etc.
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'hace ${difference.inSeconds} segundos';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'hace $weeks semana${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'hace $months mes${months > 1 ? 'es' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'hace $years año${years > 1 ? 's' : ''}';
    }
  }

  /// Convierte string ISO 8601 a DateTime
  static DateTime? parseIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Calcula la duración entre dos fechas en formato legible
  static String formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    
    if (duration.inHours > 0) {
      return '${duration.inHours} hora${duration.inHours > 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minuto${duration.inMinutes > 1 ? 's' : ''}';
    } else {
      return '${duration.inSeconds} segundo${duration.inSeconds > 1 ? 's' : ''}';
    }
  }

  /// Formatea el delay de sincronización
  static String formatSyncDelay(Duration delay) {
    if (delay.inMinutes > 0) {
      return '${delay.inMinutes} minuto${delay.inMinutes > 1 ? 's' : ''} ${delay.inSeconds % 60} segundo${(delay.inSeconds % 60) > 1 ? 's' : ''}';
    } else {
      return '${delay.inSeconds} segundo${delay.inSeconds > 1 ? 's' : ''}';
    }
  }
}
