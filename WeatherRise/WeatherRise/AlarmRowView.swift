import SwiftUI

struct AlarmRowView: View {
    @ObservedObject var alarmObject: AlarmObject

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(alarmObject.alarm.timeString, formatter: DateFormatter.timeOnly)
                    .font(.system(size: 50, design: .rounded))

                Text(alarmObject.alarm.label ?? "Label")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.red)
            }
            Spacer()
            Toggle("", isOn: $alarmObject.isEnabled)
                .labelsHidden()
        }
    }
}

struct AlarmRowView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmRowView(alarmObject: AlarmObject(alarm: Alarm(id: UUID(), time: Date(), label: "Label", weekdays: [], isEnabled: true), isEnabled: true))
            .previewLayout(.sizeThatFits)
    }
}
