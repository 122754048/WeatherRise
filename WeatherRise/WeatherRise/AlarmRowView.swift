import SwiftUI
import CoreData

struct AlarmObject: Identifiable {
    var id: UUID
    var time: Date
    var label: String
    var weekdays: Set<Int>
    var isEnabled: Bool

    // For updating the existing alarms
    var alarmEntity: AlarmEntity?

    init(alarmEntity: AlarmEntity) {
        id = alarmEntity.id ?? UUID()
        time = alarmEntity.time ?? Date()
        label = alarmEntity.label ?? "Alarm"
        weekdays = (alarmEntity.weekdays as? Set<Int>) ?? Set<Int>()
        isEnabled = alarmEntity.isEnabled

        self.alarmEntity = alarmEntity
    }
}
