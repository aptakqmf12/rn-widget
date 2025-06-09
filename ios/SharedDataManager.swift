// SharedDataManager.swift
import Foundation
import WidgetKit // 위젯 업데이트를 위해 필요

@objc(SharedDataManager) // Objective-C Bridge를 위한 설정
class SharedDataManager: NSObject {

    // MARK: - App Group ID (반드시 위에 설정한 App Group ID와 동일해야 합니다!)
    static let appGroupId = "group.react.native.widget.todo" // ⭐️ 실제 App Group ID로 변경!
    static let todoListKey = "todoListKey" // 위젯과 공유할 할 일 목록 데이터의 키

    @objc static func saveTodosToSharedDefaults(_ todosJsonString: String) {
        if let sharedDefaults = UserDefaults(suiteName: appGroupId) {
            sharedDefaults.set(todosJsonString, forKey: todoListKey)
            // 위젯에게 데이터가 업데이트되었음을 알립니다.
            // iOS 15 이상에서는 WidgetCenter.shared.reloadAllTimelines() 사용
            // iOS 14에서는 WidgetKit.reloadAllTimelines() 사용
            if #available(iOS 15.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            } else {
              WidgetCenter.shared.reloadAllTimelines()
             // 이거 쓰면안됨
             //WidgetKit.reloadAllTimelines()
            }
            print("Shared todos saved and widget reloaded successfully.")
        } else {
            print("Failed to access shared UserDefaults for App Group: \(appGroupId)")
        }
    }

    // (선택 사항) 위젯에서 앱으로 데이터를 가져오는 함수도 만들 수 있습니다.
    @objc static func getTodosFromSharedDefaults() -> String? {
        if let sharedDefaults = UserDefaults(suiteName: appGroupId) {
            return sharedDefaults.string(forKey: todoListKey)
        }
        return nil
    }
}
