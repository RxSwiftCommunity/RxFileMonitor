//
//  FolderContentMonitor.swift
//  RxFileMonitor
//
//  Created by Christian Tietze on 08/11/16.
//  Copyright © 2016 CleanCocoa. All rights reserved.
//

import Foundation

public class FolderContentMonitor {

    let callback: (FolderContentChangeEvent) -> Void

    public let pathsToWatch: [String]
    public private(set) var hasStarted = false
    private var streamRef: FSEventStreamRef!

    public private(set) var lastEventId: FSEventStreamEventId

    public init(pathsToWatch: [String], sinceWhen: FSEventStreamEventId = FSEventStreamEventId(kFSEventStreamEventIdSinceNow), callback: @escaping (FolderContentChangeEvent) -> Void) {

        self.lastEventId = sinceWhen
        self.pathsToWatch = pathsToWatch
        self.callback = callback
    }

    deinit {
        stop()
    }

    public func start() {

        guard hasStarted == false else { assertionFailure("Start must not be called twice. (Ignoring)"); return }

        var context = FSEventStreamContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = Unmanaged.passUnretained(self).toOpaque()
        let flags = UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        streamRef = FSEventStreamCreate(kCFAllocatorDefault, eventCallback, &context, pathsToWatch as CFArray, lastEventId, 0, flags)

        FSEventStreamScheduleWithRunLoop(streamRef, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        FSEventStreamStart(streamRef)

        hasStarted = true
    }

    private let eventCallback: FSEventStreamCallback = { (stream: ConstFSEventStreamRef, contextInfo: UnsafeMutableRawPointer?, numEvents: Int, eventPaths: UnsafeMutableRawPointer, eventFlags: UnsafePointer<FSEventStreamEventFlags>?, eventIds: UnsafePointer<FSEventStreamEventId>?) in

        guard let eventIds = eventIds,
            let eventFlags = eventFlags,
            let paths = unsafeBitCast(eventPaths, to: NSArray.self) as? [String]
            else { return }

        let fileSystemWatcher: FolderContentMonitor = unsafeBitCast(contextInfo, to: FolderContentMonitor.self)

        (0..<numEvents)
            .map { (index: Int) -> FolderContentChangeEvent in
                let change = Change(eventFlags: eventFlags[index])
                return FolderContentChangeEvent(eventId: eventIds[index], eventPath: paths[index], change: change)
            }.forEach(fileSystemWatcher.callback)

        fileSystemWatcher.lastEventId = eventIds[numEvents - 1]
    }

    public func stop() {
        guard hasStarted == true else { return }

        FSEventStreamStop(streamRef)
        FSEventStreamInvalidate(streamRef)
        FSEventStreamRelease(streamRef)
        streamRef = nil

        hasStarted = false
    }
}
