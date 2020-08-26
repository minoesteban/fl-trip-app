import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<File> moveFile(File sourceFile, String newPath) async {
  try {
    if (newPath == '') {
      Directory appDir = await getApplicationDocumentsDirectory();
      newPath =
          '${appDir.path}/${path.basename(sourceFile.path).replaceAll(' ', '')}';
    }
    return await sourceFile.rename(newPath);
  } catch (e) {
    /// if rename fails, copy the source file and then delete it
    final newFile = await sourceFile.copy(newPath);
    await sourceFile.delete();
    return newFile;
  }
}
