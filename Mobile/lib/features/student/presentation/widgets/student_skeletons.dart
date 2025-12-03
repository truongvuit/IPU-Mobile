import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/constants/app_sizes.dart';


class StudentSkeletons {
  StudentSkeletons._();

  
  static Widget courseCard({bool isDesktop = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: SkeletonWidget.rectangular(
        height: isDesktop ? 280.h : 240.h,
        borderRadius: AppSizes.radiusMedium,
      ),
    );
  }

  
  static Widget classItem() {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: SkeletonWidget.rectangular(
        height: 120.h,
        borderRadius: AppSizes.radiusMedium,
      ),
    );
  }

  
  static Widget scheduleItem() {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: SkeletonWidget.rectangular(
        height: 80.h,
        borderRadius: AppSizes.radiusMedium,
      ),
    );
  }

  
  static Widget gradeItem() {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: SkeletonWidget.rectangular(
        height: 90.h,
        borderRadius: AppSizes.radiusMedium,
      ),
    );
  }

  
  static Widget list({
    required Widget Function() itemBuilder,
    int itemCount = 5,
    EdgeInsets? padding,
  }) {
    return ListView.builder(
      padding: padding ?? EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(),
    );
  }

  
  static Widget grid({
    required Widget Function() itemBuilder,
    int itemCount = 6,
    int crossAxisCount = 2,
    EdgeInsets? padding,
  }) {
    return GridView.builder(
      padding: padding ?? EdgeInsets.all(AppSizes.paddingMedium),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSizes.paddingMedium,
        crossAxisSpacing: AppSizes.paddingMedium,
        childAspectRatio: 0.75,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(),
    );
  }

  
  static Widget dashboard({bool isDesktop = false}) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonWidget.rectangular(
            height: 24.h,
            width: 200.w,
            borderRadius: AppSizes.radiusSmall,
          ),
          SizedBox(height: AppSizes.paddingMedium),
          SkeletonWidget.rectangular(
            height: 120.h,
            borderRadius: AppSizes.radiusMedium,
          ),
          SizedBox(height: AppSizes.paddingMedium),
          SkeletonWidget.rectangular(
            height: 24.h,
            width: 200.w,
            borderRadius: AppSizes.radiusSmall,
          ),
          SizedBox(height: AppSizes.paddingMedium),
          ...List.generate(3, (index) => classItem()),
        ],
      ),
    );
  }
}
