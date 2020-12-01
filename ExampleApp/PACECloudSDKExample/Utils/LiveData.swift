//
//  LiveData.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 06.11.20.
//

import Foundation

struct Observer {
    weak var receiver: AnyObject?
    var handler: ((Any?) -> Void)
}

class LiveData<T> {
    var observers: [Observer] = []

    init() {}

    init(value: T) {
        self.value = value
    }

    var value: T? {
        didSet {
            notify()
        }
    }

    func observe(receiver: AnyObject, change: @escaping ((T?) -> Void)) {
        let observer = Observer(receiver: receiver, handler: { obj in
            guard let obj = obj as? T? else { fatalError() }
            change(obj)
        })

        observers.append(observer)
        observer.handler(value)
    }

    func unregister(receiver: AnyObject) {
        self.observers.removeAll { $0.receiver === receiver }
    }

    func notify() {
        DispatchQueue.main.async {
            for observer in self.observers where observer.receiver != nil {
                observer.handler(self.value)
            }
        }
    }

    func notifyObserver<T>(of type: T.Type) {
        DispatchQueue.main.async {
            let filteredObservers = self.observers.filter { $0.receiver != nil && $0.receiver is T }
            for observer in filteredObservers {
                observer.handler(self.value)
            }
        }
    }
}
