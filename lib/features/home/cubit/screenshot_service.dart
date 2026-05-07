import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ScreenshotService {

  static Future<File?> captureScreen() async {

    try {

      // =========================
      // DOCUMENT DIRECTORY
      // =========================

      final documentsDir =
          await getApplicationDocumentsDirectory();

      // =========================
      // CREATE FOLDER
      // =========================

      final screenshotDir = Directory(
        "${documentsDir.path}/HRMS_Screenshots",
      );

      if (!await screenshotDir.exists()) {

        await screenshotDir.create(
          recursive: true,
        );
      }

      // =========================
      // FILE NAME
      // =========================

      final now = DateTime.now();

      final fileName =
          "${now.millisecondsSinceEpoch}.png";

      final filePath =
          "${screenshotDir.path}/$fileName";

      // =========================
      // WINDOWS
      // =========================

      if (Platform.isWindows) {

        final script = r'''
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# FIX DPI SCALING
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class DPI {
    [DllImport("user32.dll")]
    public static extern bool SetProcessDPIAware();
}
"@

[DPI]::SetProcessDPIAware()

# FULL SCREEN BOUNDS
$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

# CREATE BITMAP
$bitmap = New-Object System.Drawing.Bitmap `
    $bounds.Width,
    $bounds.Height

# GRAPHICS
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

# HIGH QUALITY
$graphics.InterpolationMode = `
    [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# CAPTURE FULL SCREEN
$graphics.CopyFromScreen(
    $bounds.X,
    $bounds.Y,
    0,
    0,
    $bounds.Size
)

# SAVE IMAGE
$bitmap.Save(
    "''' + filePath + r'''",
    [System.Drawing.Imaging.ImageFormat]::Png
)

$graphics.Dispose()
$bitmap.Dispose()
''';

        final result = await Process.run(
          'powershell.exe',
          [
            '-NoProfile',
            '-ExecutionPolicy',
            'Bypass',
            '-Command',
            script,
          ],
        );

        print(
          "Windows Exit Code: ${result.exitCode}",
        );

        if (result.stderr != null &&
            result.stderr.toString().isNotEmpty) {

          print(result.stderr);
        }
      }

      // =========================
      // LINUX
      // =========================

      else if (Platform.isLinux) {

        // INSTALL:
        // sudo apt install gnome-screenshot

        final result = await Process.run(
          'gnome-screenshot',
          [
            '-f',
            filePath,
          ],
        );

        print(
          "Linux Exit Code: ${result.exitCode}",
        );

        if (result.stderr != null &&
            result.stderr.toString().isNotEmpty) {

          print(result.stderr);
        }
      }

      // =========================
      // CHECK FILE
      // =========================

      final file = File(filePath);

      if (await file.exists()) {

        print(
          "Full screen screenshot saved:",
        );

        print(file.path);

        return file;
      }

      print("Screenshot not found");

      return null;

    } catch (e) {

      print("Capture error:");

      print(e);

      return null;
    }
  }
}