//
//  WeatherAPI.swift
//  Weather App
//
//  Created by Mustafa Yusuf on 30/12/17.
//  Copyright © 2017 Mustafa Yusuf. All rights reserved.
//

import Foundation
import CoreData

struct WeatherData {
	
	var time: Date
	var tempC: Double
	var isDay: Bool
	var condition: String
	var iconImageURL: String
	var windKPH: Double
	var humidity: Int
	var chanceRain: String
	
	init(dictionary: NSDictionary) {
		time = Date(timeIntervalSince1970: TimeInterval(dictionary["time_epoch"] as? Int ?? 0))
		tempC = dictionary["temp_c"] as? Double ?? 0.0
		isDay = dictionary["is_day"] as? Bool ?? false
		if let c = (dictionary["condition"] as? NSDictionary) {
			condition = c["text"] as? String ?? ""
			iconImageURL = c["icon"] as? String ?? ""
		} else {
			condition = "NA"
			iconImageURL = "NA"
		}
		windKPH = dictionary["wind_kph"] as? Double ?? 0.0
		humidity = dictionary["humidity"] as? Int ?? 0
		chanceRain = dictionary["chance_of_rain"] as? String ?? ""
	}
	
	init(managedObject: NSManagedObject) {
		time = managedObject.value(forKey: "time") as? Date ?? Date()
		tempC = managedObject.value(forKey: "tempC") as? Double ?? 0.0
		isDay = managedObject.value(forKey: "isDay") as? Bool ?? false
		condition = managedObject.value(forKey: "condition") as? String ?? ""
		iconImageURL = managedObject.value(forKey: "iconImageURL") as? String ?? ""
		windKPH = managedObject.value(forKey: "windKPH") as? Double ?? 0.0
		humidity = managedObject.value(forKey: "humidity") as? Int ?? 0
		chanceRain = managedObject.value(forKey: "chanceRain") as? String ?? ""
	}
	
}

struct WeatherTodayStats {
	
	var maxtempC: Double
	var mintempC: Double
	var condition: String
	var iconImageURL: String
	var maxWindKPH: Double
	var avgHumidity: Int
	
	init() {
		maxtempC = 0.0
		mintempC = 0.0
		condition = ""
		iconImageURL = ""
		maxWindKPH = 0.0
		avgHumidity = 0
	}
	
	init(managedObject: NSManagedObject) {
		maxtempC = managedObject.value(forKey: "maxtempC") as? Double ?? 0.0
		mintempC = managedObject.value(forKey: "mintempC") as? Double ?? 0.0
		condition = managedObject.value(forKey: "condition") as? String ?? ""
		iconImageURL = managedObject.value(forKey: "iconImageURL") as? String ?? ""
		maxWindKPH = managedObject.value(forKey: "maxWindKPH") as? Double ?? 0.0
		avgHumidity = managedObject.value(forKey: "avgHumidity") as? Int ?? 0
	}

	
	init(dictionary: NSDictionary) {
		print(dictionary["maxtemp_c"] as? Double ?? "WHAAA")
		maxtempC = dictionary["maxtemp_c"] as? Double ?? 0.0
		mintempC = dictionary["mintemp_c"] as? Double ?? 0.0
		if let c = (dictionary["condition"] as? NSDictionary) {
			condition = c["text"] as? String ?? ""
			iconImageURL = c["icon"] as? String ?? ""
		} else {
			condition = "NA"
			iconImageURL = "NA"
		}
		
		maxWindKPH = dictionary["maxwind_kph"] as? Double ?? 0.0
		avgHumidity = dictionary["avghumidity"] as? Int ?? 0
	}
	
}
