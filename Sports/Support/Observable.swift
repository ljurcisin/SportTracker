//
//  Observable.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 03/04/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import Foundation

/**
 ObservableOptional is the class used by view modes
 It has inbuild support for binding,
 Views use the binding to react on changes made in view modes
 ObservableOptional  can hods the nil value
 it also has didSetOverride optional variable which can be used to inject didSetOverride callback
*/
public class ObservableOptional<ObservedType> {

    public typealias Observer = (_ observable: ObservableOptional<ObservedType>, ObservedType?, ObservedType?) -> Void

    private var observers: [Observer]
    var didSetOverride: ((_ value: ObservedType?) -> Void)? = nil

    var observingActive: Bool = true

    public var value: ObservedType? {
        didSet {
            didSetOverride?(value)
            notifyObservers(value, oldValue: oldValue)
        }
    }

    public init(_ value: ObservedType? = nil) {
        self.value = value
        observers = []
    }

    public func bind(observer: @escaping Observer) {
        self.observers.append(observer)
    }

    private func notifyObservers(_ value: ObservedType?, oldValue: ObservedType?) {
        if observingActive {
            self.observers.forEach { [unowned self](observer) in
                observer(self, value, oldValue)
            }
        }
    }
}

/**
 Observable is similar as ObservableOptional, but it can not represent optional value
*/
public class Observable<ObservedType> {

    public typealias Observer = (_ observable: Observable<ObservedType>, ObservedType, ObservedType) -> Void

    private var observers: [Observer]

    public var value: ObservedType {
        didSet {
            notifyObservers(value, oldValue: oldValue)
        }
    }

    public init(_ value: ObservedType) {
        self.value = value
        observers = []
    }

    public func bind(observer: @escaping Observer) {
        self.observers.append(observer)
    }

    private func notifyObservers(_ value: ObservedType, oldValue: ObservedType) {
        self.observers.forEach { [unowned self](observer) in
            observer(self, value, oldValue)
        }
    }
}

/**
 ObservableSortedArray is object represening array which is automaticaly sorted using given sort rule
 Same like other observable entities, can be binded by the views
*/
public class ObservableSortedArray<ObservedType> {

    public typealias Observer = (_ observable: ObservableSortedArray<ObservedType>, ObservedType, ObservedType) -> Void

    private var observers: [Observer]
    private var sortRule: ((_ value1: Any, _ value2: Any) -> Bool)

    public var value: ObservedType {
        didSet {
            if var array = value as? [Any] {
                array.sort { (value1, value2) -> Bool in
                    return sortRule(value1, value2)
                }
                value = array as! ObservedType
            }
            notifyObservers(value, oldValue)
        }
    }

    public init(_ value: ObservedType, sortRule: @escaping ((_ value1: Any, _ value2: Any) -> Bool)) {
        guard (value as? [Any] != nil) else {
            fatalError("do not use for non array objects!")
        }

        self.value = value
        self.sortRule = sortRule
        observers = []
    }

    public func bind(observer: @escaping Observer) {
        self.observers.append(observer)
    }

    private func notifyObservers(_ value: ObservedType, _ oldValue: ObservedType) {
        self.observers.forEach { [unowned self](observer) in
            observer(self, value, oldValue)
        }
    }
}
