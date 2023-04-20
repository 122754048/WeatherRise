import SwiftUI
import UserNotifications
import AVFoundation
import CoreLocation
import CoreData
import Foundation

// Add a WeatherInfo struct that will represent your fetched weather data
// Replace this with your own implementation
struct WeatherInfo {
    struct MainWeatherInfo {
        var temp: Double
        var humidity: Int
    }

    struct WeatherDescription {
        var description: String
    }

    var main: MainWeatherInfo
    var weather: [WeatherDescription]
}

extension WeatherInfo {
    func toDictionary() -> [String: Any] {
        return [
            "main": [
                "temp": main.temp,
                "humidity": main.humidity
            ],
            "weather": weather.map { ["description": $0.description] }
        ]
    }
}

class AppState: ObservableObject {
    @Published var alarms: [CustomAlarmObject] = []
    let locationManager = CLLocationManager()

    var managedObjectContext: NSManagedObjectContext!

    init() {
        let container = NSPersistentContainer(name: "WeatherRiseModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        managedObjectContext = container.viewContext
        loadAlarms()
    }

    private func loadAlarms() {
        let fetchRequest: NSFetchRequest<StoredAlarmEntity> = StoredAlarmEntity.fetchRequest()

        do {
            let alarmEntities = try managedObjectContext.fetch(fetchRequest)
            alarms = alarmEntities.map { alarmEntity in
                CustomAlarmObject(
                    id: alarmEntity.id!,
                    time: alarmEntity.time!,
                    label: alarmEntity.label!,
                    weekdays: Set<Int>((alarmEntity.weekdays! as! Set<NSNumber>).map { $0.intValue }),
                    isEnabled: alarmEntity.isEnabled
                )
            }
        } catch {
            print("Failed to fetch alarms: \(error)")
        }
    }

    func saveAlarms() {
        do {
            for alarmObject in alarms {
                let fetchRequest: NSFetchRequest<StoredAlarmEntity> = StoredAlarmEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", alarmObject.id as CVarArg)
                let fetchedResults = try managedObjectContext.fetch(fetchRequest)

                let alarmEntity: StoredAlarmEntity
                if let existingEntity = fetchedResults.first {
                    alarmEntity = existingEntity
                } else {
                    alarmEntity = StoredAlarmEntity(context: managedObjectContext)
                    alarmEntity.id = alarmObject.id
                }

                alarmEntity.time = alarmObject.time
                alarmEntity.label = alarmObject.label
                alarmEntity.weekdays = NSSet(array: alarmObject.weekdays.map { NSNumber(value: $0) })
                alarmEntity.isEnabled = alarmObject.isEnabled
            }

            try managedObjectContext.save()
        } catch {
            print("Failed to save alarms: \(error)")
        }
    }

    func parseWeatherInfo(weatherInfo: [String: Any]) -> (Double, String)? {
        guard let main = weatherInfo["main"] as? [String: Any],
              let temp = main["temp"] as? Double,
              let weatherArray = weatherInfo["weather"] as? [[String: Any]],
              let weather = weatherArray.first,
              let description = weather["description"] as? String else {
            return nil
        }
        
        return (temp, description)
    }

    func fetchWeatherData(location: CLLocation?, completion: @escaping (WeatherInfo?) -> Void) {
        guard let location = location else {
            completion(nil)
            return
        }

        let apiKey = "8f3124e087972946c96f0c697eb1e00b"
        let url = URL(string: "https://api.weatherstack.com/current?access_key=\(apiKey)&query=\(location.coordinate.latitude),\(location.coordinate.longitude)&units=m")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  error == nil else {
                completion(nil)
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let weatherInfo = json,
                      let (temp, description) = self.parseWeatherInfo(weatherInfo: weatherInfo) else {
                    completion(nil)
                    return
                }

                let weather = WeatherInfo(
                    main: WeatherInfo.MainWeatherInfo(temp: temp, humidity: 0),
                    weather: [WeatherInfo.WeatherDescription(description: description)]
                )

                completion(weather)
            } catch {
                completion(nil)
            }
        }

        task.resume()
    }

    func parseHumidity(weatherInfo: [String: Any]) -> Int? {
        if let main = weatherInfo["main"] as? [String: Any],
           let humidity = main["humidity"] as? Int {
            return humidity
        }
        return nil
    }
    func deleteAlarm(at offsets: IndexSet) {
        let alarmIdsToDelete = offsets.map { alarms[$0].id }

        for alarmId in alarmIdsToDelete {
            let fetchRequest: NSFetchRequest<StoredAlarmEntity> = StoredAlarmEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", alarmId as CVarArg)

            do {
                let fetchedResults = try managedObjectContext.fetch(fetchRequest)
                if let alarmEntityToDelete = fetchedResults.first {
                    managedObjectContext.delete(alarmEntityToDelete)
                }
            } catch {
                print("Failed to fetch alarm with id \(alarmId): \(error)")
            }
        }

        alarms.remove(atOffsets: offsets)

        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to delete alarm: \(error)")
        }
    }
}
