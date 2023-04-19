import SwiftUI

struct AlarmRowView: View {
    var customAlarmObject: CustomAlarmObject

    var body: some View {
        HStack {
            Text(customAlarmObject.label)
                .font(.title2)
                .bold()

            Spacer()

            VStack {
                Text(customAlarmObject.timeString)
                    .font(.title3)
                    .bold()

                Text("Weekdays: \(customAlarmObject.weekdaysString)")
                    .font(.subheadline)
            }
        }
        .padding()
        .background(customAlarmObject.isEnabled ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
