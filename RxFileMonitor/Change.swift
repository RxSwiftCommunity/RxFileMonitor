//
//  Change.swift
//  RxFileMonitor
//
//  Created by Christian Tietze on 08/11/16.
//  Copyright © 2016 RxSwiftCommunity https://github.com/RxSwiftCommunity
//

import Foundation

/// Option set wrapper around some `FSEventStreamEventFlags`
/// which are useful to monitor folders.
public struct Change: OptionSet {

    public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public init(eventFlags: FSEventStreamEventFlags) {
        self.rawValue = Int(eventFlags)
    }

    public static let isDirectory = Change(rawValue: kFSEventStreamEventFlagItemIsDir)
    public static let isFile = Change(rawValue: kFSEventStreamEventFlagItemIsFile)
    public static let isHardlink = Change(rawValue: kFSEventStreamEventFlagItemIsHardlink)
    public static let isLastHardlink = Change(rawValue: kFSEventStreamEventFlagItemIsLastHardlink)
    public static let isSymlink = Change(rawValue: kFSEventStreamEventFlagItemIsSymlink)

    public static let created = Change(rawValue: kFSEventStreamEventFlagItemCreated)
    public static let modified = Change(rawValue: kFSEventStreamEventFlagItemModified)
    public static let removed = Change(rawValue: kFSEventStreamEventFlagItemRemoved)
    public static let renamed = Change(rawValue: kFSEventStreamEventFlagItemRenamed)

    public static let changeOwner = Change(rawValue: kFSEventStreamEventFlagItemChangeOwner)
    public static let finderInfoModified = Change(rawValue: kFSEventStreamEventFlagItemFinderInfoMod)
    public static let inodeMetaModified = Change(rawValue: kFSEventStreamEventFlagItemInodeMetaMod)
    public static let xattrsModified = Change(rawValue: kFSEventStreamEventFlagItemXattrMod)
}

extension Change: CustomStringConvertible {

    public var description: String {

        var names: [String] = []
        if self.contains(.isDirectory) { names.append("isDir") }
        if self.contains(.isFile) { names.append("isFile") }
        if self.contains(.isHardlink) { names.append("isHardlink") }
        if self.contains(.isLastHardlink) { names.append("isLastHardlink") }
        if self.contains(.isSymlink) { names.append("isSymlink") }

        if self.contains(.created) { names.append("created") }
        if self.contains(.modified) { names.append("modified") }
        if self.contains(.removed) { names.append("removed") }
        if self.contains(.renamed) { names.append("renamed") }

        if self.contains(.changeOwner) { names.append("changeOwner") }
        if self.contains(.finderInfoModified) { names.append("finderInfoModified") }
        if self.contains(.inodeMetaModified) { names.append("inodeMetaModified") }
        if self.contains(.xattrsModified) { names.append("xattrsModified") }

        return names.joined(separator: ", ")
    }
}
