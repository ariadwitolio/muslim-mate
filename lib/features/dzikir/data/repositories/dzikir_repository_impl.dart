import '../../domain/entities/almatsurat_item.dart';
import '../../domain/repositories/dzikir_repository.dart';
import '../sources/almatsurat_local_data_source.dart';

class DzikirRepositoryImpl implements DzikirRepository {
  DzikirRepositoryImpl(this.dataSource);

  final AlMatsuratLocalDataSource dataSource;

  @override
  List<AlMatsuratItem> getAlMatsuratItems() {
    return dataSource.getItems();
  }
}
