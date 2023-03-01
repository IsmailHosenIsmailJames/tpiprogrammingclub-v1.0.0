import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tpiprogrammingclub/theme/theme.dart';

bool isDark = false;

class ChangeThemeButtonWidget extends StatelessWidget {
  const ChangeThemeButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Switch.adaptive(
      value: themeProvider.isDarkMode,
      onChanged: (value) {
        isDark = value;
        final provider = Provider.of<ThemeProvider>(context, listen: false);
        provider.toggleTheme(value);
      },
    );
  }
}
