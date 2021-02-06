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

    var monitor: FolderContentMonitor!
    var disposeBag: DisposeBag! = DisposeBag()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        let result = panel.runModal()

        guard result.rawValue == NSFileHandlingPanelOKButton,
            let url = panel.urls.first
            else { NSApp.terminate(self); return }

        report(url)

        self.monitor = FolderContentMonitor(url: url, latency: 0)
        monitor.rx.folderContentChange

            // Ignore Finder folder settings
            .filter { $0.filename != ".DS_Store" }

            // Report changes into app's main log
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] event in
                self.report("\(event.filename) changed (\(event.change))")
            })
            .disposed(by: disposeBag)
    }

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return dateFormatter
    }()

    func report(_ text: CustomStringConvertible) {

        let line = "\(dateFormatter.string(from: Date())) : \(text.description)\n"

        DispatchQueue.main.async {
            self.textView.string = self.textView.string.appending(line)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }

    @objc dynamic var windowIsAlwaysOnTop: Bool = false {
        didSet {
            if windowIsAlwaysOnTop {
                window.level = .modalPanel
            } else {
                window.level = .normal
            }
        }
    }

    @IBAction func clear(_ sender: Any?) {
        self.textView.string = ""
    }
}
