import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Botão animado de busca de filme
class AnimatedSearchButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double size;

  const AnimatedSearchButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.size = 180,
  });

  @override
  State<AnimatedSearchButton> createState() => _AnimatedSearchButtonState();
}

class _AnimatedSearchButtonState extends State<AnimatedSearchButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animação de pulso contínuo
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animação de rotação durante loading
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animação de escala ao pressionar
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedSearchButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _rotationController.repeat();
      _pulseController.stop();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _rotationController.stop();
      _rotationController.reset();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _scaleController.reverse();
      widget.onPressed();
    }
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _scaleAnimation,
          _rotationController,
        ]),
        builder: (context, child) {
          final scale = widget.isLoading
              ? 1.0
              : _pulseAnimation.value * _scaleAnimation.value;

          return Transform.scale(
            scale: scale,
            child: _buildButton(),
          );
        },
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.isEnabled
            ? AppColors.primaryGradient
            : LinearGradient(
                colors: [
                  AppColors.surface,
                  AppColors.surfaceLight,
                ],
              ),
        boxShadow: widget.isEnabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ]
            : AppShadows.medium,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anéis externos animados
          if (widget.isEnabled && !widget.isLoading) ...[
            _buildRing(widget.size + 20, 0.3),
            _buildRing(widget.size + 40, 0.15),
          ],
          
          // Borda interna
          Container(
            width: widget.size - 8,
            height: widget.size - 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
          ),

          // Conteúdo central
          widget.isLoading ? _buildLoadingContent() : _buildIdleContent(),
        ],
      ),
    );
  }

  Widget _buildRing(double size, double opacity) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: size * _pulseAnimation.value,
          height: size * _pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(opacity),
              width: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildIdleContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.movie_filter,
          size: widget.size * 0.25,
          color: Colors.white,
        ),
        const SizedBox(height: 8),
        Text(
          'DESCOBRIR',
          style: TextStyle(
            fontSize: widget.size * 0.085,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        Text(
          'FILME',
          style: TextStyle(
            fontSize: widget.size * 0.07,
            fontWeight: FontWeight.w300,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: child,
        );
      },
      child: SizedBox(
        width: widget.size * 0.4,
        height: widget.size * 0.4,
        child: CircularProgressIndicator(
          strokeWidth: 4,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }
}
