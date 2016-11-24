//
//  FolderContentChangeEvent.swift
//  RxFileMonitor
//
//  Created by Christian Tietze on 08/11/16.
//  Copyright © 2016 RxSwiftCommunity https://github.com/RxSwiftCommunity
//

import Foundation

public struct FolderContentChangeEvent: CustomStringConvertible {

    public let eventId: FSEventStreamEventId
    public let eventPath: String
    public let change: Change

    public var url: URL {
        return URL(fileURLWithPath: eventPath)
    }

    public var filename: String {

        return url.lastPathComponent
    }

    public var description: String {

        return "\(eventPath) (\(eventId)) changed: \(change)"
    }
}
