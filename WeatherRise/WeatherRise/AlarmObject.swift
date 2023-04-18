import Foundation
import Combine
import CoreData


class AlarmObject: Identifiable, ObservableObject {
    @Published var alarm: AlarmEntity
    @Published var isEnabled: Bool

    init(alarm: AlarmEntity, isEnabled: Bool) {
        self.alarm = alarm
        self.isEnabled = isEnabled
    }
}

