import Foundation

struct Alarm: Identifiable {
    let id: UUID
    let time: Date
    let label: String
    var weekdays: Set<Int> // 添加此行

    init(id: UUID = UUID(), time: Date, label: String, weekdays: Set<Int> = []) {
        self.id = id
        self.time = time
        self.label = label
        self.weekdays = weekdays // 添加此行
    }

    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: time)
    }
}
