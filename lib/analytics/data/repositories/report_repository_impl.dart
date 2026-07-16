import '../../../core/entities/monthly_report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource dataSource;
  ReportRepositoryImpl(this.dataSource);

  @override
  Future<List<MonthlyReport>> getMonthlyReports() =>
      dataSource.getMonthlyReports();
}
