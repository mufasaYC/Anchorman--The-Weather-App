//
//  PickerViewController.swift
//  Weather App
//
//  Created by Mustafa Yusuf on 30/12/17.
//  Copyright © 2017 Mustafa Yusuf. All rights reserved.
//

import UIKit
import MapKit

class PickerViewController: UIViewController {
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableVIew: UITableView!
	
	let locationManager = CLLocationManager()
	
	var pickerViewModel = PickerViewModel()
	var timer = Timer()
	
	private var searchSource: [MKLocalSearchCompletion]?
	
	lazy var searchCompleter: MKLocalSearchCompleter = {
		let searchComp = MKLocalSearchCompleter()
		searchComp.delegate = self
		return searchComp
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		searchBar.delegate = self
		tableVIew.delegate = self
		tableVIew.dataSource = self
		
		pickerViewModel.numberOfRows.bind(listener: { [unowned self] _ in
			self.tableVIew.reloadData()
		})
	}
	
	override func viewDidAppear(_ animated: Bool) {
		pickerViewModel.fetchData()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? WeatherViewController {
			destination.setupFor(city: pickerViewModel.city ?? "Chicago")
		}
	}
	
	@IBAction func logoutButton(_ sender: UIButton) {
		guard let appDomain = Bundle.main.bundleIdentifier else { return }
		UserDefaults.standard.removePersistentDomain(forName: appDomain)
		let sb = UIStoryboard(name: "Main", bundle: nil)
		let vc1 = sb.instantiateViewController(withIdentifier: "Welcome")
		present(vc1, animated: true, completion: nil)
	}
	
	@IBAction func getLocation(_ sender: UIButton) {
		
		self.locationManager.requestWhenInUseAuthorization()
		
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
			locationManager.startUpdatingLocation()
		} else {
			displayAlert(title: "Enable location servies", message: "Kindly allow us to use your location in app to serve you better")
		}
		
	}
	
}

extension PickerViewController: CLLocationManagerDelegate {
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let x = locations.last?.coordinate else { return }
		locationManager.stopUpdatingLocation()
		let geoCoder = CLGeocoder()
		let location = CLLocation(latitude: x.latitude, longitude: x.longitude)
		geoCoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
			if error != nil {
				self?.displayAlert(title: "Oops", message: "Could not locate your city")
				return
			}
			
			let placeArray = placemarks as [CLPlacemark]!
			var placeMark: CLPlacemark!
			placeMark = placeArray?[0]
			if let city = placeMark.locality
			{
				self?.pickerViewModel.city = city
				self?.performSegue(withIdentifier: "weather", sender: self)
			}
		}
	}
	
}

extension PickerViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		timer.invalidate()
		timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: false)
	}
	
	@objc func timerDidFire() {
		if !(searchBar.text?.isEmpty ?? true) {
			searchCompleter.queryFragment = searchBar.text!
		}
	}
	
	
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		view.endEditing(true)
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		view.endEditing(true)
	}
	
	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		searchBar.resignFirstResponder()
		return true
	}
	
}

extension PickerViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return pickerViewModel.numberOfRows.value ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = self.tableVIew.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		cell.textLabel?.text = pickerViewModel.title(at: indexPath.row)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		view.endEditing(true)

		let x = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		x.frame = view.frame
		self.view.addSubview(x)
		x.startAnimating()
		
		pickerViewModel.findCity(title: pickerViewModel.title(at: indexPath.row), completionHandler: { [weak self] city in
			
			if city == nil {
				//COULD NOT FIND CITY ERROR
				print("Could not find city")
				self?.displayAlert(title: "Oops!", message: "Did you select a country or a city?")
			} else {
				self?.performSegue(withIdentifier: "weather", sender: self)
			}
			x.stopAnimating()
			self?.view.willRemoveSubview(x)
		})
		
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		view.endEditing(true)
	}
}

extension PickerViewController: MKLocalSearchCompleterDelegate {
	
	func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
		pickerViewModel.updateSearch(completer: completer)
	}
	
	func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
		//handle the error
		displayAlert(title: "Autofillin failed", message: "Too many requests made, please use the search when neccessary")
		print(error.localizedDescription)
	}
}

