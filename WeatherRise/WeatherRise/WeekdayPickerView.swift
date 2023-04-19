import SwiftUI

struct WeekdayPickerView: View {
    @Binding var selectedWeekdays: Set<Int>

    var body: some View {
        List {
            ForEach(0..<7) { index in
                Button(action: {
                    if selectedWeekdays.contains(index + 1) {
                        selectedWeekdays.remove(index + 1)
                    } else {
                        selectedWeekdays.insert(index + 1)
                    }
                }) {
                    HStack {
                        Text(Calendar.current.shortWeekdaySymbols[index])
                            .foregroundColor(selectedWeekdays.contains(index + 1) ? .accentColor : .primary)
                        Spacer()
                        if selectedWeekdays.contains(index + 1) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
        .navigationTitle("选择重复")
    }
}
