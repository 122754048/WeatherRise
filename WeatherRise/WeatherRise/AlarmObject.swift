import Foundation
import Combine

class AlarmObject: Identifiable, ObservableObject {
    @Published var alarm: Alarm
    @Published var isEnabled: Bool

    init(alarm: Alarm, isEnabled: Bool) {
        self.alarm = alarm
        self.isEnabled = isEnabled
    }
}
