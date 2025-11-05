import SwiftUI
import AppKit

struct ViewControllerRepresentable: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> ViewController {
        ViewController.makePreviewController()
    }
    func updateNSViewController(_ nsViewController: ViewController, context: Context) {}
}

#Preview("ViewController") {
    ViewControllerRepresentable()
        .frame(minWidth: 800, minHeight: 600)
}
