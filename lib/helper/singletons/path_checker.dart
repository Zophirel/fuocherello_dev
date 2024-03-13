//PathChecker is a signleton that help to keep track of which is the current app route
//it is used for the chat page screen to prevent the opened chat notifications to appear
//and to re enable the notifications when the user goes from the chat page screen to the background (inactive state)
class PathChecker {
  static final PathChecker _pathChecker = PathChecker._internal();
  PathChecker._internal();
  static PathChecker get instance => _pathChecker;
  static bool isChatOpen = false;
  static String _currentLocation = '/';
  static String get getCurrentLocation {
    return _currentLocation;
  }

  static set setLocation(String newLocation) {
    _currentLocation = newLocation;
  }

  static List<String> getChatValue() {
    return _currentLocation.substring(1, _currentLocation.length).split('/');
  }
}
