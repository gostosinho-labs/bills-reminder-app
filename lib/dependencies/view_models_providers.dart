import 'package:bills_reminder/ui/bills/create/bills_create_view_model.dart';
import 'package:bills_reminder/ui/home/home_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> viewModelsProviders() {
  return [
    ChangeNotifierProvider(
      create: (context) => HomeViewModel(repository: context.read()),
    ),
    Provider(
      create: (context) => BillsCreateViewModel(repository: context.read()),
    ),
  ];
}
