//
//  AlarmEntity+CoreDataProperties.swift
//  WeatherRise
//
//  Created by 赵晨旭 on 4/17/23.
//
//

import Foundation
import CoreData


extension AlarmEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AlarmEntity> {
        return NSFetchRequest<AlarmEntity>(entityName: "AlarmEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var time: Date?
    @NSManaged public var label: String?
    @NSManaged public var weekdays: NSSet?
    @NSManaged public var isEnabled: Bool

}

extension AlarmEntity : Identifiable {

}
