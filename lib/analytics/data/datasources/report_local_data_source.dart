import '../../../core/data/app_database.dart';
import '../../../core/entities/monthly_report.dart';

abstract class ReportLocalDataSource {
  Future<List<MonthlyReport>> getMonthlyReports();
}

class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  final AppDatabase db;
  ReportLocalDataSourceImpl(this.db);

  @override
  Future<List<MonthlyReport>> getMonthlyReports() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<MonthlyReport>.from(db.monthlyReports);
  }
}
