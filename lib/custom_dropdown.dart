import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'dropdown_item.dart';

class CustomDropdown<T> extends StatefulWidget {
  const CustomDropdown({
    super.key,
    required this.children,
    required this.hint,
    required this.onChanged,
  });

  final String? hint;
  final List<DropdownItem<T>> children;
  final ValueChanged<T> onChanged;

  @override
  CustomDropdownState<T> createState() => CustomDropdownState<T>();
}

class CustomDropdownState<T> extends State<CustomDropdown>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  final double _height = 48;

  bool _isDropdownOpened = false;
  OverlayEntry? _overlayEntry;
  DropdownItem<T>? _selectedItem;

  late Animation<double> _iconTurns;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: 200.milliseconds,
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0, end: 0.5).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: AnimatedContainer(
        alignment: Alignment.center,
        height: _height,
        duration: 200.milliseconds,
        curve: Curves.fastOutSlowIn,
        decoration: _buildDropdownDecoration(),
        child: _buildDropdownBody(context),
      ),
    );
  }

  BoxDecoration _buildDropdownDecoration() {
    return BoxDecoration(
      color: _isDropdownOpened ? Colors.blueGrey.shade50 : Colors.grey.shade50,
      borderRadius: _isDropdownOpened
          ? const BorderRadius.only(
              topRight: Radius.circular(12.0),
              topLeft: Radius.circular(12.0),
            )
          : const BorderRadius.all(
              Radius.circular(12.0),
            ),
      border: _isDropdownOpened
          ? null
          : Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
    );
  }

  GestureDetector _buildDropdownBody(BuildContext context) {
    return GestureDetector(
      onTap: () => _dropdownTapped(context),
      child: SizedBox(
        height: _height - 2,
        child: ListTile(
          title: Text(
            _selectedItem == null
                ? widget.hint ?? ''
                : _selectedItem?.value ?? '',
          ),
          titleTextStyle: TextStyle(
            color: _selectedItem != null ? Colors.orange : Colors.grey.shade500,
          ),
          trailing: RotationTransition(
            turns: _iconTurns,
            child: const Icon(
              Icons.expand_more,
              color: Colors.orange,
            ),
          ),
          contentPadding: const EdgeInsets.only(
            left: 16.0,
            right: 8.0,
          ),
        ),
      ),
    );
  }

  void expand({bool refreshState = true}) {
    if (!_isDropdownOpened) {
      _isDropdownOpened = true;
      _controller.forward();
      if (refreshState) {
        setState(() {});
      }
    }
  }

  void collapse({bool refreshState = true}) {
    if (_isDropdownOpened) {
      _isDropdownOpened = false;
      _controller.reverse();
      _overlayEntry?.remove();
      if (refreshState) {
        setState(() {});
      }
    }
  }

  void _dropdownTapped(BuildContext context) {
    if (_isDropdownOpened) {
      _overlayEntry?.remove();
      _controller.reverse();
    } else {
      _controller.forward();
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }

    _isDropdownOpened = !_isDropdownOpened;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height - 1),
          child: Material(
            color: Colors.transparent,
            shadowColor: Colors.black12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(
                    12.0,
                  ),
                  bottomRight: Radius.circular(
                    12.0,
                  ),
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 250,
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 16.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  itemCount: widget.children.length,
                  itemBuilder: (context, index) {
                    return DropdownListItem<T>(
                      item: widget.children[index] as DropdownItem<T>,
                      onSelect: (value) {
                        _selectedItem = value;
                        collapse();

                        widget.onChanged(value.key);
                      },
                    );
                  },
                ),
              ).animate().fadeIn(begin: 0.5, duration: 150.milliseconds).scaleY(
                  begin: 0.5,
                  end: 1,
                  duration: 150.milliseconds,
                  alignment: Alignment.topCenter),
            ),
          ),
        ),
      ),
    );
  }
}

class DropdownListItem<T> extends StatelessWidget {
  final DropdownItem<T> item;
  final ValueChanged<DropdownItem<T>> onSelect;

  const DropdownListItem({
    super.key,
    required this.item,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelect(item),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 8.0,
        ),
        child: Text(
          item.value,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

extension ListExtensions on List {
  T? firstWhereOrNull<T>(bool Function(T element) test,
      {T Function()? orElse}) {
    for (T element in this) {
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();
    return null;
  }
}
