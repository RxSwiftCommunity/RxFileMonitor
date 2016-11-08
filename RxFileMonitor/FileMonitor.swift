//
//  FileMonitor.swift
//  RxFileMonitor
//
//  Created by Christian Tietze on 08/11/16.
//  Copyright © 2016 CleanCocoa. All rights reserved.
//

import Foundation

/// Monitor for a particular file or folder. Change events
/// will fire when the contents of the URL changes:
///
/// -   If it's a folder, it will fire when you add/remove/rename files.
/// -   If it's a file, it will fire when you change its contents,
///    remove, or rename it.
///
/// The URL will not update if you rename the file, though.
public class FileMonitor {

    public struct ChangeEvent {
        public let url: URL
    }

    public static let monitorQueue = DispatchQueue(label: "com.cleancocoa.rxfilemonitor.monitorqueue", qos: .background, attributes: [.concurrent])

    var monitoredFileDescriptor: Int32?
    var monitorSource: DispatchSourceFileSystemObject?

    let url: URL
    let callback: (ChangeEvent) -> Void

    /// Set up a new monitor. You have to call `start()` first
    /// to make it work.
    ///
    /// - parameter url: File or folder to monitor for changes.
    /// - parameter callback: Will be called when a change event fires.
    ///
    ///     If it's a folder, it will fire when you add/remove/rename files.
    ///
    ///     If it's a file, it will fire when you change its contents,
    ///    remove, or rename it.
    /// 
    /// - note: Renaming files will not fire events with the
    ///   new URL.
    public init(url: URL, callback: @escaping (ChangeEvent) -> Void) {

        self.url = url
        self.callback = callback
    }

    deinit {
        stop()
    }

    public func start() {

        guard self.monitorSource == nil && self.monitoredFileDescriptor == nil else {
            assertionFailure("Starting monitor twice is not supported")
            return
        }

        let fileDescriptor = open(url.path, O_EVTONLY)
        let monitorSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: DispatchSource.FileSystemEvent.all,
            queue: FileMonitor.monitorQueue)

        monitorSource.setEventHandler { [weak self] in
            self?.didObserveChange()
        }

        monitorSource.setCancelHandler {
            self.monitoredFileDescriptor = nil
            self.monitorSource = nil
        }

        self.monitorSource = monitorSource
        self.monitoredFileDescriptor = fileDescriptor

        monitorSource.resume()
    }

    private func didObserveChange() {

        self.callback(ChangeEvent(url: self.url))
    }

    public func stop() {

        monitorSource?.cancel()
    }
}
