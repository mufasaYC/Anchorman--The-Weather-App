//
//  WeatherViewModel.swift
//  Weather App
//
//  Created by Mustafa Yusuf on 30/12/17.
//  Copyright © 2017 Mustafa Yusuf. All rights reserved.
//

import UIKit
import CoreData
import Foundation

enum Theme {
	case day, night
}

class WeatherViewModel {
	
	private var todayStats = WeatherTodayStats()
	private var weatherData = [WeatherData]()
	private var theme = Theme.day
	var container: NSPersistentContainer? =
		(UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

	//Table View func and var
	var numberOfSections: Int {
			return 1
	}
	var numberOfRow: Int {
		return weatherData.count
	}
	
	func weatherDataForCell(at rowNumber: Int) -> WeatherData {
		return weatherData[rowNumber]
	}
	
	//Binding variable
	var didFetch: Box<String?> = Box(nil)
	
	//Label Initialising Variables
	var city = String()
	var avgHumidity: String {
		return "Average Humidity is " + String(describing: todayStats.avgHumidity) + "%"
	}
	var rainChance: String {
		//checking if current hour matches the forecast hour
		let calendar = Calendar(identifier: .gregorian)
		let hour = calendar.component(.hour, from: Date())
		for i in weatherData {
			if hour == calendar.component(.hour, from: i.time) {
				return "Chance of rain is " + String(describing: i.chanceRain) + "%"
			}
		}
		return ""
	}
	
	var windDescription: String {
		return "Highest wind speeds to " + String(describing: todayStats.maxWindKPH) + " km/h"
	}
	
	var condition: String {
		let calendar = Calendar(identifier: .gregorian)
		let hour = calendar.component(.hour, from: Date())
		for i in weatherData {
			if hour == calendar.component(.hour, from: i.time) {
				return String(describing: i.condition)
			}
		}
		return String(describing: todayStats.condition)
	}
	
	var currentTemperature: String {
		let calendar = Calendar(identifier: .gregorian)
		let hour = calendar.component(.hour, from: Date())
		for i in weatherData {
			if hour == calendar.component(.hour, from: i.time) {
				return String(describing: i.tempC) + "°"
			}
		}
		return String(describing: todayStats.maxtempC) + "°"
	}
	
	var highLowDescription: String {
		//return "High " + todayStats.maxtempC + "°" + " / Low " + todayStats.mintempC + "°"
		return "High " + String(describing: todayStats.maxtempC) + "°" + " / Low " + String(describing: todayStats.mintempC) + "°"
	}
	
	//isDay
	var isDay: Bool {
		let calendar = Calendar(identifier: .gregorian)
		let hour = calendar.component(.hour, from: Date())
		for i in weatherData {
			if hour == calendar.component(.hour, from: i.time) {
				theme = i.isDay ? .day : .night
				return i.isDay
			}
		}
		return true
	}
	
}

//Mark:- Fetch Forecast + Current Weather Report

extension WeatherViewModel {
	
	func fetchWeatherData(forCity: String) {
		let route = Routes()
		route.fetchWeatherData(city: forCity, completionHandler: { [weak self] data, stats, error in
			
			if error == nil {
				UserDefaults.standard.set(forCity, forKey: "city")
				if let s = stats {
					self?.todayStats = s
				}
				if let d = data {
					self?.weatherData = d
					self?.city = forCity
					self?.didFetch.value = forCity
				}
				self?.saveData()
			} else {
				print("Error in fetchWeatherData")
				//Handle Error
			}
		})
	}

}

//Mark:- Theme Related Function (Day night switch)

extension WeatherViewModel {
	
	func textColor() -> UIColor {
		if theme == .day {
			return UIColor(red: 76.0/255.0, green: 76.0/255.0, blue: 76.0/255.0, alpha: 1.0)
		}
		return .lightGray
	}
	
	func backgroundColor() -> UIColor {
		if theme == .day {
			return .white
		}
		return UIColor(white: 0.13, alpha: 1)
	}
	
	func sunMoonColor() -> UIColor {
		if theme == .day {
			return UIColor(red: 247.0/255.0, green: 223.0/255.0, blue: 102.0/255.0, alpha: 1)
		}
		return UIColor(white: 0.87, alpha: 1)
	}
	
}

//Mark:- CoreData save and fetch

extension WeatherViewModel {
	
	func fetchData() {
		retrieveStat()
		retrieveWeatherData()
	}
	
	func saveData() {
		
		saveStat(i: todayStats)
		
		deleteData(entityName: "Data")
		for i in weatherData {
			saveData(i: i)
		}

	}
	
	private func deleteData(entityName: String) {
		guard let appDelegate =
			UIApplication.shared.delegate as? AppDelegate else {
				return
		}
		let managedContext =
			appDelegate.persistentContainer.viewContext
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		
		do {
			try managedContext.execute(request)
			print("Deleted old records")
		} catch let error as NSError {
			print("Could not delete. \(error), \(error.userInfo)")
		}
	}
	
	private func saveCity(city: String) {
		guard let appDelegate =
			UIApplication.shared.delegate as? AppDelegate else {
				return
		}
		
		// 1
		let managedContext =
			appDelegate.persistentContainer.viewContext
		
		// 2
		let entity =
			NSEntityDescription.entity(forEntityName: "City",
									   in: managedContext)!
		
		let data = NSManagedObject(entity: entity,
								   insertInto: managedContext)
		
		// 3
		data.setValue(city, forKey: "name")
		
		// 4
		managedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

		do {
			try managedContext.save()
			print("SAVE CITY")
		} catch let error as NSError {
			print("Could not save. \(error), \(error.userInfo)")
		}
		
	}
	
	
	
	
	private func saveStat(i: WeatherTodayStats) {
		
		deleteData(entityName: "Stats")
		
		guard let appDelegate =
			UIApplication.shared.delegate as? AppDelegate else {
				return
		}
		
		// 1
		let managedContext =
			appDelegate.persistentContainer.viewContext
		
		// 2
		let entity =
			NSEntityDescription.entity(forEntityName: "Stats",
									   in: managedContext)!
		
		let data = NSManagedObject(entity: entity,
								   insertInto: managedContext)
		
		// 3
		data.setValue(i.maxtempC, forKey: "maxtempC")
		data.setValue(i.condition, forKey: "condition")
		data.setValue(i.avgHumidity, forKey: "avgHumidity")
		data.setValue(i.iconImageURL, forKey: "iconImageURL")
		data.setValue(i.maxWindKPH, forKey: "maxWindKPH")
		data.setValue(i.mintempC, forKey: "mintempC")
		
		// 4
		do {
			try managedContext.save()
			print("SAVE STAT")
		} catch let error as NSError {
			print("Could not save. \(error), \(error.userInfo)")
		}

	}
	
	private func saveData(i: WeatherData) {
		
		guard let appDelegate =
			UIApplication.shared.delegate as? AppDelegate else {
				return
		}
		
		// 1
		let managedContext =
			appDelegate.persistentContainer.viewContext
		
		// 2
		let entity =
			NSEntityDescription.entity(forEntityName: "Data",
									   in: managedContext)!
		
		let data = NSManagedObject(entity: entity,
									 insertInto: managedContext)
		
		// 3
		data.setValue(i.chanceRain, forKey: "chanceRain")
		data.setValue(i.condition, forKey: "condition")
		data.setValue(i.humidity, forKey: "humidity")
		data.setValue(i.iconImageURL, forKey: "iconImageURL")
		data.setValue(i.isDay, forKey: "isDay")
		data.setValue(i.tempC, forKey: "tempC")
		data.setValue(i.time, forKey: "time")
		data.setValue(i.windKPH, forKey: "windKPH")
		
		// 4
		do {
			try managedContext.save()
			print("SAVE DATA")
		} catch let error as NSError {
			print("Could not save. \(error), \(error.userInfo)")
		}
	}
	
	private func retrieveStat() {
		
		if let c = UserDefaults.standard.string(forKey: "city") {
			city = c
			saveCity(city: c)
		}
		
		guard let appDelegate =
			UIApplication.shared.delegate as? AppDelegate else {
				return
		}
		
		let managedContext =
			appDelegate.persistentContainer.viewContext
		
		//2
		let fetchRequest =
			NSFetchRequest<NSManagedObject>(entityName: "Stats")
		
		//3
		do {
			let allData = try managedContext.fetch(fetchRequest)
			if allData.count > 0 {
				todayStats = WeatherTodayStats(managedObject: allData.first!)
			}
		} catch let error as NSError {
			print("Could not fetch. \(error), \(error.userInfo)")
		}
		
	}
	
	private func retrieveWeatherData() {
		if let c = UserDefaults.standard.string(forKey: "city") {
			city = c
		}
		
		guard let appDelegate =
			UIApplication.shared.delegate as? AppDelegate else {
				return
		}
		
		let managedContext =
			appDelegate.persistentContainer.viewContext
		
		//2
		let fetchRequest =
			NSFetchRequest<NSManagedObject>(entityName: "Data")
		
		//3
		do {
			let allData = try managedContext.fetch(fetchRequest)
			for i in allData {
				weatherData.append(WeatherData(managedObject: i))
			}
			didFetch.value = "fetched"
		} catch let error as NSError {
			print("Could not fetch. \(error), \(error.userInfo)")
		}
	}


	
}
