enum AppRoute {
  welcomeScreen,
  playerScreen
}

extension AppRouteExtension on AppRoute {
  String get name {
    switch (this) {
      case AppRoute.welcomeScreen:
        return "/";
      case AppRoute.playerScreen:
        return "/player";
    }
  }
}