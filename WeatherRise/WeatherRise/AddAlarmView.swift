import SwiftUI

struct AddAlarmView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @State private var alarmTime = Date()
    @State private var ringtone = "默认"
    @State private var selectedWeekdays: Set<Int> = []

    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("设置闹钟", selection: $alarmTime, displayedComponents: .hourAndMinute)
                }
                Section {
                    NavigationLink(destination: WeekdayPickerView(selectedWeekdays: $selectedWeekdays)) {
                        HStack {
                            Text("重复")
                            Spacer()
                            Text(WeekdayHelper.shared.weekdaysLabel(for: selectedWeekdays))
                                .foregroundColor(.gray)
                        }
                    }
                }
                Section {
                    Picker("铃声", selection: $ringtone) {
                        Text("默认").tag("默认")
                        Text("铃声 1").tag("铃声 1")
                        Text("铃声 2").tag("铃声 2")
                    }
                }
            }
            .navigationBarTitle("添加闹钟")
            .navigationBarItems(
                leading:
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    },
                trailing:
                    Button("保存") {
                        let newAlarm = Alarm(time: alarmTime, label: WeekdayHelper.shared.weekdaysLabel(for: selectedWeekdays), weekdays: selectedWeekdays)
                        let newAlarmObject = AlarmObject(alarm: newAlarm, isEnabled: true)
                        appState.addAlarm(alarmObject: newAlarmObject)
                        presentationMode.wrappedValue.dismiss()
                    }
            )
        }
    }
}

struct AddAlarmView_Previews: PreviewProvider {
    static var previews: some View {
        AddAlarmView()
            .environmentObject(AppState())
    }
}
