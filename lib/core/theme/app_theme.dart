import 'package:fluent_ui/fluent_ui.dart';
import 'app_colors.dart';

// ── Builders de FluentThemeData ───────────────────────────────────────────────
// Cada builder inyecta la instancia correcta de AppColors como ThemeExtension.
// Los widgets leen los tokens vía context.colors — nunca acceden a las clases
// ShadNeutral / ShadNeutralLight directamente.


 const double radius = 8.0;
 const double radiusSm = 6.0;
 const double radiusLg = 10.0;
 const double radiusXl = 12.0;
FluentThemeData buildDarkTheme() => FluentThemeData(
      brightness: Brightness.dark,
      extensions: [appColorsDark],
      accentColor: AccentColor.swatch(const {
        'darkest': Color(0xFF525252),
        'darker': Color(0xFF737373),
        'dark': Color(0xFFA3A3A3),
        'normal': Color(0xFFE5E5E5),
        'light': Color(0xFFF5F5F5),
        'lighter': Color(0xFFFAFAFA),
        'lightest': Color(0xFFFFFFFF),
      }),
      scaffoldBackgroundColor: appColorsDark.background,
      cardColor: appColorsDark.card,
      micaBackgroundColor: appColorsDark.sidebar,
      navigationPaneTheme: NavigationPaneThemeData(
        backgroundColor: appColorsDark.sidebar,
        highlightColor: appColorsDark.foreground,
      ),
      typography: Typography.raw(
        body: TextStyle(
          fontFamily: 'SF Pro Text',
          color: appColorsDark.foreground,
          fontSize: 14,
          letterSpacing: -0.1,
        ),
      ),
    );

FluentThemeData buildLightTheme() => FluentThemeData(
      brightness: Brightness.light,
      extensions: [appColorsLight],
      accentColor: AccentColor.swatch(const {
        'darkest': Color(0xFF171717),
        'darker': Color(0xFF262626),
        'dark': Color(0xFF404040),
        'normal': Color(0xFF525252),
        'light': Color(0xFF737373),
        'lighter': Color(0xFFA3A3A3),
        'lightest': Color(0xFFD4D4D4),
      }),
      scaffoldBackgroundColor: appColorsLight.background,
      cardColor: appColorsLight.card,
      micaBackgroundColor: appColorsLight.sidebar,
      navigationPaneTheme: NavigationPaneThemeData(
        backgroundColor: appColorsLight.sidebar,
        highlightColor: appColorsLight.foreground,
      ),
      typography: Typography.raw(
        body: TextStyle(
          fontFamily: 'SF Pro Text',
          color: appColorsLight.foreground,
          fontSize: 14,
          letterSpacing: -0.1,
        ),
      ),
    );
