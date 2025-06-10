// SharedDataManager.swift
import Foundation
import WidgetKit

@objc(SharedDataManager)
class SharedDataManager: NSObject {

    static let appGroupId = "group.react.native.widget.todo"
    static let todoListKey = "todoListKey"

    @objc static func saveTodosToSharedDefaults(_ todosJsonString: String, resolver resolve: RCTPromiseResolveBlock,  rejecter reject: RCTPromiseRejectBlock) {
        if let sharedDefaults = UserDefaults(suiteName: appGroupId) {
            sharedDefaults.set(todosJsonString, forKey: todoListKey)
            if #available(iOS 15.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            } else {
                WidgetCenter.shared.reloadAllTimelines() // iOS 14+ 에서도 WidgetCenter 사용 가능
            }
            print("Shared todos saved and widget reloaded successfully.")
            resolve(nil) // 성공 시 resolve 호출 (반환할 데이터가 없으면 nil)
        } else {
            let error = NSError(domain: "SharedDataManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to access shared UserDefaults for App Group: \(appGroupId)"])
            print(error.localizedDescription)
            reject("shared_defaults_error", error.localizedDescription, error) // 실패 시 reject 호출
        }
    }

    // getTodosFromSharedDefaults 함수도 Promise를 사용한다면 동일하게 수정
    @objc static func getTodosFromSharedDefaults(resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if let sharedDefaults = UserDefaults(suiteName: appGroupId) {
            let todosJsonString = sharedDefaults.string(forKey: todoListKey)
            resolve(todosJsonString)
        } else {
            let error = NSError(domain: "SharedDataManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to access shared UserDefaults for App Group: \(appGroupId)"])
            reject("shared_defaults_error", error.localizedDescription, error)
        }
    }
}