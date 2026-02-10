import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

/// Botón para alternar entre modos de tema (claro/oscuro/sistema)
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return PopupMenuButton<ThemeMode>(
      icon: Icon(_getIcon(themeMode)),
      tooltip: 'Cambiar tema',
      onSelected: (ThemeMode mode) {
        ref.read(themeProvider.notifier).setTheme(mode);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: ThemeMode.system,
          child: Row(
            children: [
              Icon(
                Icons.phone_android,
                color: themeMode == ThemeMode.system 
                    ? Theme.of(context).primaryColor 
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Sistema',
                style: TextStyle(
                  fontWeight: themeMode == ThemeMode.system 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
              if (themeMode == ThemeMode.system) ...[
                const Spacer(),
                Icon(Icons.check, color: Theme.of(context).primaryColor),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(
                Icons.light_mode,
                color: themeMode == ThemeMode.light 
                    ? Theme.of(context).primaryColor 
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Claro',
                style: TextStyle(
                  fontWeight: themeMode == ThemeMode.light 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
              if (themeMode == ThemeMode.light) ...[
                const Spacer(),
                Icon(Icons.check, color: Theme.of(context).primaryColor),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(
                Icons.dark_mode,
                color: themeMode == ThemeMode.dark 
                    ? Theme.of(context).primaryColor 
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Oscuro',
                style: TextStyle(
                  fontWeight: themeMode == ThemeMode.dark 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
              if (themeMode == ThemeMode.dark) ...[
                const Spacer(),
                Icon(Icons.check, color: Theme.of(context).primaryColor),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  /// Obtiene el ícono correspondiente al modo de tema actual
  IconData _getIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      default:
        return Icons.brightness_auto;
    }
  }
}
