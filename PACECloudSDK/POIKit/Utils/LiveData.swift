//
//  LiveData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension POIKit {
    struct ObserverItem {
        weak var receiver: AnyObject?
        var handler: ((Any?) -> Void)
    }

    class Observable<T> {
        public var observers: [ObserverItem] = []

        public init() {}

        public init(value: T) {
            self.value = value
        }

        public var value: T? {
            didSet {
                notify()
            }
        }

        public func observe(receiver: AnyObject, change: @escaping ((T?) -> Void)) {
            let observer = ObserverItem(receiver: receiver, handler: { obj in
                guard let obj = obj as? T? else { fatalError() }
                change(obj)
            })

            observers.append(observer)
            observer.handler(value)
        }

        public func unregister(receiver: AnyObject) {
            self.observers.removeAll { $0.receiver === receiver }
        }

        public func notify() {
            DispatchQueue.main.async {
                for observer in self.observers where observer.receiver != nil {
                    observer.handler(self.value)
                }
            }
        }

        public func notifyObserver<T>(of type: T.Type) {
            DispatchQueue.main.async {
                let filteredObservers = self.observers.filter { $0.receiver != nil && $0.receiver is T }
                for observer in filteredObservers {
                    observer.handler(self.value)
                }
            }
        }
    }
}
