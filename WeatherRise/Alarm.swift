import Foundation

class Alarm: Identifiable, ObservableObject {
    let id = UUID()
    @Published var time: Date
    @Published var repeatDays: String
    @Published var isActive: Bool

    init(time: Date = Date(), repeatDays: String = "无", isActive: Bool = false) {
        self.time = time
        self.repeatDays = repeatDays
        self.isActive = isActive
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}
