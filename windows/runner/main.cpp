#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <windows.h>

#include <memory>
#include <thread>
#include <atomic>
#include <chrono>

#include "flutter_window.h"
#include "utils.h"

using flutter::EncodableMap;
using flutter::EncodableValue;

/// =====================================================
/// GLOBALS
/// =====================================================

std::unique_ptr<
    flutter::EventSink<
        flutter::EncodableValue>>
    g_event_sink;

std::unique_ptr<
    flutter::MethodChannel<
        flutter::EncodableValue>>
    method_channel;

std::unique_ptr<
    flutter::EventChannel<
        flutter::EncodableValue>>
    event_channel;

HHOOK keyboardHook = NULL;

HHOOK mouseHook = NULL;

std::atomic<bool>
    trackingStarted(false);

int keyboardCount = 0;

int mouseClickCount = 0;

int mouseMoveCount = 0;

/// =====================================================
/// KEYBOARD HOOK
/// =====================================================

LRESULT CALLBACK KeyboardProc(
    int nCode,
    WPARAM wParam,
    LPARAM lParam) {

  if (nCode >= 0) {

    if (wParam == WM_KEYDOWN) {

      keyboardCount++;
    }
  }

  return CallNextHookEx(
      keyboardHook,
      nCode,
      wParam,
      lParam);
}

/// =====================================================
/// MOUSE HOOK
/// =====================================================

LRESULT CALLBACK MouseProc(
    int nCode,
    WPARAM wParam,
    LPARAM lParam) {

  static POINT lastPoint = {0, 0};

  static bool initialized = false;

  if (nCode >= 0) {

    MSLLHOOKSTRUCT* mouse =
        (MSLLHOOKSTRUCT*)lParam;

    switch (wParam) {

      /// =====================================
      /// MOUSE MOVE
      /// =====================================

      case WM_MOUSEMOVE: {

        if (!initialized) {

          lastPoint = mouse->pt;

          initialized = true;
        }

        int dx =
            abs(mouse->pt.x - lastPoint.x);

        int dy =
            abs(mouse->pt.y - lastPoint.y);

        // Ignore tiny fake movement
        if (dx > 2 || dy > 2) {

          mouseMoveCount++;

          lastPoint = mouse->pt;
        }

        break;
      }

      /// =====================================
      /// LEFT CLICK
      /// =====================================

      case WM_LBUTTONDOWN:

        mouseClickCount++;

        break;

      /// =====================================
      /// RIGHT CLICK
      /// =====================================

      case WM_RBUTTONDOWN:

        mouseClickCount++;

        break;

      /// =====================================
      /// MIDDLE CLICK
      /// =====================================

      case WM_MBUTTONDOWN:

        mouseClickCount++;

        break;
    }
  }

  return CallNextHookEx(
      mouseHook,
      nCode,
      wParam,
      lParam);
}

/// =====================================================
/// GET IDLE TIME
/// =====================================================

int GetIdleTime() {

  LASTINPUTINFO lii;

  lii.cbSize =
      sizeof(LASTINPUTINFO);

  GetLastInputInfo(&lii);

  ULONGLONG tick =
      GetTickCount64();

  return static_cast<int>(
      (tick - lii.dwTime) / 1000);
}

/// =====================================================
/// STOP TRACKING
/// =====================================================

void StopTracking() {

  trackingStarted = false;

  if (keyboardHook != NULL) {

    UnhookWindowsHookEx(
        keyboardHook);

    keyboardHook = NULL;
  }

  if (mouseHook != NULL) {

    UnhookWindowsHookEx(
        mouseHook);

    mouseHook = NULL;
  }

  printf(
      "TRACKING STOPPED\n");
}

/// =====================================================
/// START TRACKING
/// =====================================================

void StartTracking() {

  if (trackingStarted) {

    printf(
        "TRACKING ALREADY RUNNING\n");

    return;
  }

  trackingStarted = true;

  keyboardHook =
      SetWindowsHookEx(
          WH_KEYBOARD_LL,
          KeyboardProc,
          NULL,
          0);

  mouseHook =
      SetWindowsHookEx(
          WH_MOUSE_LL,
          MouseProc,
          NULL,
          0);

  printf(
      "TRACKING STARTED\n");

  std::thread([] {

    while (trackingStarted) {

      if (g_event_sink) {

        EncodableMap data;

        data[
            EncodableValue(
                "keys")] =
            EncodableValue(
                keyboardCount);

        data[
            EncodableValue(
                "clicks")] =
            EncodableValue(
                mouseClickCount);

        data[
            EncodableValue(
                "moves")] =
            EncodableValue(
                mouseMoveCount);

        data[
            EncodableValue(
                "idle")] =
            EncodableValue(
                GetIdleTime());

        g_event_sink->Success(
            EncodableValue(
                data));

        printf(
            "KEYS => %d\n",
            keyboardCount);

        printf(
            "CLICKS => %d\n",
            mouseClickCount);

        printf(
            "MOVES => %d\n",
            mouseMoveCount);

        printf(
            "IDLE => %d\n",
            GetIdleTime());

        /// RESET COUNTERS EVERY SECOND

        keyboardCount = 0;

        mouseClickCount = 0;

        mouseMoveCount = 0;
      }

      std::this_thread::
          sleep_for(
              std::chrono::
                  seconds(1));
    }

  }).detach();
}

/// =====================================================
/// MAIN
/// =====================================================

int APIENTRY wWinMain(
    _In_ HINSTANCE instance,
    _In_opt_ HINSTANCE prev,
    _In_ wchar_t* command_line,
    _In_ int show_command) {

  /// CONSOLE

  if (!::AttachConsole(
           ATTACH_PARENT_PROCESS) &&
      ::IsDebuggerPresent()) {

    CreateAndAttachConsole();
  }

  /// COM INIT

  ::CoInitializeEx(
      nullptr,
      COINIT_APARTMENTTHREADED);

  /// FLUTTER PROJECT

  flutter::DartProject project(
      L"data");

  std::vector<std::string>
      command_line_arguments =
          GetCommandLineArguments();

  project
      .set_dart_entrypoint_arguments(
          std::move(
              command_line_arguments));

  /// WINDOW

  FlutterWindow window(project);

  Win32Window::Point origin(
      10,
      10);

  Win32Window::Size size(
      1280,
      720);

  if (!window.Create(
          L"hrms_desktop",
          origin,
          size)) {

    return EXIT_FAILURE;
  }

  window.SetQuitOnClose(true);

  /// =====================================================
  /// ENGINE
  /// =====================================================

  auto controller =
      window.flutter_controller();

  auto messenger =
      controller
          ->engine()
          ->messenger();

  /// =====================================================
  /// METHOD CHANNEL
  /// =====================================================

  method_channel =
      std::make_unique<
          flutter::
              MethodChannel<
                  flutter::
                      EncodableValue>>(
          messenger,
          "hrms/activity",
          &flutter::
              StandardMethodCodec::
                  GetInstance());

  method_channel->
      SetMethodCallHandler(

          [](const auto& call,
             auto result) {

            /// START

            if (call.method_name()
                ==
                "startTracking") {

              StartTracking();

              result->Success();

              return;
            }

            /// STOP

            if (call.method_name()
                ==
                "stopTracking") {

              StopTracking();

              result->Success();

              return;
            }

            result
                ->NotImplemented();
          });

  /// =====================================================
  /// EVENT CHANNEL
  /// =====================================================

  auto streamHandler =
      std::make_unique<
          flutter::
              StreamHandlerFunctions<
                  flutter::
                      EncodableValue>>(

          [](const EncodableValue*
                 arguments,

             std::unique_ptr<
                 flutter::
                     EventSink<
                         flutter::
                             EncodableValue>>
                 &&events)

              -> std::unique_ptr<
                  flutter::
                      StreamHandlerError<
                          flutter::
                              EncodableValue>> {

            g_event_sink =
                std::move(
                    events);

            printf(
                "STREAM CONNECTED\n");

            return nullptr;
          },

          [](const EncodableValue*
                 arguments)

              -> std::unique_ptr<
                  flutter::
                      StreamHandlerError<
                          flutter::
                              EncodableValue>> {

            g_event_sink
                .reset();

            printf(
                "STREAM DISCONNECTED\n");

            return nullptr;
          });

  event_channel =
      std::make_unique<
          flutter::
              EventChannel<
                  flutter::
                      EncodableValue>>(
          messenger,
          "hrms/activity_stream",
          &flutter::
              StandardMethodCodec::
                  GetInstance());

  event_channel->
      SetStreamHandler(
          std::move(
              streamHandler));

  /// =====================================================
  /// MESSAGE LOOP
  /// =====================================================

  ::MSG msg;

  while (::GetMessage(
      &msg,
      nullptr,
      0,
      0)) {

    ::TranslateMessage(
        &msg);

    ::DispatchMessage(
        &msg);
  }

  /// =====================================================
  /// CLEANUP
  /// =====================================================

  StopTracking();

  ::CoUninitialize();

  return EXIT_SUCCESS;
}