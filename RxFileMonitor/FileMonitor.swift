//
//  FileMonitor.swift
//  RxFileMonitor
//
//  Created by Christian Tietze on 08/11/16.
//  Copyright © 2016 CleanCocoa. All rights reserved.
//

import Foundation

public class FileMonitor {

    static let monitorQueue = DispatchQueue(label: "com.cleancocoa.rxfilemonitor.monitorqueue", qos: .background, attributes: [.concurrent])

    var monitoredFileDescriptor: Int32?
    var monitorSource: DispatchSourceFileSystemObject?

    let url: URL

    public init(url: URL) {

        self.url = url
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

    func didObserveChange() {

        print("Change")
    }

    public func stop() {

        monitorSource?.cancel()
    }
}
