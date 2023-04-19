import Foundation

class WeekdayHelper {
    static let shared = WeekdayHelper()
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    func weekdaysLabel(for weekdays: Set<Int>) -> String {
        let selectedSymbols = weekdays.sorted().map { weekdaySymbols[$0 - 1] }

        if weekdays.count == 5 && weekdays.isSubset(of: [2, 3, 4, 5, 6]) {
            return "工作日"
        } else if weekdays.count == 2 && weekdays.isSubset(of: [1, 7]) {
            return "周末"
        } else if weekdays.count == 7 {
            return "每天"
        } else {
            return selectedSymbols.joined(separator: ", ")
        }
    }
}
