import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// A custom [RouteObserver] that observes route changes and logs them
class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final Logger _logger = Logger('AppRouteObserver');
  
  // Track the current route name
  String? _currentRouteName;
  
  // Get the current route name
  String? get currentRouteName => _currentRouteName;
  
  // Track the previous route name
  String? _previousRouteName;
  
  // Get the previous route name
  String? get previousRouteName => _previousRouteName;
  
  // Track the time when the current route was pushed
  DateTime? _routePushedAt;
  
  // Get the duration of the current route
  Duration? get currentRouteDuration => 
      _routePushedAt != null ? DateTime.now().difference(_routePushedAt!) : null;
  
  // Callback when route is pushed
  final Function(String? previousRoute, String? newRoute)? onRoutePushed;
  
  // Callback when route is popped
  final Function(String? previousRoute, String? newRoute)? onRoutePopped;
  
  // Callback when route is replaced
  final Function(String? previousRoute, String? newRoute)? onRouteReplaced;
  
  AppRouteObserver({
    this.onRoutePushed,
    this.onRoutePopped,
    this.onRouteReplaced,
  });
  
  /// Called when a new route is pushed onto the navigator
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _handleRouteChange(route, previousRoute, RouteChangeType.push);
  }
  
  /// Called when a route is popped off the navigator
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _handleRouteChange(previousRoute, route, RouteChangeType.pop);
  }
  
  /// Called when a route is replaced with another route
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _handleRouteChange(newRoute, oldRoute, RouteChangeType.replace);
  }
  
  /// Handle route changes and update the current and previous route names
  void _handleRouteChange(
    Route<dynamic>? newRoute, 
    Route<dynamic>? oldRoute, 
    RouteChangeType changeType,
  ) {
    final newRouteName = _getRouteName(newRoute);
    final oldRouteName = _getRouteName(oldRoute);
    
    // Update route tracking
    switch (changeType) {
      case RouteChangeType.push:
        _previousRouteName = _currentRouteName;
        _currentRouteName = newRouteName;
        _routePushedAt = DateTime.now();
        _logRouteChange('Pushed', newRouteName, oldRouteName);
        onRoutePushed?.call(oldRouteName, newRouteName);
        break;
      case RouteChangeType.pop:
        _previousRouteName = _currentRouteName;
        _currentRouteName = oldRouteName;
        _logRouteChange('Popped', oldRouteName, newRouteName);
        onRoutePopped?.call(newRouteName, oldRouteName);
        break;
      case RouteChangeType.replace:
        _previousRouteName = oldRouteName;
        _currentRouteName = newRouteName;
        _logRouteChange('Replaced', newRouteName, oldRouteName);
        onRouteReplaced?.call(oldRouteName, newRouteName);
        break;
    }
    
    // Log the route change to analytics or other services
    _logRouteToAnalytics(newRouteName, oldRouteName, changeType);
  }
  
  /// Get the route name from a route
  String? _getRouteName(Route<dynamic>? route) {
    if (route == null) return null;
    
    // For named routes
    if (route.settings.name != null) {
      return route.settings.name;
    }
    
    // For page routes with a builder
    if (route is PageRoute && route.settings.name == null) {
      return route.settings.name ?? route.runtimeType.toString();
    }
    
    // For modal routes
    if (route is ModalRoute) {
      return route.settings.name ?? route.runtimeType.toString();
    }
    
    // Fallback to runtime type
    return route.runtimeType.toString();
  }
  
  /// Log route changes to the console
  void _logRouteChange(String action, String? to, String? from) {
    _logger.fine('$action: ${from ?? 'null'} -> ${to ?? 'null'}' + 
        (currentRouteDuration != null ? ' (${currentRouteDuration!.inSeconds}s)' : ''));
  }
  
  /// Log route changes to analytics
  void _logRouteToAnalytics(
    String? to, 
    String? from, 
    RouteChangeType changeType,
  ) {
    // TODO: Implement analytics logging (e.g., Firebase Analytics, Sentry, etc.)
    // Example:
    // FirebaseAnalytics().logEvent(
    //   name: 'screen_view',
    //   parameters: {
    //     'from': from,
    //     'to': to,
    //     'change_type': changeType.toString(),
    //     'timestamp': DateTime.now().toIso8601String(),
    //   },
    // );
  }
  
  /// Get the current route's path as a list of route names
  List<String> getCurrentRoutePath() {
    final path = <String>[];
    
    // Start with the current route
    if (_currentRouteName != null) {
      path.add(_currentRouteName!);
    }
    
    // Add the previous route if available
    if (_previousRouteName != null) {
      path.add(_previousRouteName!);
    }
    
    return path;
  }
  
  /// Check if the current route is in a specific path
  bool isInPath(String routeName) {
    return getCurrentRoutePath().contains(routeName);
  }
  
  /// Check if the current route is the same as the given route name
  bool isCurrentRoute(String routeName) {
    return _currentRouteName == routeName;
  }
  
  /// Check if the previous route is the same as the given route name
  bool isPreviousRoute(String routeName) {
    return _previousRouteName == routeName;
  }
  
  /// Reset the route observer
  void reset() {
    _currentRouteName = null;
    _previousRouteName = null;
    _routePushedAt = null;
  }
}

/// Type of route change
enum RouteChangeType {
  push,
  pop,
  replace,
}

/// Global instance of the route observer
final appRouteObserver = AppRouteObserver();
