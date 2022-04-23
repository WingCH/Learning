enum Flavor {
  PRODUCTION,
  UAT,
}

class EnvConfig {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
   return appFlavor.toString();
  }

  static String get baseUrl {
    switch (appFlavor) {
      case Flavor.PRODUCTION:
        return 'https://www.api.com';
      case Flavor.UAT:
        return 'https://www.uat.api.com';
      default:
        return 'https://www.uat.api.com';
    }
  }
}
