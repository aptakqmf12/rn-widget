import WidgetKit
import SwiftUI
import Foundation // JSON 파싱을 위해 필요


let appGroupId = "group.react.native.widget.todo"
let todoListKey = "todoListKey"


// 위젯에 표시될 데이터를 제공하는 역할을 합니다.
struct Provider: TimelineProvider {
    // 위젯에 표시될 할 일 데이터 모델
    struct Entry: TimelineEntry {
        let date: Date
        let todos: [String] // 할 일 목록 (문자열 배열)
    }

    // 플레이스홀더: 위젯이 로드되기 전이나 데이터가 없을 때 표시될 기본 UI
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), todos: ["로딩 중...", "위젯을 추가해보세요."])
    }

    // 스냅샷: 위젯 갤러리나 빠르게 위젯을 표시할 때 사용
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let todos = fetchTodosFromSharedDefaults()
        let entry = Entry(date: Date(), todos: todos)
        completion(entry)
    }

    // 타임라인: 위젯이 언제, 어떤 데이터로 업데이트될지 정의
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let todos = fetchTodosFromSharedDefaults()
        let entry = Entry(date: Date(), todos: todos)

        // 다음 업데이트 시점을 정의합니다.
        // 여기서는 1분마다 위젯을 업데이트하도록 설정했습니다.
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }

    // MARK: - Shared Defaults에서 할 일 목록 읽어오기
    private func fetchTodosFromSharedDefaults() -> [String] {
        if let sharedDefaults = UserDefaults(suiteName: appGroupId) {
            if let todosJsonString = sharedDefaults.string(forKey: todoListKey) {
                // JSON 문자열을 Swift 배열로 디코딩
                if let data = todosJsonString.data(using: .utf8) {
                    do {
                        let todosArray = try JSONDecoder().decode([String].self, from: data)
                        return todosArray.isEmpty ? ["할 일이 없습니다."] : todosArray
                    } catch {
                        print("Error decoding JSON: \(error.localizedDescription)")
                        return ["데이터 파싱 오류"]
                    }
                }
            }
        }
        return ["할 일이 없습니다."] // 기본값
    }
}

// 위젯의 실제 UI를 SwiftUI로 정의합니다.
struct TodoWidgetEntryView : View {
    var entry: Provider.Entry
    // 위젯의 크기 (시스템에서 제공되는 환경 변수)
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            // 위젯 배경색 (선택 사항)
            ContainerRelativeShape()
                .fill(Color.red.gradient)

            VStack(alignment: .leading, spacing: 5) {
                Text("나의 할 일")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 2)


                // 할 일 목록 표시
                if entry.todos.isEmpty || (entry.todos.count == 1 && entry.todos[0] == "할 일이 없습니다.") {
                    Text("할 일이 없습니다. 앱에서 추가해보세요!")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    ForEach(entry.todos.prefix(getDisplayLimit(for: family)), id: \.self) { todo in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.7))
                            Text(todo)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .lineLimit(1) // 한 줄로 제한
                        }
                    }

                    if entry.todos.count > getDisplayLimit(for: family) {
                        Text("...")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                Spacer() // 내용을 상단으로 밀어올림
            }
            .padding() // 전체 VStack에 패딩 적용
        }
    }

    // 위젯 크기에 따라 표시할 할 일 개수 제한
    private func getDisplayLimit(for family: WidgetFamily) -> Int {
        switch family {
        case .systemSmall:
            return 2 // 작은 위젯에는 2개까지만 표시
        case .systemMedium:
            return 4 // 중간 위젯에는 4개까지만 표시
        case .systemLarge:
            return 8 // 큰 위젯에는 8개까지만 표시
        case .systemExtraLarge: // iPadOS에서 사용 가능
            return 10
        @unknown default:
            return 3
        }
    }
}

// 위젯의 종류, 표시 이름, 설명 등을 정의합니다.
struct TodoWidget: Widget {
    let kind: String = "TodoWidget" // ⭐️ kind도 "TodoWidget"으로 변경

    var body: some WidgetConfiguration {
        // StaticConfiguration: 사용자 설정 없이 고정된 데이터만 보여주는 위젯
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            // MyTodoAppWidgetEntryView -> TodoWidgetEntryView 로 변경
            TodoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("나의 할 일") // 위젯 갤러리에서 표시될 이름
        .description("나의 할 일 목록을 빠르게 확인하세요.") // 위젯 갤러리에서 표시될 설명
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge]) // 지원하는 위젯 크기
    }
}


// Xcode 캔버스에서 위젯을 미리 볼 수 있도록 합니다.
#Preview(body: {
    TodoWidgetEntryView(entry: Provider.Entry(date: Date(), todos: ["할 일 1", "할 일 2", "할 일 3", "할 일 4"]))
})
