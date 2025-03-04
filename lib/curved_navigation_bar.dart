import 'dart:io';

import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:curved_labeled_navigation_bar/src/nav_bar_item_widget.dart';
import 'package:curved_labeled_navigation_bar/src/types.dart';
import 'package:flutter/material.dart';

import 'src/nav_custom_painter.dart';

typedef _LetIndexPage = bool Function(int value);

class CurvedNavigationBar extends StatefulWidget {
  /// Defines the appearance of the [CurvedNavigationBarItem] list that are
  /// arrayed within the bottom navigation bar.
  final List<CurvedNavigationBarItem> items;

  /// The index into [items] for the current active [CurvedNavigationBarItem].
  final int index;

  /// The color of the [CurvedNavigationBar] itself, default Colors.white.
  final Color color;

  /// The background color of floating button, default same as [color] attribute.
  final Color? buttonBackgroundColor;

  /// The color of [CurvedNavigationBar]'s background, default Colors.blueAccent.
  final Color backgroundColor;

  /// Called when one of the [items] is tapped.
  final ValueChanged<int>? onTap;

  /// Function which takes page index as argument and returns bool. If function
  /// returns false then page is not changed on button tap. It returns true by
  /// default.
  final _LetIndexPage letIndexChange;

  /// Curves interpolating button change animation, default Curves.easeOut.
  final Curve animationCurve;

  /// Duration of button change animation, default Duration(milliseconds: 600).
  final Duration animationDuration;

  /// Height of [CurvedNavigationBar].
  final double height;

  /// Padding of icon in floating button.
  final double iconPadding;

  /// Check if [CurvedNavigationBar] has label.
  final bool hasLabel;

  final double elevationMainButton;

  final Color? shadowColor;

  final List<Shadow> shadows;

  final AnimtaionsType animtaionsType;

  CurvedNavigationBar({
    Key? key,
    required this.items,
    this.index = 0,
    this.color = Colors.white,
    this.buttonBackgroundColor,
    this.backgroundColor = Colors.blueAccent,
    this.onTap,
    _LetIndexPage? letIndexChange,
    this.animationCurve = Curves.easeOut,
    this.animationDuration = const Duration(milliseconds: 400),
    this.iconPadding = 12.0,
    this.elevationMainButton = 10.0,
    this.shadowColor,
    this.shadows = const <Shadow>[],
    this.animtaionsType = AnimtaionsType.scale,
    double? height,
  })  : assert(items.isNotEmpty),
        assert(0 <= index && index < items.length),
        letIndexChange = letIndexChange ?? ((_) => true),
        height = height ?? (Platform.isAndroid ? 70.0 : 80.0),
        hasLabel = items.any((item) => item.label != null),
        super(key: key);

  @override
  CurvedNavigationBarState createState() => CurvedNavigationBarState();
}

class CurvedNavigationBarState extends State<CurvedNavigationBar>
    with SingleTickerProviderStateMixin {
  late double _startingPos;
  late double _pos;
  late Widget _icon;
  late AnimationController _animationController;
  late int _length;
  int _endingIndex = 0;
  double _buttonHide = 0;

  late int _currentViewIndex = widget.index;
  @override
  void initState() {
    super.initState();
    _icon = widget.items[widget.index].childBuilder(_currentViewIndex, 0);
    _length = widget.items.length;
    _pos = widget.index / _length;
    _startingPos = widget.index / _length;
    _animationController = AnimationController(vsync: this, value: _pos);
    _animationController.addListener(() {
      setState(() {
        _pos = _animationController.value;
        final endingPos = _endingIndex / widget.items.length;
        final middle = (endingPos + _startingPos) / 2;
        if ((endingPos - _pos).abs() < (_startingPos - _pos).abs()) {
          _icon = widget.items[_endingIndex].childBuilder(
            _currentViewIndex,
            _buttonHide,
          );
          _currentViewIndex = _endingIndex;
        }
        _buttonHide =
            (1 - ((middle - _pos) / (_startingPos - middle)).abs()).abs();
      });
    });
  }

  @override
  void didUpdateWidget(CurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final newPosition = widget.index / _length;
      _startingPos = _pos;
      _endingIndex = widget.index;

      _animationController.animateTo(
        newPosition,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: widget.backgroundColor,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          // Selected button
          Positioned(
            bottom: widget.height - 30.0,
            left: Directionality.of(context) == TextDirection.rtl
                ? null
                : _pos * size.width,
            right: Directionality.of(context) == TextDirection.rtl
                ? _pos * size.width
                : null,
            width: size.width / _length,
            child: Center(
              child: AnimatedSwitcher(
                duration: widget.animationDuration * 0.7,
                switchInCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: Material(
                  key: ValueKey(_currentViewIndex),
                  color: widget.buttonBackgroundColor ?? widget.color,
                  type: MaterialType.circle,
                  elevation: widget.elevationMainButton,
                  shadowColor: widget.shadowColor ??
                      Theme.of(context).shadowColor.withOpacity(0.3),
                  child: Padding(
                    padding: EdgeInsets.all(widget.iconPadding),
                    child: _icon,
                  ),
                ),
              ),
            ),
          ),
          // Background
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              painter: NavCustomPainter(
                  startingLoc: _pos,
                  itemsLength: _length,
                  color: widget.color,
                  textDirection: Directionality.of(context),
                  hasLabel: widget.hasLabel,
                  shadows: widget.shadows),
              child: Container(height: widget.height),
            ),
          ),
          // Unselected buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: widget.height,
              child: Row(
                children: widget.items.map((item) {
                  return NavBarItemWidget(
                    onTap: _buttonTap,
                    position: _pos,
                    length: _length,
                    index: widget.items.indexOf(item),
                    labelWidget: item.labelBuilder?.call(_currentViewIndex, 0),
                    child:
                        Center(child: item.childBuilder(_currentViewIndex, 0)),
                    label: item.label,
                    labelStyle: item.labelStyle,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setPage(int index) {
    _buttonTap(index);
  }

  void _buttonTap(int index) {
    if (!widget.letIndexChange(index) || _animationController.isAnimating) {
      return;
    }
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
    final newPosition = index / _length;
    setState(() {
      _startingPos = _pos;
      _endingIndex = index;
      _animationController.animateTo(
        newPosition,
        duration: widget.animationDuration,
        curve: widget.animationCurve,
      );
    });
  }
}
