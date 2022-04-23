enum Flavor {
  PRODUCTION,
  UAT,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.PRODUCTION:
        return 'Mall';
      case Flavor.UAT:
        return 'UAT Mall';
      default:
        return 'title';
    }
  }

}
