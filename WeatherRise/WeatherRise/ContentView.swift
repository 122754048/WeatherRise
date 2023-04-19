import SwiftUI
import UserNotifications
import AVFoundation
import CoreLocation
import CoreData

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddAlarmView = false
    @State private var temperature: String = "N/A"
    @State private var humidity: String = "N/A"

    var body: some View {
        NavigationView {
            VStack {
                Text("Weather Rise")
                    .font(.largeTitle)
                    .bold()
                    .padding()

                HStack {
                    Text("温度")
                        .font(.headline)
                    Spacer()
                    Text("湿度")
                        .font(.headline)
                }
                .padding(.horizontal)

                HStack {
                    Text(temperature)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.blue)
                    Spacer()
                    Text(humidity)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .onAppear {
                    appState.fetchWeatherData(location: appState.locationManager.location) { weatherInfo in
                        if let weatherInfo = weatherInfo,
                           let (temp, _) = appState.parseWeatherInfo(weatherInfo: weatherInfo.toDictionary()),
                           let hum = appState.parseHumidity(weatherInfo: weatherInfo.toDictionary()) {
                            DispatchQueue.main.async {
                                temperature = "\(temp)℃"
                                humidity = "\(hum)%"
                            }
                        }
                    }
                }

                List {
                    ForEach(appState.alarms) { customAlarmObject in
                        AlarmRowView(customAlarmObject: customAlarmObject)
                    }
                    .onDelete(perform: appState.deleteAlarm(at:))
                }

                Spacer()
            }
            .navigationBarTitle("天气闹钟", displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        showingAddAlarmView = true
                    }) {
                        Image(systemName: "plus")
                    }
            )
            .sheet(isPresented: $showingAddAlarmView) {
                AddAlarmView()
                    .environmentObject(appState)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
