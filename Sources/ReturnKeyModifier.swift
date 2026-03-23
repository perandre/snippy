import SwiftUI
import AppKit

/// Monitors for the Return key using NSEvent local monitor.
/// This works in NSPanel windows where .onSubmit and .onKeyPress fail.
struct OnReturnKey: ViewModifier {
    let action: () -> Void
    @State private var monitor: Any?

    func body(content: Content) -> some View {
        content
            .onAppear {
                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if event.keyCode == 36 { // Return key
                        action()
                        return nil // consume the event
                    }
                    return event
                }
            }
            .onDisappear {
                if let monitor = monitor {
                    NSEvent.removeMonitor(monitor)
                }
            }
    }
}

extension View {
    func onReturnKey(perform action: @escaping () -> Void) -> some View {
        modifier(OnReturnKey(action: action))
    }
}
