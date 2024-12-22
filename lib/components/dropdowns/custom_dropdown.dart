import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onMenuOpened;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.onMenuOpened,
  });

  @override
  CustomDropdownState createState() => CustomDropdownState();
}

class CustomDropdownState extends State<CustomDropdown> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    if (_isOpen) {
      closeDropdown();
    }
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    
    // Определяем, достаточно ли места внизу экрана
    var screenHeight = MediaQuery.of(context).size.height;
    var bottomSpace = screenHeight - offset.dy - size.height;
    var openUpward = bottomSpace < 200; // changed from 250 to 200

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, openUpward ? -200 : size.height), // changed from -250 to -200
          child: Material(
            elevation: 1,
            borderRadius: BorderRadius.circular(8.0),
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1,
              child: Container(
                constraints: BoxConstraints(maxHeight: 200), 
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey[800],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.items.map((String value) {
                      return InkWell( 
                        onTap: () => _selectItem(value),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    if (_isOpen) {
      closeDropdown();
    } else {
      _overlayEntry = _createOverlayEntry();
      if (mounted) {
        Overlay.of(context).insert(_overlayEntry!);
        setState(() {
          _isOpen = true;
        });
        _animationController.forward();
        if (widget.onMenuOpened != null) {
          widget.onMenuOpened!();
        }
      }
    }
  }

  void _selectItem(String? value) {
    if (mounted) {
      widget.onChanged(value);
      closeDropdown();
    }
  }

  void closeDropdown() {
    if (_isOpen && mounted) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isOpen = false;
          });
          _overlayEntry?.remove();
          _overlayEntry = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            closeDropdown();
          }
        },
        child: GestureDetector(
          onTap: _toggleDropdown, // Simplified tap handler
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[800],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.value,
                  style: TextStyle(color: Colors.white),
                ),
                Icon(
                  _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}