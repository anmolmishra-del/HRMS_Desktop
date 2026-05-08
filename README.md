# hrms_desktop

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
sudo apt install gnome-screenshot






//////////////////////////////////////////////////////////////////////////////////////
linux/my_application.cc
Install:
sudo apt install libx11-dev
Add to:
linux/CMakeLists.txt
find_package(X11 REQUIRED)target_link_libraries(${BINARY_NAME} PRIVATE X11)

Linux keyboard hook example
#include <X11/Xlib.h>Display* display;void StartTracking() {    display = XOpenDisplay(NULL);    Window root = DefaultRootWindow(display);    XSelectInput(        display,        root,        KeyPressMask |        PointerMotionMask |        ButtonPressMask    );    while (true) {        XEvent event;        XNextEvent(display, &event);        switch (event.type) {        case KeyPress:            keyboardCount++;            break;        case MotionNotify:            mouseMoveCount++;            break;        case ButtonPress:            mouseClickCount++;            break;        }    }}

MACOS IMPLEMENTATION
APIs used
Use:


Quartz Event Tap


CoreGraphics



macOS example
File:
macos/Runner/AppDelegate.swift

macOS keyboard hook
import Cocoaimport CoreGraphicsvar keyboardCount = 0var mouseCount = 0func callback(    proxy: CGEventTapProxy,    type: CGEventType,    event: CGEvent,    refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {    switch type {    case .keyDown:        keyboardCount += 1    case .leftMouseDown,         .rightMouseDown:        mouseCount += 1    default:        break    }    return Unmanaged.passRetained(event)}
Create event tap:
let eventMask =    (1 << CGEventType.keyDown.rawValue) |    (1 << CGEventType.leftMouseDown.rawValue)let tap = CGEvent.tapCreate(    tap: .cgSessionEventTap,    place: .headInsertEventTap,    options: .defaultTap,    eventsOfInterest: CGEventMask(eventMask),    callback: callback,    userInfo: nil)

IMPORTANT MACOS PERMISSIONS
macOS requires:
Accessibility permission
User must enable:
System Settings→ Privacy & Security→ Accessibility
Without this:
❌ hooks won't work.

Cross-platform Flutter architecture
Best approach
Create service abstraction:
abstract class ActivityTracker {  Stream<ActivityData> get stream;}
Implement:


WindowsTracker


LinuxTracker


MacTracker



Recommended production setup
Track
✅ idle time
✅ activity counts
✅ active app/window
✅ screenshots
✅ work session timing
Avoid
❌ raw keystrokes
❌ passwords
❌ browser text

Better alternative (HIGHLY recommended)
Instead of low-level hooks:
Use:


idle detection


active window detection


periodic screenshots


This works more reliably across:


Windows


Linux


macOS


without antivirus problems.

I can also give you
Full production HRMS architecture


background service


startup on boot


tray app


screenshot capture


app usage tracking


offline sync


PostgreSQL schema


realtime admin dashboard


employee productivity analytics


OR
Complete cross-platform plugin
with:


Windows


Linux


macOS
native implementations together.

