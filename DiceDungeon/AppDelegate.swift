//
//  AppDelegate.swift
//  DiceDungeon
//
//  Created by Michael Weingartner on 10/3/25.
//


import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set the window to fill the screen at startup
        if let window = NSApplication.shared.windows.first {
            if let screen = window.screen ?? NSScreen.main {
                // Get the visible frame (excludes menu bar and dock)
                let visibleFrame = screen.visibleFrame
                
                // Set the window frame to fill the visible screen area
                window.setFrame(visibleFrame, display: true, animate: false)
                
                // Optional: Make the window zoom to fill the screen
                // window.zoom(nil)
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}
