import SwiftUI
import CoreData

class AppState: ObservableObject {
    @Published var alarms: [CustomAlarmObject] = []

    private var managedObjectContext: NSManagedObjectContext!

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
                    weekdays: alarmEntity.weekdays!,
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
                alarmEntity.weekdays = alarmObject.weekdays
                alarmEntity.isEnabled = alarmObject.isEnabled
            }

            try managedObjectContext.save()
        } catch {
            print("Failed to save alarms: \(error)")
        }
    }
}
