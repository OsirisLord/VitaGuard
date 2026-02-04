import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/vital_sign.dart';
import '../bloc/vital_bloc.dart';

class VitalMonitoringPage extends StatelessWidget {
  const VitalMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VitalBloc(repository: sl()),
      child: const _VitalMonitoringView(),
    );
  }
}

class _VitalMonitoringView extends StatefulWidget {
  const _VitalMonitoringView();

  @override
  State<_VitalMonitoringView> createState() => _VitalMonitoringViewState();
}

class _VitalMonitoringViewState extends State<_VitalMonitoringView> {
  final TextEditingController _ipController =
      TextEditingController(text: '192.168.4.1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Monitoring'),
        actions: [
          BlocBuilder<VitalBloc, VitalState>(
            builder: (context, state) {
              if (state is VitalConnected) {
                return IconButton(
                  icon: const Icon(Icons.link_off),
                  onPressed: () {
                    context.read<VitalBloc>().add(DisconnectVitalDevice());
                  },
                );
              }
              return IconButton(
                icon: const Icon(Icons.link),
                onPressed: () => _showConnectDialog(context),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<VitalBloc, VitalState>(
        builder: (context, state) {
          if (state is VitalConnecting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VitalError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showConnectDialog(context),
                    child: const Text('Retry Connection'),
                  ),
                ],
              ),
            );
          }

          if (state is VitalConnected) {
            return _LiveDashboard(
              current: state.current,
              history: state.history,
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monitor_heart,
                    size: 64, color: AppColors.primary),
                const SizedBox(height: 24),
                const Text('Connect to VitaGuard Device'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showConnectDialog(context),
                  child: const Text('Connect'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showConnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Connect Device'),
        content: TextField(
          controller: _ipController,
          decoration: const InputDecoration(
            labelText: 'Device IP Address',
            hintText: 'e.g. 192.168.4.1',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<VitalBloc>()
                  .add(ConnectVitalDevice(_ipController.text));
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}

class _LiveDashboard extends StatelessWidget {
  final VitalSign current;
  final List<VitalSign> history;

  const _LiveDashboard({required this.current, required this.history});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current Values
        Row(
          children: [
            Expanded(
              child: _VitalCard(
                label: 'SpO2',
                value: '${current.spo2}%',
                icon: Icons.air,
                color: current.spo2 < 90 ? AppColors.error : AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _VitalCard(
                label: 'Heart Rate',
                value: '${current.bpm} BPM',
                icon: Icons.favorite,
                color: current.bpm > 100 || current.bpm < 60
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Charts
        const Text('Oxygen Saturation (SpO2)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: _VitalChart(
            data: history,
            getValue: (v) => v.spo2.toDouble(),
            color: Colors.blue,
            minY: 80,
            maxY: 100,
          ),
        ),

        const SizedBox(height: 24),

        const Text('Heart Rate',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: _VitalChart(
            data: history,
            getValue: (v) => v.bpm.toDouble(),
            color: Colors.red,
            minY: 40,
            maxY: 150,
          ),
        ),
      ],
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _VitalCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _VitalChart extends StatelessWidget {
  final List<VitalSign> data;
  final double Function(VitalSign) getValue;
  final Color color;
  final double minY;
  final double maxY;

  const _VitalChart({
    required this.data,
    required this.getValue,
    required this.color,
    required this.minY,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('No data'));

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(
            show: true, border: Border.all(color: Colors.grey.shade300)),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), getValue(e.value));
            }).toList(),
            isCurved: true,
            color: color,
            dotData: const FlDotData(show: false),
            belowBarData:
                BarAreaData(show: true, color: color.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }
}
