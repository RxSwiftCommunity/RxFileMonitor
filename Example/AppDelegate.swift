//
//  AppDelegate.swift
//  Example
//
//  Created by Christian Tietze on 08/11/16.
//  Copyright © 2016 CleanCocoa. All rights reserved.
//

import Cocoa
import RxFileMonitor

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var textView: NSTextView!

    var monitor: FileMonitor?

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        let result = panel.runModal()

        guard result == NSFileHandlingPanelOKButton,
            let url = panel.urls.first
            else { NSApp.terminate(self); return }

        report(url)
        monitor = FileMonitor(url: url) { [weak self] in
            self?.report("change in folder")
        }
        monitor?.start()

        contentMonitor = FolderContentMonitor(pathsToWatch: [url.path]) { [weak self] event in
            self?.report("change in \(event)")
        }
        contentMonitor?.start()
    }

    var contentMonitor: FolderContentMonitor?

    func report(_ text: CustomStringConvertible) {

        DispatchQueue.main.async {
            self.textView.string = (self.textView.string ?? "")
                .appending(text.description)
                .appending("\n\n")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {

        monitor?.stop()
        contentMonitor?.stop()
    }
}
