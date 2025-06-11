import WidgetKit
import SwiftUI
import Foundation

let appGroupId = "group.react.native.widget.todo"
let todoListKey = "todoListKey"

struct Provider: TimelineProvider {
    struct Entry: TimelineEntry {
        let date: Date
        let todos: [String]
    }

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), todos: ["로딩 중...", "위젯을 추가해보세요."])
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let todos = fetchTodosFromSharedDefaults()
        let entry = Entry(date: Date(), todos: todos)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let todos = fetchTodosFromSharedDefaults()
        let entry = Entry(date: Date(), todos: todos)
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }

    private func fetchTodosFromSharedDefaults() -> [String] {
        if let sharedDefaults = UserDefaults(suiteName: appGroupId),
           let todosJsonString = sharedDefaults.string(forKey: todoListKey),
           let data = todosJsonString.data(using: .utf8) {
            do {
                let todosArray = try JSONDecoder().decode([String].self, from: data)
                return todosArray.isEmpty ? ["할 일이 없습니다."] : todosArray
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                return ["데이터 파싱 오류"]
            }
        }
        return ["할 일이 없습니다."]
    }
}

struct TodoWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("나의 할 일")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.bottom, 2)

            if entry.todos.isEmpty || (entry.todos.count == 1 && entry.todos[0] == "할 일이 없습니다.") {
                Text("할 일이 없습니다. 앱에서 추가해보세요!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(entry.todos.prefix(getDisplayLimit(for: family)), id: \.self) { todo in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                        Text(todo)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                }

                if entry.todos.count > getDisplayLimit(for: family) {
                    Text("...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .backgroundWidgetStyle()
    }

    private func getDisplayLimit(for family: WidgetFamily) -> Int {
        switch family {
        case .systemSmall: return 2
        case .systemMedium: return 4
        case .systemLarge: return 8
        case .systemExtraLarge: return 10
        @unknown default: return 3
        }
    }
}

// ✅ containerBackground 적용을 위한 ViewModifier
extension View {
    @ViewBuilder
    func backgroundWidgetStyle() -> some View {
        if #available(iOS 17.0, *) {
            self
                .containerBackground(.fill.tertiary, for: .widget)
        } else {
            self
                .background(Color.red) // iOS 16 이하용 대체 배경
        }
    }
}

struct TodoWidget: Widget {
    let kind: String = "TodoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("나의 할 일")
        .description("나의 할 일 목록을 빠르게 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(body: {
    TodoWidgetEntryView(entry: Provider.Entry(date: Date(), todos: ["할 일 1", "할 일 2", "할 일 3", "할 일 4"]))
})
