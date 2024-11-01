import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:travel_on_final/features/search/domain/entities/travel_package.dart';

class ReservationCalendarScreen extends StatefulWidget {
  final TravelPackage package;

  const ReservationCalendarScreen({
    Key? key,
    required this.package,
  }) : super(key: key);

  @override
  State<ReservationCalendarScreen> createState() => _ReservationCalendarScreenState();
}

class _ReservationCalendarScreenState extends State<ReservationCalendarScreen> {
  // 상태 변수들
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  Map<String, bool> _availabilityCache = {};
  bool _isLoading = false;
  late int _selectedParticipants;
  late final int _minParticipants;
  late final int _maxParticipants;

  @override
  void initState() {
    super.initState();
    _minParticipants = widget.package.minParticipants;
    _maxParticipants = widget.package.maxParticipants;
    assert(widget.package.minParticipants > 0, 'Invalid minimum participants');
    _selectedParticipants = widget.package.minParticipants;
    _preloadAvailability();
  }

  // 헬퍼 메서드
  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  bool _isValidDepartureDay(DateTime date) {
    return widget.package.departureDays.contains(date.weekday);
  }

  // 가용성 로딩
  Future<void> _preloadAvailability() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final start = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final end = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      final snapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('packageId', isEqualTo: widget.package.id)
          .where('status', isEqualTo: 'approved')
          .get();

      final approvedDates = snapshot.docs.map((doc) =>
          (doc.data()['reservationDate'] as Timestamp).toDate()
      ).toList();

      if (mounted) {
        setState(() {
          for (var date = start;
          date.isBefore(end.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
            if (!date.isBefore(now)) {
              final dateKey = _getDateKey(date);
              final hasApprovedReservation = approvedDates.any((approvedDate) =>
              approvedDate.year == date.year &&
                  approvedDate.month == date.month &&
                  approvedDate.day == date.day
              );
              _availabilityCache[dateKey] = !hasApprovedReservation;
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // UI 빌더 메서드
  Widget _buildParticipantSelector() {
    // widget.package.minParticipants 대신 _minParticipants 사용
    if (_selectedParticipants < _minParticipants) {
      _selectedParticipants = _minParticipants;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '인원 선택',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 여기도 저장된 변수 사용
              Text('$_minParticipants명 ~ $_maxParticipants명'),
              Row(
                children: [
                  IconButton(
                    // 여기도 수정
                    onPressed: _selectedParticipants > _minParticipants
                        ? () {
                      setState(() {
                        final newValue = _selectedParticipants - 1;
                        if (newValue >= _minParticipants) {
                          _selectedParticipants = newValue;
                        }
                      });
                    }
                        : null,
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: _selectedParticipants > _minParticipants
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                  Text(
                    '$_selectedParticipants명',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    // 여기도 수정
                    onPressed: _selectedParticipants < _maxParticipants
                        ? () {
                      setState(() {
                        _selectedParticipants++;
                      });
                    }
                        : null,
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: _selectedParticipants < _maxParticipants
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 예약 처리
  void _requestReservation(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final reservationProvider = context.read<ReservationProvider>();

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      context.push('/login');
      return;
    }

    if (_selectedParticipants < _minParticipants) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최소 $_minParticipants명 이상 선택해주세요')),
      );
      return;
    }

    if (_selectedParticipants > _maxParticipants) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('최대 $_maxParticipants명까지 선택 가능합니다')),
      );
      return;
    }

    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('날짜를 선택해주세요')),
      );
      return;
    }

    if (_selectedParticipants < widget.package.minParticipants ||
        _selectedParticipants > widget.package.maxParticipants) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 인원을 선택해주세요')),
      );
      return;
    }

    try {
      await reservationProvider.createReservation(
        packageId: widget.package.id,
        packageTitle: widget.package.title,
        customerId: authProvider.currentUser!.id,
        customerName: authProvider.currentUser!.name,
        guideName: widget.package.guideName,
        guideId: widget.package.guideId,
        reservationDate: _selectedDay!,
        price: widget.package.price,
        participants: _selectedParticipants,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('예약이 신청되었습니다')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('예약 신청 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 날짜 선택'),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(),
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            enabledDayPredicate: (day) {
              if (day.isBefore(DateTime.now())) return false;
              if (!_isValidDepartureDay(day)) return false;
              final dateKey = _getDateKey(day);
              return _availabilityCache[dateKey] ?? true;
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (selectedDay.isBefore(DateTime.now())) return;

              if (!_isValidDepartureDay(selectedDay)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('선택할 수 없는 출발일입니다')),
                );
                return;
              }

              final dateKey = _getDateKey(selectedDay);
              final isAvailable = _availabilityCache[dateKey] ?? true;

              if (isAvailable) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('선택한 날짜는 예약이 마감되었습니다')),
                  );
                }
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _availabilityCache.clear();
              });
              _preloadAvailability();
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                bool isDepartureDay = _isValidDepartureDay(date);
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDepartureDay ? Colors.blue.shade50 : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isDepartureDay && !date.isBefore(DateTime.now())
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
              selectedBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              disabledBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white),
              todayDecoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: Colors.blue),
              disabledTextStyle: const TextStyle(color: Colors.grey),
              defaultDecoration: const BoxDecoration(shape: BoxShape.circle),
              weekendDecoration: const BoxDecoration(shape: BoxShape.circle),
              outsideDecoration: const BoxDecoration(shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          if (_selectedDay != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '선택한 날짜: ${DateFormat('yyyy년 MM월 dd일').format(_selectedDay!)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '패키지: ${widget.package.title}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.package.nights}박${widget.package.nights + 1}일',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('출발 요일: ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: widget.package.departureDays.map((day) {
                            final weekday = ['월', '화', '수', '목', '금', '토', '일'][day - 1];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Text(
                                weekday,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '가격: ₩${NumberFormat('#,###').format(widget.package.price.toInt())}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildParticipantSelector(),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _requestReservation(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  '예약 신청하기',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}