import SwiftUI
import UserNotifications
import AVFoundation
import CoreLocation
import CoreData

class AppState: NSObject, ObservableObject, AVSpeechSynthesizerDelegate, CLLocationManagerDelegate {
    @Published var isSpeaking = false
    @Published var alarms: [AlarmObject] {
        didSet {
            saveAlarms()
        }
    }
    var managedObjectContext: NSManagedObjectContext!
    let speechSynthesizer = AVSpeechSynthesizer()
    let locationManager = CLLocationManager()

    override init() {
        super.init()
        speechSynthesizer.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func fetchWeatherData(location: CLLocation?, completion: @escaping (String?) -> Void) {
        guard let location = location else {
            completion(nil)
            return
        }
        
        let apiKey = "11ba0f7ccd0cffc622e0de06c21d380b"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)&units=metric&lang=zh_cn"
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to get weather data: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let weather = json["weather"] as? [[String: Any]],
                  let main = json["main"] as? [String: Any],
                  let temperature = main["temp"] as? Double else {
                completion(nil)
                return
            }
            
            let weatherDescription = weather.first?["description"] as? String ?? ""
            let humidity = main["humidity"] as? Int ?? 0
            let weatherInfo = "现在的天气：\(weatherDescription)，温度：\(temperature)℃，湿度：\(humidity)%。"
            completion(weatherInfo)
        }
        
        task.resume()
    }

    func parseWeatherInfo(weatherInfo: String) -> (temperature: Double, weatherCondition: String)? {
        let temperaturePattern = "(\\d+)([\\.\\d+]+)?℃"
        let weatherConditionPattern = "(?<=建议穿).+"

        if let temperatureRange = weatherInfo.range(of: temperaturePattern, options: .regularExpression),
           let weatherConditionRange = weatherInfo.range(of: weatherConditionPattern, options: .regularExpression) {
            let temperatureString = weatherInfo[temperatureRange]
            let temperature = Double(temperatureString.dropLast(1)) ?? 0.0
            let weatherCondition = String(weatherInfo[weatherConditionRange])
            return (temperature, weatherCondition)
        } else {
            return nil
        }
    }

    func speak(weatherInfo: String) {
        let speechUtterance = AVSpeechUtterance(string: weatherInfo)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        speechSynthesizer.speak(speechUtterance)
        isSpeaking = true
    }
    func deleteAlarm(at offsets: IndexSet) {
        alarms.remove(atOffsets: offsets)
    }
    func parseHumidity(weatherInfo: String) -> Int? {
        let humidityPattern = "湿度：(\\d+)%"
        
        if let humidityRange = weatherInfo.range(of: humidityPattern, options: .regularExpression) {
            let humidityString = weatherInfo[humidityRange]
            let digitsRange = humidityString.rangeOfCharacter(from: .decimalDigits)
            let humidity = Int(humidityString[digitsRange!]) ?? 0
            return humidity
        } else {
            return nil
        }
    }
    func addAlarm(alarmObject: AlarmObject) {
        alarms.append(alarmObject)
    }
    func loadAlarms() {
        let fetchRequest: NSFetchRequest<AlarmEntity> = AlarmEntity.fetchRequest()

        do {
            let alarmEntities = try managedObjectContext.fetch(fetchRequest)
            alarms = alarmEntities.map { AlarmObject(alarmEntity: $0) }
        } catch {
            print("Failed to load alarms from Core Data: \(error.localizedDescription)")
        }
    }
    func saveAlarms() {
        // 1. 删除 Core Data 中的所有现有 AlarmEntity
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AlarmEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedObjectContext.execute(deleteRequest)
        } catch {
            print("Error deleting existing AlarmEntity objects: \(error)")
        }

        // 2. 将当前的闹钟数据保存到 Core Data
        for alarmObject in alarms {
            let alarmEntity = AlarmEntity(context: managedObjectContext)
            alarmEntity.id = alarmObject.alarm.id
            alarmEntity.time = alarmObject.alarm.time
            alarmEntity.label = alarmObject.alarm.label
            alarmEntity.weekdays = alarmObject.alarm.weekdays as NSSet
            alarmEntity.isEnabled = alarmObject.isEnabled // 修复此处的错误
        }
        
        // 3. 保存上下文以提交更改
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving alarms to Core Data: \(error)")
        }
    }
}

@main
struct WeatherRiseApp: App {
    @StateObject private var appState = AppState()

    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherRiseModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    init() {
        appState.managedObjectContext = persistentContainer.viewContext
        appState.loadAlarms() // 加载已保存的闹钟数据
        configureNotifications()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .environmentObject(appState)
        }
    }

    func configureNotifications() {
        // ...
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
