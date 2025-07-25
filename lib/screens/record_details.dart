// lib/screens/record_details.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:psm/pages/navigation_page.dart';
import 'package:psm/service/records.dart';

import '../pages/notificationpage.dart';

class RecordDetailScreen extends StatelessWidget {
  final Record record;

  const RecordDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy');
    final DateFormat dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Record Details'),
        backgroundColor: AppColors.primary.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Metamorphous',
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: AppColors.textPrimary,
          letterSpacing: 0.8,
          shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Stack(
        children: [
          // Background image with dark overlay (like ProfileScreen)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage("assets/images/al-marhum/islamicbackground.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.85),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Header
                Text(
                  record.deceasedName,
                  style: const TextStyle(
                    fontFamily: 'Metamorphous',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.accent.withOpacity(0.6), thickness: 2),
                const SizedBox(height: 24),

                // Sections
                _buildSectionHeader(context, 'Deceased Information'),
                _buildDetailCard(context, [
                  _buildDetailRow(
                      'Date of Death',
                      record.deceasedDod != null
                          ? dateFormat.format(record.deceasedDod!.toDate())
                          : 'N/A'),
                  _buildDetailRow(
                      'Date of Birth',
                      record.deceasedDob != null
                          ? dateFormat.format(record.deceasedDob!.toDate())
                          : 'N/A'),
                  _buildDetailRow('Category', record.category ?? 'N/A'),
                  _buildDetailRow(
                      'Relationship', record.relationshipToDeceased ?? 'N/A'),
                ]),
                const SizedBox(height: 32),

                _buildSectionHeader(context, 'Grave Information'),
                _buildDetailCard(context, [
                  _buildDetailRow('Lot / Plot', record.graveLot ?? 'N/A'),
                  _buildDetailRow('Address', record.graveAddress ?? 'N/A'),
                  _buildDetailRow('Area', record.area),
                  _buildDetailRow('State', record.state ?? 'N/A'),
                  if (record.position != null)
                    _buildDetailRow('Coordinates',
                        'Lat: ${record.position!.latitude.toStringAsFixed(6)}, Lng: ${record.position!.longitude.toStringAsFixed(6)}'),
                ]),
                const SizedBox(height: 32),

                _buildSectionHeader(context, 'Record Metadata'),
                _buildDetailCard(context, [
                  _buildDetailRow('Created By', record.userEmail ?? 'N/A'),
                  _buildDetailRow(
                      'Created On',
                      record.createdAt != null
                          ? dateTimeFormat.format(record.createdAt!.toDate())
                          : 'N/A'),
                  _buildDetailRow(
                      'Last Updated',
                      record.updatedAt != null
                          ? dateTimeFormat.format(record.updatedAt!.toDate())
                          : 'N/A'),
                ]),
                if (record.position != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NavigationPage(
                                destination: LatLng(
                                  record.position!.latitude,
                                  record.position!.longitude,
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Navigate to Grave'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 8,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.7,
                            fontFamily: 'Metamorphous',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Metamorphous',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
          shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Metamorphous',
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.textPrimary,
                shadows: [Shadow(blurRadius: 2, color: Colors.black45)],
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
