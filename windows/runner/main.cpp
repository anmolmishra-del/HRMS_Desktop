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

#include "flutter_window.h"
#include "utils.h"

using flutter::EncodableMap;
using flutter::EncodableValue;

// =====================================================
// GLOBALS
// =====================================================

std::unique_ptr<
    flutter::EventSink<flutter::EncodableValue>>
    g_event_sink;

HHOOK keyboardHook;
HHOOK mouseHook;

int keyboardCount = 0;
int mouseClickCount = 0;
int mouseMoveCount = 0;

// =====================================================
// KEYBOARD HOOK
// =====================================================

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
        lParam
    );
}

// =====================================================
// MOUSE HOOK
// =====================================================

LRESULT CALLBACK MouseProc(
    int nCode,
    WPARAM wParam,
    LPARAM lParam) {

    if (nCode >= 0) {

        switch (wParam) {

        case WM_MOUSEMOVE:
            mouseMoveCount++;
            break;

        case WM_LBUTTONDOWN:
        case WM_RBUTTONDOWN:
            mouseClickCount++;
            break;
        }
    }

    return CallNextHookEx(
        mouseHook,
        nCode,
        wParam,
        lParam
    );
}

// =====================================================
// IDLE TIME
// =====================================================

int GetIdleTime() {

    LASTINPUTINFO lii;

    lii.cbSize = sizeof(LASTINPUTINFO);

    GetLastInputInfo(&lii);

    return (GetTickCount() - lii.dwTime) / 1000;
}

// =====================================================
// START TRACKING
// =====================================================

void StartTracking() {

    keyboardHook = SetWindowsHookEx(
        WH_KEYBOARD_LL,
        KeyboardProc,
        NULL,
        0
    );

    mouseHook = SetWindowsHookEx(
        WH_MOUSE_LL,
        MouseProc,
        NULL,
        0
    );

    // SEND EVENTS TO FLUTTER

    std::thread([]() {

        while (true) {

            if (g_event_sink) {

                EncodableMap data;

                data[EncodableValue("keys")] =
                    EncodableValue(keyboardCount);

                data[EncodableValue("clicks")] =
                    EncodableValue(mouseClickCount);

                data[EncodableValue("moves")] =
                    EncodableValue(mouseMoveCount);

                data[EncodableValue("idle")] =
                    EncodableValue(GetIdleTime());

                g_event_sink->Success(
                    EncodableValue(data)
                );
            }

            Sleep(1000);
        }

    }).detach();
}

// =====================================================
// MAIN
// =====================================================

int APIENTRY wWinMain(
    _In_ HINSTANCE instance,
    _In_opt_ HINSTANCE prev,
    _In_ wchar_t *command_line,
    _In_ int show_command) {

    // CONSOLE

    if (!::AttachConsole(ATTACH_PARENT_PROCESS) &&
        ::IsDebuggerPresent()) {

        CreateAndAttachConsole();
    }

    // COM INIT

    ::CoInitializeEx(
        nullptr,
        COINIT_APARTMENTTHREADED
    );

    // FLUTTER PROJECT

    flutter::DartProject project(L"data");

    std::vector<std::string>
        command_line_arguments =
            GetCommandLineArguments();

    project.set_dart_entrypoint_arguments(
        std::move(command_line_arguments)
    );

    // WINDOW

    FlutterWindow window(project);

    Win32Window::Point origin(10, 10);

    Win32Window::Size size(1280, 720);

    if (!window.Create(
            L"hrms_desktop",
            origin,
            size)) {

        return EXIT_FAILURE;
    }

    window.SetQuitOnClose(true);

    // =====================================================
    // FLUTTER ENGINE
    // =====================================================

    auto controller =
        window.flutter_controller();

    auto messenger =
        controller->engine()->messenger();

    // =====================================================
    // METHOD CHANNEL
    // =====================================================

    flutter::MethodChannel<> method_channel(
        messenger,
        "hrms/activity",
        &flutter::StandardMethodCodec::GetInstance()
    );

    method_channel.SetMethodCallHandler(
        [](const auto &call,
           auto result) {

            if (call.method_name() ==
                "startTracking") {

                StartTracking();

                result->Success();

            } else {

                result->NotImplemented();
            }
        }
    );

    // =====================================================
    // EVENT CHANNEL
    // =====================================================

    auto streamHandler =
        std::make_unique<
            flutter::StreamHandlerFunctions<>
        >(

            [](const EncodableValue *arguments,
               std::unique_ptr<
                   flutter::EventSink<
                       flutter::EncodableValue>> &&
                   events)

                -> std::unique_ptr<
                    flutter::StreamHandlerError<
                        flutter::EncodableValue>> {

                g_event_sink =
                    std::move(events);

                return nullptr;
            },

            [](const EncodableValue *arguments)

                -> std::unique_ptr<
                    flutter::StreamHandlerError<
                        flutter::EncodableValue>> {

                g_event_sink.reset();

                return nullptr;
            });

    flutter::EventChannel<> event_channel(
        messenger,
        "hrms/activity_stream",
        &flutter::StandardMethodCodec::GetInstance()
    );

    event_channel.SetStreamHandler(
        std::move(streamHandler)
    );

    // =====================================================
    // WINDOWS MESSAGE LOOP
    // =====================================================

    ::MSG msg;

    while (::GetMessage(
        &msg,
        nullptr,
        0,
        0)) {

        ::TranslateMessage(&msg);

        ::DispatchMessage(&msg);
    }

    // =====================================================
    // CLEANUP
    // =====================================================

    UnhookWindowsHookEx(keyboardHook);

    UnhookWindowsHookEx(mouseHook);

    ::CoUninitialize();

    return EXIT_SUCCESS;
}