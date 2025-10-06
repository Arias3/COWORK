import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/evaluacion_periodo.dart';
import '../../../activities/domain/entities/activity.dart';

class EvaluacionDetalleSimplePage extends StatelessWidget {
  final EvaluacionPeriodo evaluacion;
  final Activity activity;

  const EvaluacionDetalleSimplePage({
    Key? key,
    required this.evaluacion,
    required this.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Evaluación'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEstadoEvaluacion(),
            SizedBox(height: 20),
            _buildInformacionBasica(),
            SizedBox(height: 20),
            _buildAccionesDisponibles(),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoEvaluacion() {
    Color statusColor = _getStatusColor(evaluacion.estado);
    IconData statusIcon = _getStatusIcon(evaluacion.estado);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado de la Evaluación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 24),
                SizedBox(width: 8),
                Text(
                  evaluacion.estado.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              evaluacion.titulo,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (evaluacion.descripcion != null) ...[
              SizedBox(height: 8),
              Text(
                evaluacion.descripcion!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionBasica() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Básica',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildInfoRow('Actividad', activity.nombre),
            _buildInfoRow('Actividad Descripción', activity.descripcion),
            _buildInfoRow(
              'Fecha de Inicio',
              _formatDate(evaluacion.fechaInicio),
            ),
            if (evaluacion.fechaFin != null)
              _buildInfoRow('Fecha de Fin', _formatDate(evaluacion.fechaFin!)),
            _buildInfoRow(
              'Evaluación entre Pares',
              evaluacion.evaluacionEntrePares ? 'Sí' : 'No',
            ),
            _buildInfoRow(
              'Puntuación Máxima',
              '${evaluacion.puntuacionMaxima}/5.0',
            ),
            _buildInfoRow(
              'Comentarios Habilitados',
              evaluacion.habilitarComentarios ? 'Sí' : 'No',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildAccionesDisponibles() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            if (evaluacion.estado == EstadoEvaluacionPeriodo.pendiente) ...[
              ElevatedButton.icon(
                onPressed: _activarEvaluacion,
                icon: Icon(Icons.play_arrow),
                label: Text('Activar Evaluación'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back),
              label: Text('Volver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _activarEvaluacion() {
    Get.snackbar(
      'Funcionalidad en Desarrollo',
      'La activación de evaluaciones estará disponible pronto',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Color _getStatusColor(EstadoEvaluacionPeriodo estado) {
    switch (estado) {
      case EstadoEvaluacionPeriodo.pendiente:
        return Colors.orange;
      case EstadoEvaluacionPeriodo.activo:
        return Colors.green;
      case EstadoEvaluacionPeriodo.finalizado:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(EstadoEvaluacionPeriodo estado) {
    switch (estado) {
      case EstadoEvaluacionPeriodo.pendiente:
        return Icons.pending;
      case EstadoEvaluacionPeriodo.activo:
        return Icons.play_circle;
      case EstadoEvaluacionPeriodo.finalizado:
        return Icons.check_circle;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
