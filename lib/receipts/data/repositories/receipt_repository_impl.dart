import '../../../core/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/receipt_local_data_source.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final ReceiptLocalDataSource dataSource;
  ReceiptRepositoryImpl(this.dataSource);

  @override
  Future<List<Receipt>> getAll() => dataSource.getAll();

  @override
  Future<Receipt> add(Receipt receipt) => dataSource.add(receipt);

  @override
  Future<void> delete(String id) => dataSource.delete(id);

  @override
  Future<Receipt> scan() => dataSource.scan();
}
