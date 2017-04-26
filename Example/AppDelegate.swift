//
//  AppDelegate.swift
//  Example
//
//  Created by Christian Tietze on 08/11/16.
//  Copyright © 2016 RxSwiftCommunity https://github.com/RxSwiftCommunity
//

import Cocoa
import RxFileMonitor
import RxSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var textView: NSTextView!

    let disposeBag = DisposeBag()

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

        FolderContentMonitor(url: url, latency: 0)
            .asObservable()

            // Ignore Finder folder settings
            .filter { $0.filename != ".DS_Store" }

            // Report changes into app's main log
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { event in
                self.report("\(event.filename) changed (\(event.change))")
            })
            .addDisposableTo(disposeBag)
    }

    func report(_ text: CustomStringConvertible) {

        DispatchQueue.main.async {
            self.textView.string = (self.textView.string ?? "")
                .appending(text.description)
                .appending("\n\n")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }
}
