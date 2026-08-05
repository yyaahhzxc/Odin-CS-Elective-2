import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/airplane_painters.dart';
import '../widgets/boarding_pass_ticket.dart';
import '../widgets/web_navbar.dart';

class WebFlightDashboard extends StatefulWidget {
  const WebFlightDashboard({super.key});

  @override
  State<WebFlightDashboard> createState() => _WebFlightDashboardState();
}

class _WebFlightDashboardState extends State<WebFlightDashboard> {
  bool isRoundTrip = true;
  int selectedFlightIndex = 0;

  final List<Map<String, String>> flights = [
    {
      'fromCity': 'Los Angeles',
      'fromCode': 'SFO',
      'fromTime': '21.30',
      'fromDate': 'Sat-27 August',
      'toCity': 'Los Angeles',
      'toCode': 'NYC',
      'toTime': '21.30',
      'toDate': 'Sat-10 September',
      'price': 'IDR 1.500.000',
      'seat': 'F1',
    },
    {
      'fromCity': 'Los Angeles',
      'fromCode': 'NYC',
      'fromTime': '21.30',
      'fromDate': 'Sat-10 August',
      'toCity': 'Los Angeles',
      'toCode': 'SFO',
      'toTime': '21.30',
      'toDate': 'Sat-11 September',
      'price': 'IDR 1.750.000',
      'seat': 'B3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedFlight = flights[selectedFlightIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    // 2-column side-by-side only when width >= 980px
    final isSideBySide = screenWidth >= 1050;

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: Column(
        children: [
          // Top Web Navbar
          const WebNavbar(),

          // Dashboard Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 700 ? 32 : 16,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isSideBySide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Search Column (58%)
                            Expanded(
                              flex: 58,
                              child: _buildSearchSection(context),
                            ),
                            const SizedBox(width: 32),
                            // Right Ticket Column (42%)
                            Expanded(
                              flex: 42,
                              child: _buildTicketPreviewSection(context, selectedFlight),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stacked Single Column for Tablet / Small Web
                            _buildSearchSection(context),
                            const SizedBox(height: 36),
                            _buildTicketPreviewSection(context, selectedFlight),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Left Flight Search Section
  Widget _buildSearchSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Card (Always vertical layout inside card to prevent overflow)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.tealBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.tealDark.withAlpha(40),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                top: -20,
                width: 240,
                height: 180,
                child: CustomPaint(
                  painter: AirplaneWatermarkPainter(
                    color: Colors.white.withAlpha(25),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CHOOSE YOUR FLIGHT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select your route and preview your live booking pass',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 220,
                      child: _buildSegmentedToggle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        const Text(
          'Available Flights',
          style: TextStyle(
            color: AppColors.tealDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // Flight Selection List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: flights.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = flights[index];
            final isSelected = selectedFlightIndex == index;

            return GestureDetector(
              onTap: () => setState(() => selectedFlightIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppColors.tealPrimary : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.tealPrimary.withAlpha(25)
                          : Colors.black.withAlpha(8),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Radio button
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppColors.tealPrimary : AppColors.textGrey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),

                    // Origin City
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['fromCity']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 10),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item['fromCode']!,
                              maxLines: 1,
                              softWrap: false,
                              style: const TextStyle(color: AppColors.tealDark, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(item['fromTime']!, style: const TextStyle(color: AppColors.textGrey, fontSize: 10)),
                          if (item['fromDate']!.isNotEmpty)
                            Text(
                              item['fromDate']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.tealDark, fontSize: 9, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),

                    // Trajectory Arrow
                    SizedBox(
                      width: 44,
                      height: 32,
                      child: CustomPaint(
                        painter: FlightTrajectoryPainter(
                          color: AppColors.tealLight,
                          isReturn: index == 1,
                        ),
                      ),
                    ),

                    // Destination City
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['toCity']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 10),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              item['toCode']!,
                              maxLines: 1,
                              softWrap: false,
                              style: const TextStyle(color: AppColors.tealDark, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(item['toTime']!, style: const TextStyle(color: AppColors.textGrey, fontSize: 10)),
                          if (item['toDate']!.isNotEmpty)
                            Text(
                              item['toDate']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.tealDark, fontSize: 9, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Price badge
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.tealPrimary : AppColors.screenBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item['price']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.tealDark,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Right Live Ticket Section
  Widget _buildTicketPreviewSection(BuildContext context, Map<String, String> selectedFlight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Live Boarding Pass',
              style: TextStyle(
                color: AppColors.tealDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Chip(
                  backgroundColor: AppColors.accentCream,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    'Ready for Boarding',
                    style: TextStyle(color: AppColors.tealDark, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Live Ticket Card
        BoardingPassTicketCard(
          passengerName: 'ALFHARIZKY FAUZI',
          originCode: selectedFlight['fromCode']!,
          destinationCode: selectedFlight['toCode']!,
          originTime: selectedFlight['fromTime']!,
          destinationTime: selectedFlight['toTime']!,
          departureDate: selectedFlight['toDate']!.isNotEmpty ? selectedFlight['toDate']! : 'Sat-27 August',
          ticketPrice: selectedFlight['price']!,
          seat: selectedFlight['seat']!,
        ),

        const SizedBox(height: 20),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ticket pass printed successfully!')),
                  );
                },
                icon: const Icon(Icons.print_rounded, size: 16),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('PRINT PASS'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealBackground,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pass downloaded to device.')),
                );
              },
              icon: const Icon(Icons.download_rounded, size: 16, color: AppColors.tealDark),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('DOWNLOAD', style: TextStyle(color: AppColors.tealDark)),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                side: const BorderSide(color: AppColors.tealPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Segmented Toggle Pill
  Widget _buildSegmentedToggle() {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isRoundTrip = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isRoundTrip ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'ROUND TRIP',
                  style: TextStyle(
                    color: isRoundTrip ? AppColors.tealDark : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isRoundTrip = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isRoundTrip ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'ONE WAY',
                  style: TextStyle(
                    color: !isRoundTrip ? AppColors.tealDark : Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
