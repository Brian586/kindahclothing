import 'package:file_picker/file_picker.dart';

class CustomFilePicker {
  static Future<List<PlatformFile>> pickImages({bool? isMultiple}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: isMultiple!, type: FileType.image, withData: true);

    return result != null ? result.files : [];
  }
}
