import Foundation
import Combine
import CoreData

class CustomAlarmObject: Identifiable, ObservableObject {
    @Published var id: UUID
    @Published var time: Date
    @Published var label: String
    @Published var weekdays: Set<Int>
    @Published var isEnabled: Bool

    init(id: UUID, time: Date, label: String, weekdays: Set<Int>, isEnabled: Bool) {
        self.id = id
        self.time = time
        self.label = label
        self.weekdays = weekdays
        self.isEnabled = isEnabled
    }
}
