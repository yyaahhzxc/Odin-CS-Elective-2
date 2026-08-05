import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'airplane_painters.dart';
import 'barcode_painter.dart';

class BoardingPassTicketCard extends StatelessWidget {
  final String passengerName;
  final String originCode;
  final String destinationCode;
  final String originTime;
  final String destinationTime;
  final String departureDate;
  final String ticketPrice;
  final String seat;
  final String flightClass;
  final String gate;
  final String baggage;

  const BoardingPassTicketCard({
    super.key,
    this.passengerName = 'ALFHARIZKY FAUZI',
    this.originCode = 'SFO',
    this.destinationCode = 'NYC',
    this.originTime = '21.30',
    this.destinationTime = '21.30',
    this.departureDate = 'Sat-10 September',
    this.ticketPrice = 'IDR 1.500.000',
    this.seat = 'F1',
    this.flightClass = 'Economy',
    this.gate = '31',
    this.baggage = '2×15 kg',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Route Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.tealBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Los Angeles', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(originCode, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Text(originTime, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 44,
                  height: 28,
                  child: CustomPaint(
                    painter: FlightTrajectoryPainter(color: Colors.white70),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Los Angeles', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(destinationCode, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Text(destinationTime, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(departureDate, style: const TextStyle(color: AppColors.accentCream, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Ticket Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Airplane Vector Art
                SizedBox(
                  width: 80,
                  height: 60,
                  child: CustomPaint(
                    painter: AirplaneLineArtPainter(
                      color: AppColors.tealPrimary,
                      strokeWidth: 2.0,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Passenger Name
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Passenger',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          passengerName,
                          style: const TextStyle(
                            color: AppColors.tealDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                const SizedBox(height: 14),

                // Row 1: Ticket Price & Seat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildInfoColumn('Ticket Price', ticketPrice, isHighlighted: true)),
                    Expanded(child: _buildInfoColumn('Seat', seat, alignRight: true)),
                  ],
                ),

                const SizedBox(height: 16),

                // Row 2: Class, Gate, Baggage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildInfoColumn('Class', flightClass)),
                    Expanded(child: _buildInfoColumn('Gate', gate, alignCenter: true)),
                    Expanded(child: _buildInfoColumn('Baggage', baggage, alignRight: true)),
                  ],
                ),

                const SizedBox(height: 28),

                // BOOKING PASS & Barcode
                const Text(
                  'BOOKING PASS',
                  style: TextStyle(
                    color: AppColors.tealDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 8),

                const BarcodeWidget(height: 40, color: AppColors.textDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isHighlighted = false, bool alignRight = false, bool alignCenter = false}) {
    CrossAxisAlignment crossAlign = CrossAxisAlignment.start;
    Alignment textFitAlign = Alignment.centerLeft;
    if (alignRight) {
      crossAlign = CrossAxisAlignment.end;
      textFitAlign = Alignment.centerRight;
    } else if (alignCenter) {
      crossAlign = CrossAxisAlignment.center;
      textFitAlign = Alignment.center;
    }

    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: textFitAlign,
          child: Text(
            value,
            style: TextStyle(
              color: isHighlighted ? AppColors.tealPrimary : AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
