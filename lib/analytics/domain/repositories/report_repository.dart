import '../../../core/entities/monthly_report.dart';

abstract class ReportRepository {
  Future<List<MonthlyReport>> getMonthlyReports();
}
