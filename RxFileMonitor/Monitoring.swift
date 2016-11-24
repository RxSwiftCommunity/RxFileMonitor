//
//  Monitoring.swift
//  RxFileMonitor
//
//  Created by Christian Tietze on 08/11/16.
//  Copyright © 2016 RxSwiftCommunity https://github.com/RxSwiftCommunity
//

import Foundation
import RxSwift

public enum Monitoring {

    public static func folderMonitor(url: URL) -> Observable<FolderContentChangeEvent> {

        return Observable.create { observer in

            let monitor = FolderContentMonitor(pathsToWatch: [url.path]) { event in
                observer.on(.next(event))
            }

            monitor.start()

            return Disposables.create {
                monitor.stop()
            }
        }
    }
}
