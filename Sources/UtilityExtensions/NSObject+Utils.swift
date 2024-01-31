//
//  NSObject+Utils.swift
//
//  Created by Yevhen Biiak on 20.08.2023.
//

import Foundation
import Combine

extension NSObject {
    
    /// Generic method for getting AssociatedObject from the NSObject class and its subclasses
    ///
    /// - Parameters:
    ///   - key: The key for the association
    ///
    ///# Example #
    /// ```
    /// private struct AssociatedKeys {
    ///      static var actions = "_actions_"
    /// }
    /// var actions: [(() -> Void)] {
    ///     get { getAssociatedObject(key: &AssociatedKeys.actions) ?? [] }
    ///     set { setAssociatedObject(key: &AssociatedKeys.actions, value: newValue) }
    /// }
    /// ```
    internal func getAssociatedObject<T>(key: inout String) -> T? {
        withUnsafePointer(to: &key) {
            objc_getAssociatedObject(self, $0) as? T
        }
    }
    /// Generic method for setting AssociatedObject to the NSObject class and its subclasses
    ///
    /// - Parameters:
    ///   - key: The key for the association
    ///   - value: The value to associate with the key key for object.
    ///
    ///# Example #
    /// ```
    /// private struct AssociatedKeys {
    ///      static var actions = "_actions_"
    /// }
    /// var actions: [(() -> Void)] {
    ///     get { getAssociatedObject(key: &AssociatedKeys.actions) ?? [] }
    ///     set { setAssociatedObject(key: &AssociatedKeys.actions, value: newValue) }
    /// }
    /// ```
    internal func setAssociatedObject<T>(key: inout String, value: T) {
        withUnsafePointer(to: &key) {
            objc_setAssociatedObject(self, $0, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal func isStrongly(_ T: NSObject.Type) -> Bool {
        type(of: self) == T
    }
}

internal final class NSCancellable: NSObject {
    let cancellable: AnyCancellable
    
    init(_ cancellable: AnyCancellable) {
        self.cancellable = cancellable
    }
    
    func cancel() {
        self.cancellable.cancel()
    }
}

extension NSObject {
    static var _ns_cancellables = "_ns_cancellables"
    
    internal var nsCancellables: Set<NSCancellable> {
        get { getAssociatedObject(key: &Self._ns_cancellables) ?? [] }
        set { setAssociatedObject(key: &Self._ns_cancellables, value: newValue) }
    }
}

extension AnyCancellable {
    internal func store(in nsObject: NSObject) {
        nsObject.nsCancellables.insert(NSCancellable(self))
    }
}


public protocol KeypathObservable {}
extension NSObject: KeypathObservable {}

extension KeypathObservable where Self: NSObject {
    
    @discardableResult
    public func onChange<Value>(_ keyPath: KeyPath<Self, Value>, _ handler: @escaping (Value) -> Void) -> Self {
        publisher(for: keyPath)
            .sink(receiveValue: handler)
            .store(in: self)
        return self
    }
}

