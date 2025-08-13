import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// Optimized ListView with performance improvements
class OptimizedListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;

  const OptimizedListView({
    super.key,
    required this.children,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      shrinkWrap: shrinkWrap,
      controller: controller,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: children[index],
        );
      },
    );
  }
}

/// Optimized GridView with performance improvements
class OptimizedGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;
  final double? childAspectRatio;
  final double? mainAxisExtent;

  const OptimizedGridView({
    super.key,
    required this.children,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
    this.childAspectRatio,
    this.mainAxisExtent,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      shrinkWrap: shrinkWrap,
      controller: controller,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio ?? 1.0,
        mainAxisExtent: mainAxisExtent,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: children[index],
        );
      },
    );
  }
}

/// Optimized StaggeredGridView with performance improvements
class OptimizedStaggeredGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  const OptimizedStaggeredGridView({
    super.key,
    required this.children,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      shrinkWrap: shrinkWrap,
      controller: controller,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: children[index],
        );
      },
    );
  }
}

/// Optimized ScrollView with performance improvements
class OptimizedScrollView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool? primary;
  final bool reverse;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  const OptimizedScrollView({
    super.key,
    required this.children,
    this.padding,
    this.physics,
    this.controller,
    this.primary,
    this.reverse = false,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      controller: controller,
      primary: primary,
      reverse: reverse,
      // shrinkWrap parameter removed as it's not needed for SingleChildScrollView
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      child: Column(
        children:
            children.map((child) => RepaintBoundary(child: child)).toList(),
      ),
    );
  }
}

/// Optimized Lazy Loading Widget
class OptimizedLazyLoadingWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Widget? placeholder;

  const OptimizedLazyLoadingWidget({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 100),
    this.placeholder,
  });

  @override
  State<OptimizedLazyLoadingWidget> createState() =>
      _OptimizedLazyLoadingWidgetState();
}

class _OptimizedLazyLoadingWidgetState
    extends State<OptimizedLazyLoadingWidget> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadWithDelay();
  }

  void _loadWithDelay() {
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return widget.child;
    }
    return widget.placeholder ?? const SizedBox.shrink();
  }
}

/// Optimized Image Widget with caching
class OptimizedImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width?.toInt(),
        cacheHeight: height?.toInt(),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const Icon(Icons.error);
        },
      ),
    );
  }
}
