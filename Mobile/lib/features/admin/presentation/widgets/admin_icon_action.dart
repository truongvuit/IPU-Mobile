import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';






class AdminIconAction extends StatelessWidget {
  const AdminIconAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconSize,
    this.iconColor,
    this.backgroundColor,
    this.tooltip,
    this.useCircleBackground = false,
    this.circleBackgroundColor,
  });

  
  final IconData icon;

  
  final VoidCallback onTap;

  
  final double? iconSize;

  
  final Color? iconColor;

  
  final Color? backgroundColor;

  
  final String? tooltip;

  
  final bool useCircleBackground;

  
  final Color? circleBackgroundColor;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      icon,
      size: iconSize ?? 18.sp,
      color: iconColor,
    );

    
    if (useCircleBackground) {
      iconWidget = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: circleBackgroundColor ?? Colors.black54,
          shape: BoxShape.circle,
        ),
        child: iconWidget,
      );
    }

    Widget child = SizedBox(
      width: 44.w,
      height: 44.h,
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22.r),
          onTap: onTap,
          child: Center(
            child: iconWidget,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      child = Tooltip(
        message: tooltip!,
        child: child,
      );
    }

    return child;
  }
}
