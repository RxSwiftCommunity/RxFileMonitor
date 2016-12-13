//
//  FolderContentMonitor.swift
//  RxFileMonitor
//
//  Created by Christian Tietze on 08/11/16.
//  Copyright © 2016 RxSwiftCommunity https://github.com/RxSwiftCommunity
//

import Foundation

/// Monitor for a particular file or folder. Change events
/// will fire when the contents of the URL changes:
///
/// If it's a folder, it will fire when you add/remove/rename files or folders
/// below the reference paths. See `Change` for an incomprehensive list of 
/// events details that will be reported.
public class FolderContentMonitor {

    var callback: ((FolderContentChangeEvent) -> Void)?

    public let pathsToWatch: [String]
    public private(set) var hasStarted = false
    private var streamRef: FSEventStreamRef!

    public private(set) var lastEventId: FSEventStreamEventId

    /// - parameter url: Folder to monitor.
    /// - parameter sinceWhen: Reference event for the subscription. Default
    ///   is `kFSEventStreamEventIdSinceNow`.
    /// - parameter callback: Callback for incoming file system events. Can be ignored
    ///   when you use the monitor `asObservable`
    public convenience init(
        url: URL,
        sinceWhen: FSEventStreamEventId = FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
        callback: ((FolderContentChangeEvent) -> Void)? = nil) {

        self.init(pathsToWatch: [url.path], sinceWhen: sinceWhen, callback: callback)
    }

    /// - parameter pathsToWatch: Collection of file or folder paths.
    /// - parameter sinceWhen: Reference event for the subscription. Default 
    ///   is `kFSEventStreamEventIdSinceNow`.
    /// - parameter callback: Callback for incoming file system events. Can be ignored
    ///   when you use the monitor `asObservable`
    public init(
        pathsToWatch: [String],
        sinceWhen: FSEventStreamEventId = FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
        callback: ((FolderContentChangeEvent) -> Void)? = nil) {

        self.lastEventId = sinceWhen
        self.pathsToWatch = pathsToWatch
        self.callback = callback
    }

    deinit {
        stop()
    }

    public func start() {

        guard !hasStarted else { assertionFailure("Start must not be called twice. (Ignoring)"); return }

        var context = FSEventStreamContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = Unmanaged.passUnretained(self).toOpaque()
        let flags = UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        streamRef = FSEventStreamCreate(kCFAllocatorDefault, eventCallback, &context, pathsToWatch as CFArray, lastEventId, 0, flags)

        FSEventStreamScheduleWithRunLoop(streamRef, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        FSEventStreamStart(streamRef)

        hasStarted = true
    }

    private let eventCallback: FSEventStreamCallback = {
        (stream: ConstFSEventStreamRef,
        contextInfo: UnsafeMutableRawPointer?,
        numEvents: Int,
        eventPaths: UnsafeMutableRawPointer,
        eventFlags: UnsafePointer<FSEventStreamEventFlags>?,
        eventIds: UnsafePointer<FSEventStreamEventId>?) in

        let fileSystemWatcher: FolderContentMonitor = unsafeBitCast(contextInfo, to: FolderContentMonitor.self)

        guard let callback = fileSystemWatcher.callback,
            let eventIds = eventIds,
            let eventFlags = eventFlags,
            let paths = unsafeBitCast(eventPaths, to: NSArray.self) as? [String]
            else { return }

        (0..<numEvents)
            .map { (index: Int) -> FolderContentChangeEvent in
                let change = Change(eventFlags: eventFlags[index])
                return FolderContentChangeEvent(eventId: eventIds[index], eventPath: paths[index], change: change)
            }.forEach(callback)

        fileSystemWatcher.lastEventId = eventIds[numEvents - 1]
    }

    public func stop() {

        guard hasStarted else { return }

        FSEventStreamStop(streamRef)
        FSEventStreamInvalidate(streamRef)
        FSEventStreamRelease(streamRef)
        streamRef = nil

        hasStarted = false
    }
}
