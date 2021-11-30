//
//  AppDelegate.swift
//  BCWallyDemo-Mac
//
//  Created by Wolf McNally on 10/14/20.
//

import Cocoa
import SwiftUI
import BCWally
import WolfBase

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Wally.initialize()
        let data = Data(hex: "1673a0b7da12c9a7252f5c93a1376a8f")!
        let bip39 = Wally.bip39Encode(data: data)
        print(bip39)
        // biology other combine reflect clutch squeeze net twist neck answer survey butter

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}
