import SwiftUI

struct AddAlarmView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState

    @State private var selectedTime = Date()
    @State private var alarmLabel = ""
    @State private var selectedWeekdays = Set<Int>()

    var body: some View {
        NavigationView {
            Form {
                DatePicker("时间", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()

                TextField("标签", text: $alarmLabel)

                NavigationLink(destination: WeekdayPickerView(selectedWeekdays: $selectedWeekdays)) {
                    HStack {
                        Text("重复")
                        Spacer()
                        Text(WeekdayHelper.shared.weekdaysLabel(for: selectedWeekdays))
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationBarTitle("添加闹钟", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    let newAlarm = CustomAlarmObject(
                        id: UUID(),
                        time: selectedTime,
                        label: alarmLabel.isEmpty ? "闹钟" : alarmLabel,
                        weekdays: selectedWeekdays,
                        isEnabled: true
                    )
                    appState.alarms.append(newAlarm)
                    appState.saveAlarms()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct AddAlarmView_Previews: PreviewProvider {
    static var appState = AppState()

    static var previews: some View {
        AddAlarmView()
            .environmentObject(appState)
    }
}
