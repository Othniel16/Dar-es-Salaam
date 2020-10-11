import 'package:dar_es_salaam/shared/barrier.dart';

void showProgress(BuildContext context) {
  // show a loading widget to let the user know what is happening
  showProgressDialog(
      context: context,
      loadingText: 'Please wait',
      orientation: ProgressOrientation.vertical);
}
