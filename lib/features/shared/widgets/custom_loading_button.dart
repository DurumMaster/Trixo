import 'package:flutter/material.dart';
import 'package:trixo_frontend/config/theme/app_colors.dart';

class MUILoadingButton extends StatefulWidget {
  const MUILoadingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loadingStateText = '',
    this.borderRadius = 12.0,
    this.animationDuration = 250,
    this.hapticsEnabled = false,
    this.widthFactorUnpressed = 0.04,
    this.widthFactorPressed = 0.035,
    this.heightFactorUnPressed = 0.03,
    this.heightFactorPressed = 0.025,
    this.maxHorizontalPadding = 50,
    this.leadingIcon,
    this.actionIcon,
    this.boxShadows,
  });

  final String text;
  final Future<void> Function()? onPressed;
  final String loadingStateText;
  final double borderRadius;
  final int animationDuration;
  final bool hapticsEnabled;
  final double widthFactorUnpressed;
  final double widthFactorPressed;
  final double heightFactorPressed;
  final double heightFactorUnPressed;
  final double maxHorizontalPadding;
  final IconData? leadingIcon;
  final IconData? actionIcon;
  final List<BoxShadow>? boxShadows;

  @override
  State<MUILoadingButton> createState() => _MUILoadingButtonState();
}

class _MUILoadingButtonState extends State<MUILoadingButton> {
  bool _isLoadingButtonPressed = false;

  void _startLoading() {
    if (!mounted) return;
    setState(() {
      _isLoadingButtonPressed = true;
    });
  }

  void _stopLoading() {
    if (!mounted) return;
    setState(() {
      _isLoadingButtonPressed = false;
    });
  }

  double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) async {
        if (widget.onPressed == null) return;
        _startLoading();
        try {
          await widget.onPressed!();
        } finally {
          _stopLoading();
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: widget.animationDuration),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: AppColors.white, width: 1.5),
          boxShadow: widget.boxShadows ??
              [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: _isLoadingButtonPressed
              ? getScreenWidth(context) * widget.widthFactorPressed
              : getScreenWidth(context) * widget.widthFactorUnpressed,
          vertical: _isLoadingButtonPressed
              ? getScreenWidth(context) * widget.heightFactorPressed
              : getScreenWidth(context) * widget.heightFactorUnPressed,
        ).clamp(
          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          EdgeInsets.symmetric(
              horizontal: widget.maxHorizontalPadding, vertical: 16),
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: widget.animationDuration),
          child: !_isLoadingButtonPressed
              ? Row(
                  key: const ValueKey('buttonText'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.leadingIcon != null)
                      Icon(
                        widget.leadingIcon,
                        color: AppColors.white,
                        size: 18,
                      ),
                    if (widget.leadingIcon != null) const SizedBox(width: 8),
                    Text(
                      widget.text,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.actionIcon != null) const SizedBox(width: 8),
                    if (widget.actionIcon != null)
                      Icon(
                        widget.actionIcon,
                        color: AppColors.white,
                        size: 18,
                      ),
                  ],
                )
              : Row(
                  key: const ValueKey('loadingState'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      width: 18,
                      height: 18,
                      child: const CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    Text(
                      widget.loadingStateText.isNotEmpty
                          ? widget.loadingStateText
                          : 'Cargando...',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
