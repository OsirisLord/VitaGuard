import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../depedency_injection.dart'; // We'll update this
import '../../../auth/presentation/bloc/auth_bloc.dart'; // Get current user
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/diagnosis_result.dart';
import '../../../../core/services/report_service.dart'; // Import
import '../bloc/scan_bloc.dart';

class XrayAnalysisPage extends StatefulWidget {
  const XrayAnalysisPage({super.key});

  @override
  State<XrayAnalysisPage> createState() => _XrayAnalysisPageState();
}

class _XrayAnalysisPageState extends State<XrayAnalysisPage> {
  @override
  Widget build(BuildContext context) {
    // Get current user ID from AuthBloc
    final authState = context.read<AuthBloc>().state;
    String patientId = '';
    if (authState is Authenticated) {
      patientId = authState.user.id;
    }

    return BlocProvider(
      create: (context) => ScanBloc(
        repository: sl(), // Using service locator
        patientId: patientId,
      ),
      child: const _XrayAnalysisView(),
    );
  }
}

class _XrayAnalysisView extends StatelessWidget {
  const _XrayAnalysisView();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null && context.mounted) {
      context.read<ScanBloc>().add(ScanImagePicked(File(pickedFile.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI X-Ray Analysis'),
      ),
      body: BlocConsumer<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state is ScanFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          } else if (state is ScanSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Result saved to history!'), backgroundColor: AppColors.success),
            );
          }
        },
        builder: (context, state) {
          if (state is ScanAnalyzing || state is ScanSaving) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ScanSuccess) {
            return _ResultView(
              result: state.result, 
              image: state.image,
              onSave: () => context.read<ScanBloc>().add(ScanResultSaved(state.result)),
              onRetake: () => context.read<ScanBloc>().add(ScanReset()),
              onGenerateReport: () => _generateReport(context, state.result),
            );
          }

          return _InitialView(
            onCameraTap: () => _pickImage(context, ImageSource.camera),
            onGalleryTap: () => _pickImage(context, ImageSource.gallery),
          );
        },
      ),
    );
  }
  Future<void> _generateReport(BuildContext context, DiagnosisResult result) async {
    // We need current user (patient) and maybe doctor info
    // For now we mock or fetch from auth
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final reportService = sl<ReportService>();
      await reportService.generateDiagnosisReport(
        result, 
        authState.user,
        null, // No verified doctor yet
      );
    }
  }
}

class _InitialView extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const _InitialView({required this.onCameraTap, required this.onGalleryTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.document_scanner_outlined, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Upload Chest X-Ray',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Get instant AI-powered analysis for pneumonia detection',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          _OptionButton(
            icon: Icons.camera_alt,
            label: 'Take Photo',
            onTap: onCameraTap,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          _OptionButton(
            icon: Icons.photo_library,
            label: 'Upload from Gallery',
            onTap: onGalleryTap,
            color: AppColors.secondary,
            isOutlined: true,
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isOutlined;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isOutlined
        ? OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color),
              foregroundColor: color,
            ),
          )
        : ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(icon),
            label: Text(label),
            style: ElevatedButton.styleFrom(backgroundColor: color),
          ),
    );
  }
}

class _ResultView extends StatefulWidget {
  final DiagnosisResult result;
  final File image;
  final VoidCallback onSave;
  final VoidCallback onRetake;
  final VoidCallback onGenerateReport; // Add callback

  const _ResultView({
    required this.result,
    required this.image,
    required this.onSave,
    required this.onRetake,
    required this.onGenerateReport,
  });

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView> {
  bool _showHeatmap = false;

  @override
  Widget build(BuildContext context) {
    // Assuming binary result with thresholds
    final isPositive = widget.result.diagnosis.toLowerCase().contains('pneumonia');
    final color = isPositive ? AppColors.error : AppColors.success;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  widget.image,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (_showHeatmap)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.red.withOpacity(0.3),
                      child: const Center(
                        child: Text(
                          'Heatmap Simulation',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              spacing: 12,
              children: [
                FilterChip(
                  label: const Text('Show Heatmap'),
                  selected: _showHeatmap,
                  onSelected: (value) {
                    setState(() {
                      _showHeatmap = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  isPositive ? Icons.warning : Icons.check_circle,
                  size: 48,
                  color: color,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.result.diagnosis,
                  style: AppTextStyles.h2.copyWith(color: color),
                ),
                Text(
                  'Confidence: ${(widget.result.confidence * 100).toStringAsFixed(1)}%',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          ElevatedButton(
            onPressed: widget.onSave,
            child: const Text('Save Result'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: widget.onGenerateReport,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Generate PDF Report'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.onRetake,
            child: const Text('Start New Scan'),
          ),
        ],
      ),
    );
  }
}
