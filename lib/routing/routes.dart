abstract final class Routes {
  static const home = '/';

  static const createBill = '/bills/create';
  static String editBill(int id) => '/bills/$id';

  static const calendar = '/calendar';

  static const settingsNotifications = '/settings/notifications';
}
