//
//  Monitoring.swift
//  RxFileMonitor
//
//  Created by Christian Tietze on 08/11/16.
//  Copyright © 2016 RxSwiftCommunity https://github.com/RxSwiftCommunity
//

import Foundation
import RxSwift

extension FolderContentMonitor: ReactiveCompatible { }

extension Reactive where Base: FolderContentMonitor {
    public var folderContentChange: Observable<FolderContentChangeEvent> {
        return Observable<FolderContentChangeEvent>.create { [weak weakMonitor = self.base] observer in

            guard let monitor = weakMonitor else {
                observer.onCompleted()
                return Disposables.create()
            }

            // Wrap existing callback
            let oldCallback = monitor.callback

            monitor.callback = { event in
                oldCallback?(event)
                observer.on(.next(event))
            }

            if !monitor.hasStarted {
                monitor.start()
            }

            return Disposables.create {
                if let strongBase = weakMonitor {
                    strongBase.stop()
                }
            }
        }
    }
}
