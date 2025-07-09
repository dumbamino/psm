// lib/screens/record_details.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psm/service/records.dart'; // Make sure this path is correct

class RecordDetailScreen extends StatelessWidget {
  final Record record;

  const RecordDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    // Define date formatters for consistent display
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy'); // e.g., 19 September 2024
    final DateFormat dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a'); // e.g., 13 Jun 2025, 05:37 PM

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Details'),
        backgroundColor: Colors.green.shade50,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main deceased name as a prominent header
            Text(
              record.deceasedName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),

            // Deceased Information Section
            _buildSectionHeader(context, 'Deceased Information'),
            _buildDetailCard(
              children: [
                _buildDetailRow('Date of Death:', record.deceasedDod != null ? dateFormat.format(record.deceasedDod!.toDate()) : 'N/A'),
                _buildDetailRow('Date of Birth:', record.deceasedDob != null ? dateFormat.format(record.deceasedDob!.toDate()) : 'N/A'),
                _buildDetailRow('Category:', record.category ?? 'N/A'),
                _buildDetailRow('Relationship:', record.relationshipToDeceased ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 24),

            // Grave Information Section
            _buildSectionHeader(context, 'Grave Information'),
            _buildDetailCard(
              children: [
                _buildDetailRow('Lot / Plot:', record.graveLot ?? 'N/A'),
                _buildDetailRow('Address:', record.graveAddress ?? 'N/A'),
                _buildDetailRow('Area:', record.area),
                _buildDetailRow('State:', record.state ?? 'N/A'),
                if (record.position != null) // Only show if location data exists
                  _buildDetailRow('Coordinates:', 'Lat: ${record.position!.latitude.toStringAsFixed(6)}, Lng: ${record.position!.longitude.toStringAsFixed(6)}'),
              ],
            ),
            const SizedBox(height: 24),

            // Record Metadata Section
            _buildSectionHeader(context, 'Record Metadata'),
            _buildDetailCard(
              children: [
                _buildDetailRow('Created By:', record.userEmail ?? 'N/A'),
                _buildDetailRow('Created On:', record.createdAt != null ? dateTimeFormat.format(record.createdAt!.toDate()) : 'N/A'),
                _buildDetailRow('Last Updated:', record.updatedAt != null ? dateTimeFormat.format(record.updatedAt!.toDate()) : 'N/A'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to create a consistent section header style
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Helper widget to create a styled container for details
  Widget _buildDetailCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  // Helper widget to create a consistent "Label: Value" row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110, // Fixed width for labels to align values
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}