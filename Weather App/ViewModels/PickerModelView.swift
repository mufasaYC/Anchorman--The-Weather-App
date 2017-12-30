//
//  PickerModelView.swift
//  Weather App
//
//  Created by Mustafa Yusuf on 30/12/17.
//  Copyright © 2017 Mustafa Yusuf. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PickerViewModel {
	
	private var searchSource: [String]
	
	init() {
		searchSource = [String]()
	}
	
	func title(at index: Int) -> String {
		return searchSource[index]
	}
	
	var numberOfRows: Box<Int?> = Box(nil)
	
	func updateSearch(completer: MKLocalSearchCompleter) {
		searchSource = completer.results.map { $0.title }
		numberOfRows.value = searchSource.count
	}
	
	var history: [String]?
	
	var city: String?
	
	func findCity(title: String, completionHandler: @escaping (String?) -> ()) {
		let request = MKLocalSearchRequest()
		request.naturalLanguageQuery = title
		let search = MKLocalSearch(request: request)
		
		search.start { [weak self] response, error in
			if error == nil {
				for i in (response?.mapItems)! {
					self?.city = i.placemark.locality ?? ""
					completionHandler(i.placemark.locality)
				}
				completionHandler(nil)
			} else {
				completionHandler(nil)
			}
		}
	}
	
	func fetchData() {
		
		guard let appDelegate =
			UIApplication.shared.delegate as? AppDelegate else {
				return
		}
		
		let managedContext =
			appDelegate.persistentContainer.viewContext
		
		//2
		let fetchRequest =
			NSFetchRequest<NSManagedObject>(entityName: "City")
		
		//3
		do {
			let allData = try managedContext.fetch(fetchRequest)
			for i in allData {
				let x = i.value(forKey: "name") as? String ?? ""
				searchSource.append(x)
			}
			numberOfRows.value = searchSource.count
		} catch let error as NSError {
			print("Could not fetch. \(error), \(error.userInfo)")
		}
		
	}

}



