import 'dart:io';

class ScreenshotService {

  static Future<File?> captureScreen() async {

    try {

      // =========================
      // FILE NAME
      // =========================

      final now = DateTime.now();

      final fileName =
          "${now.millisecondsSinceEpoch}.png";

      // =========================
      // TEMP PATH
      // =========================

      final tempDir = Directory.systemTemp;

      final filePath =
          "${tempDir.path}\\$fileName";

      // =========================
      // WINDOWS
      // =========================

      if (Platform.isWindows) {

        final script = """
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# DPI FIX
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class DPI {
    [DllImport("user32.dll")]
    public static extern bool SetProcessDPIAware();
}
"@

[DPI]::SetProcessDPIAware()

# GET FULL SCREEN
\$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds

# CREATE BITMAP
\$bitmap = New-Object System.Drawing.Bitmap(
    \$bounds.Width,
    \$bounds.Height
)

# GRAPHICS
\$graphics = [System.Drawing.Graphics]::FromImage(\$bitmap)

# CAPTURE ENTIRE SCREEN
\$graphics.CopyFromScreen(
    \$bounds.Location,
    [System.Drawing.Point]::Empty,
    \$bounds.Size
)

# SAVE PNG
\$bitmap.Save(
    "$filePath",
    [System.Drawing.Imaging.ImageFormat]::Png
)

# CLEANUP
\$graphics.Dispose()
\$bitmap.Dispose()
""";

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

        print("Windows Exit Code:");
        print(result.exitCode);

        print(result.stdout);

        print(result.stderr);
      }

      // =========================
      // LINUX
      // =========================

      else if (Platform.isLinux) {

        final result = await Process.run(
          'gnome-screenshot',
          [
            '-f',
            filePath,
          ],
        );

        print("Linux Exit Code:");
        print(result.exitCode);

        print(result.stdout);

        print(result.stderr);
      }

      // =========================
      // CHECK FILE
      // =========================

      final file = File(filePath);

      if (await file.exists()) {

        print("Screenshot saved in temp:");
        print(file.path);

        return file;
      }

      print("Screenshot file not found");

      return null;

    } catch (e) {

      print("Capture error:");
      print(e);

      return null;
    }
  }

  // =========================
  // DELETE TEMP FILE
  // =========================

  static Future<void> deleteScreenshot(
    File file,
  ) async {

    if (await file.exists()) {

      await file.delete();

      print("Temp screenshot deleted");
    }
  }
}