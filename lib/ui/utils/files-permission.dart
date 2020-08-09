import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'custom-dialog.dart';

enum FileType { Image, Audio }

class FilesPermission {
  onAddFileClicked(BuildContext context, FileType fileType) async {
    Permission permission;

    if (fileType == FileType.Image) {
      if (Platform.isIOS) {
        permission = Permission.photos;
      } else {
        permission = Permission.storage;
      }
    } else if (fileType == FileType.Audio) {
      if (Platform.isIOS) {
        permission = Permission.mediaLibrary;
      } else {
        permission = Permission.storage;
      }
    }

    PermissionStatus permissionStatus = await permission.status;

    print(permissionStatus);

    if (permissionStatus == PermissionStatus.restricted) {
      _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.permanentlyDenied) {
      _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.undetermined) {
      permissionStatus = await permission.request();

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.denied) {
      if (Platform.isIOS) {
        _showOpenAppSettingsDialog(context);
      } else {
        permissionStatus = await permission.request();
      }

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.granted) {
      print('Permission granted');
    }
  }

  _showOpenAppSettingsDialog(context) {
    return CustomDialog.show(
      context,
      'Permission needed',
      'Photos permission is needed to select photos',
      'Open settings',
      openAppSettings,
    );
  }
}
