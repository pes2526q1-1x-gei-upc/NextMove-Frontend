import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextmove_app/l10n/app_localizations.dart';
import 'package:nextmove_app/src/core/theme/app_theme.dart';
import 'package:nextmove_app/src/funcionalidades/estaciones/dominio/station_model.dart';
import 'package:nextmove_app/src/funcionalidades/mapa/data/dataproviders/bike_detection_provider.dart';
import 'package:nextmove_app/src/core/errors/exceptions.dart' as custom_exceptions;

class NavigationCompletedScreen extends StatefulWidget {
  final VoidCallback onClose;
  final StationType currentMode;

  const NavigationCompletedScreen({
    super.key,
    required this.onClose,
    required this.currentMode,
  });

  @override
  State<NavigationCompletedScreen> createState() => _NavigationCompletedScreenState();
}

class _NavigationCompletedScreenState extends State<NavigationCompletedScreen> {
  final ImagePicker _picker = ImagePicker();
  final BikeDetectionProvider _bikeDetectionProvider = BikeDetectionProvider();
  File? _selectedImage;
  bool _isValidating = false;
  bool? _isValidBike; // null = no validado, true = válido, false = inválido

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _selectedImage = imageFile;
          _isValidBike = null; // Reset validation state
        });
        
        // Validar la imagen automáticamente
        await _validateBikeImage(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.imagePickerError),
          ),
        );
      }
    }
  }

  Future<void> _validateBikeImage(File imageFile) async {
    setState(() {
      _isValidating = true;
      _isValidBike = null;
    });

    try {
      final isValid = await _bikeDetectionProvider.detectBike(imageFile);
      
      if (mounted) {
        setState(() {
          _isValidating = false;
          _isValidBike = isValid;
        });

        if (isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.bikePhotoAccepted,
              ),
              backgroundColor: AppTheme.seedColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.bikePhotoRejected,
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _isValidBike = false;
        });

        String errorMessage;
        if (e is custom_exceptions.ServerException) {
          errorMessage = e.message!;
        } else {
          errorMessage = AppLocalizations.of(context)!.bikeDetectionError;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final isBikeMode = widget.currentMode == StationType.bicycle;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? theme.scaffoldBackgroundColor : theme.scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono de éxito con animación
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.seedColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 80,
                        color: AppTheme.seedColor,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Título
                    Text(
                      l10n.recordCompleted,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Mensaje descriptivo
                    Text(
                      l10n.recordCompletedMessage,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    // Sección de imagen (solo para modo bici)
                    if (isBikeMode) ...[
                      const SizedBox(height: 32),
                      
                      // Mensaje de puntos extra
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.seedColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.seedColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              color: AppTheme.seedColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.uploadBikePhotoPoints,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Área de imagen
                      GestureDetector(
                        onTap: _isValidating ? null : _pickImageFromCamera,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: isDark 
                                  ? theme.cardColor 
                                  : Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isValidating
                                    ? Colors.blue
                                    : _isValidBike == true
                                      ? AppTheme.seedColor
                                      : _isValidBike == false
                                        ? Colors.orange
                                        : _selectedImage != null
                                          ? AppTheme.seedColor
                                          : (isDark 
                                              ? Colors.white.withValues(alpha: 0.2)
                                              : Colors.grey[300]!),
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: _selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Stack(
                                      children: [
                                        Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                        if (_isValidating)
                                          Container(
                                            color: Colors.black.withValues(alpha: 0.5),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const CircularProgressIndicator(
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    l10n.validatingPhoto,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_rounded,
                                        size: 48,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        l10n.tapToTakePhoto,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                            // Indicador de estado de validación
                            if (_selectedImage != null && !_isValidating && _isValidBike != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _isValidBike == true
                                      ? AppTheme.seedColor
                                      : Colors.orange,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isValidBike == true
                                          ? Icons.check_circle
                                          : Icons.error,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isValidBike == true
                                          ? l10n.valid
                                          : l10n.invalid,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 48),
                    
                    // Botón de cerrar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.seedColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.close,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

