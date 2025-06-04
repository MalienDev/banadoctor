import 'package:flutter/material.dart';
import 'package:medecin_mobile/src/utils/constants.dart';

/// A collection of custom page route transitions
class AppPageRoute<T> extends PageRouteBuilder<T> {
  /// The widget to display as the main content of the route
  final WidgetBuilder builder;
  
  /// The route settings for this route
  final RouteSettings? routeSettings;
  
  /// The duration of the transition animation
  final Duration? transitionDurationValue;
  
  /// The type of transition to use
  final RouteTransitionType transitionType;
  
  /// Whether the route is fullscreen
  final bool fullscreenDialog;
  
  /// Whether the route maintains state when not visible
  final bool maintainState;
  
  /// Whether the route is opaque
  final bool opaque;
  
  /// The color to use for the barrier
  final Color? barrierColor;
  
  /// The label for the barrier
  final String? barrierLabel;
  
  AppPageRoute({
    required this.builder,
    this.routeSettings,
    this.transitionDurationValue,
    this.transitionType = RouteTransitionType.fade,
    this.fullscreenDialog = false,
    this.maintainState = true,
    this.opaque = true,
    this.barrierColor,
    this.barrierLabel,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              builder(context),
          settings: routeSettings,
          transitionDuration: transitionDurationValue ?? kDefaultAnimationDuration,
          reverseTransitionDuration: transitionDurationValue ?? kDefaultAnimationDuration,
          fullscreenDialog: fullscreenDialog,
          maintainState: maintainState,
          opaque: opaque,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
          transitionsBuilder: _getTransitionBuilder(transitionType),
        );
  
  /// Get the appropriate transition builder based on the transition type
  static RouteTransitionsBuilder _getTransitionBuilder(RouteTransitionType type) {
    switch (type) {
      case RouteTransitionType.fade:
        return _fadeTransitionBuilder;
      case RouteTransitionType.slideRight:
        return _slideRightTransitionBuilder;
      case RouteTransitionType.slideLeft:
        return _slideLeftTransitionBuilder;
      case RouteTransitionType.slideUp:
        return _slideUpTransitionBuilder;
      case RouteTransitionType.scale:
        return _scaleTransitionBuilder;
      case RouteTransitionType.rotate:
        return _rotateTransitionBuilder;
      case RouteTransitionType.size:
        return _sizeTransitionBuilder;
      case RouteTransitionType.scaleRotate:
        return _scaleRotateTransitionBuilder;
      case RouteTransitionType.none:
        return _noneTransitionBuilder;
      default:
        return _defaultTransitionBuilder;
    }
  }
  
  // Default transition (platform specific)
  static Widget _defaultTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
  
  // No transition
  static Widget _noneTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
  
  // Fade transition
  static Widget _fadeTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
  
  // Slide from right transition
  static Widget _slideRightTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;
    
    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);
    
    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
  
  // Slide from left transition
  static Widget _slideLeftTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(-1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;
    
    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);
    
    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
  
  // Slide from bottom transition
  static Widget _slideUpTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;
    
    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);
    
    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
  
  // Scale transition
  static Widget _scaleTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        ),
      ),
      child: child,
    );
  }
  
  // Rotate transition
  static Widget _rotateTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return RotationTransition(
      turns: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.linear,
        ),
      ),
      child: child,
    );
  }
  
  // Size transition
  static Widget _sizeTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Align(
      alignment: Alignment.center,
      child: SizeTransition(
        sizeFactor: animation,
        axis: Axis.vertical,
        axisAlignment: -1.0,
        child: child,
      ),
    );
  }
  
  // Scale and rotate transition
  static Widget _scaleRotateTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        ),
      ),
      child: RotationTransition(
        turns: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.linear,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Types of route transitions
enum RouteTransitionType {
  /// No transition
  none,
  
  /// Fade transition
  fade,
  
  /// Slide in from right
  slideRight,
  
  /// Slide in from left
  slideLeft,
  
  /// Slide up from bottom
  slideUp,
  
  /// Scale transition
  scale,
  
  /// Rotate transition
  rotate,
  
  /// Size transition
  size,
  
  /// Scale and rotate transition
  scaleRotate,
  
  /// Default platform transition
  platform,
}

/// Extension methods for [RouteTransitionType]
extension RouteTransitionTypeExtension on RouteTransitionType {
  /// Get the page route builder for this transition type
  PageRoute<T> buildRoute<T>(
    WidgetBuilder builder, {
    RouteSettings? settings,
    Duration? transitionDuration,
    bool fullscreenDialog = false,
    bool maintainState = true,
    bool opaque = true,
    Color? barrierColor,
    String? barrierLabel,
  }) {
    return AppPageRoute<T>(
      builder: builder,
      routeSettings: settings,
      transitionDurationValue: transitionDuration,
      transitionType: this,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
      opaque: opaque,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
    );
  }
  
  /// Get the page route builder for a full-screen dialog
  PageRoute<T> buildDialogRoute<T>(
    WidgetBuilder builder, {
    RouteSettings? settings,
    Duration? transitionDuration,
    bool maintainState = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
  }) {
    return AppPageRoute<T>(
      builder: builder,
      routeSettings: settings,
      transitionDurationValue: transitionDuration,
      transitionType: this,
      fullscreenDialog: true,
      maintainState: maintainState,
      opaque: false,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
    );
  }
}

/// A utility class for creating custom page routes
class RouteUtils {
  /// Push a new route with a custom transition
  static Future<T?> push<T>(
    BuildContext context,
    WidgetBuilder builder, {
    RouteTransitionType transition = RouteTransitionType.slideRight,
    RouteSettings? settings,
    bool fullscreenDialog = false,
    bool maintainState = true,
    bool opaque = true,
    Color? barrierColor,
    String? barrierLabel,
  }) {
    return Navigator.of(context).push<T>(
      transition.buildRoute<T>(
        builder,
        settings: settings,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
        opaque: opaque,
        barrierColor: barrierColor,
        barrierLabel: barrierLabel,
      ),
    );
  }
  
  /// Push a full-screen dialog with a custom transition
  static Future<T?> pushDialog<T>(
    BuildContext context,
    WidgetBuilder builder, {
    RouteTransitionType transition = RouteTransitionType.slideUp,
    RouteSettings? settings,
    bool maintainState = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
  }) {
    return Navigator.of(context).push<T>(
      transition.buildDialogRoute<T>(
        builder,
        settings: settings,
        maintainState: maintainState,
        barrierColor: barrierColor,
        barrierLabel: barrierLabel,
      ),
    );
  }
  
  /// Push a new route and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    WidgetBuilder builder, {
    RouteTransitionType transition = RouteTransitionType.fade,
    RouteSettings? settings,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      transition.buildRoute(
        builder,
        settings: settings,
      ),
      predicate ?? (Route<dynamic> route) => false,
    );
  }
  
  /// Push a named route with custom transitions
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    RouteTransitionType transition = RouteTransitionType.slideRight,
    bool fullscreenDialog = false,
  }) {
    return Navigator.of(context).push<T>(
      transition.buildRoute<T>(
        (context) => _getRoute(routeName, arguments),
        settings: RouteSettings(
          name: routeName,
          arguments: arguments,
        ),
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }
  
  // Helper method to get the appropriate route based on route name
  static Widget _getRoute(String routeName, Object? arguments) {
    // This would be replaced with your actual route generation logic
    // For example, using a switch statement or a route factory
    return Container(); // Placeholder
  }
}
