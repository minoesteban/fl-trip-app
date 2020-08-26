import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'custom-dialog.dart';

// enum FileType { Image, Audio }

Future<bool> onAddFileClicked(BuildContext context, FileType fileType) async {
  showOpenAppSettingsDialog(context) {
    return CustomDialog.show(
      context,
      'Permission needed',
      'Photos permission is needed to select photos',
      'Open settings',
      openAppSettings,
    );
  }

  Permission permission;
  if (fileType == FileType.image) {
    if (Platform.isIOS) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }
  } else if (fileType == FileType.audio) {
    if (Platform.isIOS) {
      permission = Permission.mediaLibrary;
    } else {
      permission = Permission.storage;
    }
  }

  PermissionStatus permissionStatus = await permission.status;
  if (permissionStatus == PermissionStatus.restricted) {
    showOpenAppSettingsDialog(context);
    permissionStatus = await permission.status;
    if (permissionStatus != PermissionStatus.granted) {
      //Only continue if permission granted
      return false;
    }
  }

  if (permissionStatus == PermissionStatus.permanentlyDenied) {
    showOpenAppSettingsDialog(context);
    permissionStatus = await permission.status;
    if (permissionStatus != PermissionStatus.granted) {
      //Only continue if permission granted
      return false;
    }
  }

  if (permissionStatus == PermissionStatus.undetermined) {
    permissionStatus = await permission.request();
    if (permissionStatus != PermissionStatus.granted) {
      //Only continue if permission granted
      return false;
    }
  }

  if (permissionStatus == PermissionStatus.denied) {
    if (Platform.isIOS) {
      showOpenAppSettingsDialog(context);
    } else {
      permissionStatus = await permission.request();
    }

    if (permissionStatus != PermissionStatus.granted) {
      //Only continue if permission granted
      return false;
    }
  }

  if (permissionStatus == PermissionStatus.granted) {
    return true;
  }

  return false;
}
