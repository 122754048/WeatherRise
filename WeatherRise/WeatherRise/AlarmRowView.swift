import SwiftUI

struct AlarmRowView: View {
    @ObservedObject var alarmObject: Alarm

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(alarmObject.alarm.formattedTime)
                    .font(.title2)
                    .bold()
                TextField("Label", text: $alarmObject.label.wrappedValue)
            }
            Spacer()
            Toggle("", isOn: $alarmObject.isEnabled)
        }
    }
}

struct AlarmRowView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmRowView(alarmObject: AlarmObject(alarm: Alarm(time: Date(), label: "Test"), isEnabled: true))
    }
}
