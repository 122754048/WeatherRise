import SwiftUI

struct AlarmRowView: View {
    @ObservedObject var customAlarmObject: CustomAlarmObject

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(customAlarmObject.timeString)
                        .font(.system(size: 50, weight: .medium))
                    Text(customAlarmObject.weekdaysString)
                        .font(.system(size: 15))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(minHeight: 80)
                Spacer()
                RoundedRectangle(cornerRadius: 16)
                    .fill(customAlarmObject.isEnabled ? Color.blue : Color.gray)
                    .frame(width: 51, height: 31)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .padding(2)
                            .offset(x: customAlarmObject.isEnabled ? 10 : -10)
                    )
                    .onTapGesture {
                        customAlarmObject.isEnabled.toggle()
                    }
                    .animation(.spring(), value: customAlarmObject.isEnabled)
            }
            .padding(.horizontal, 16) // Increase the horizontal padding to 16 points
            .padding(.top, 8)
            .padding(.bottom, 4)
        }
        .background(Color(.systemBackground)) // Set the background color to match the system background
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color(.systemBackground)) // Set the list row background color to match the system background
        .padding(.vertical, 4) // Add vertical padding between the rows
    }
}
