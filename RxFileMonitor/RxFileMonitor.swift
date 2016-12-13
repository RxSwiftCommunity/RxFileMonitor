//
//  Monitoring.swift
//  RxFileMonitor
//
//  Created by Christian Tietze on 08/11/16.
//  Copyright © 2016 RxSwiftCommunity https://github.com/RxSwiftCommunity
//

import Foundation
import RxSwift

extension FolderContentMonitor: ObservableConvertibleType {

    public func asObservable() -> Observable<FolderContentChangeEvent> {

        return Observable.create { observer in

            // Wrap existing callback
            let oldCallback = self.callback

            self.callback = { event in
                oldCallback?(event)
                observer.on(.next(event))
            }

            if !self.hasStarted {
                self.start()
            }

            return Disposables.create {
                self.stop()
            }
        }
    }
}
