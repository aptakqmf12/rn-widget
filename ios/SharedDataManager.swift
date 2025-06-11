// SharedDataManager.swift
import Foundation
import WidgetKit

@objc(SharedDataManager)
class SharedDataManager: NSObject {

    static let appGroupId = "group.react.native.widget.todo"
    static let todoListKey = "todoListKey"

    @objc func saveTodosToSharedDefaults(_ todosJsonString: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
            if let sharedDefaults = UserDefaults(suiteName: Self.appGroupId) {
                sharedDefaults.set(todosJsonString, forKey: Self.todoListKey)
                if #available(iOS 15.0, *) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
                resolve(nil)
            } else {
                let error = NSError(domain: "SharedDataManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to access shared UserDefaults for App Group: \(Self.appGroupId)"])
                reject("shared_defaults_error", error.localizedDescription, error)
            }
        }


    @objc func getTodosFromSharedDefaults(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
            if let sharedDefaults = UserDefaults(suiteName: Self.appGroupId) {
                let todosJsonString = sharedDefaults.string(forKey: Self.todoListKey)
                resolve(todosJsonString)
            } else {
                let error = NSError(domain: "SharedDataManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to access shared UserDefaults for App Group: \(Self.appGroupId)"])
                reject("shared_defaults_error", error.localizedDescription, error)
            }
        }
}
