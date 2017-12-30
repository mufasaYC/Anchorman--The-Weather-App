//
//  WeatherViewController.swift
//  Weather App
//
//  Created by Mustafa Yusuf on 30/12/17.
//  Copyright © 2017 Mustafa Yusuf. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {

	var weatherViewModel = WeatherViewModel()
	
	@IBOutlet weak var sunMoonView: UIView!
	@IBOutlet weak var rainLabel: UILabel!
	@IBOutlet weak var humidityLabel: UILabel!
	@IBOutlet weak var windDataLabel: UILabel!
	@IBOutlet weak var weatherConditionLabel: UILabel!
	@IBOutlet weak var currentTemperatureLabel: UILabel!
	@IBOutlet weak var highLowLabel: UILabel!
	@IBOutlet weak var cityLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		collectionView.dataSource = self
		weatherViewModel.didFetch.bind(listener: { [unowned self] _ in
			self.collectionView.reloadData()
			self.refreshLabels()
			self.theme()
		})
		setupFor(city: nil) //when nil, checks for core data else fetches city
    }
	
	override func viewWillAppear(_ animated: Bool) {
		_ = weatherViewModel.isDay
		theme()
	}
	
	func refreshLabels() {
		rainLabel.text = weatherViewModel.rainChance
		humidityLabel.text = weatherViewModel.avgHumidity
		windDataLabel.text = weatherViewModel.windDescription
		weatherConditionLabel.text = weatherViewModel.condition
		currentTemperatureLabel.text = weatherViewModel.currentTemperature
		highLowLabel.text = weatherViewModel.highLowDescription
		cityLabel.text = weatherViewModel.city
	}
	
	func setupFor(city: String?) {
		if UserDefaults.standard.string(forKey: "city") != nil && city == nil {
			weatherViewModel.fetchData()
			return
		}
		guard let c = city else { return }
		weatherViewModel.fetchWeatherData(forCity: c)
	}
	
}

extension WeatherViewController: UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return weatherViewModel.numberOfSections
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return weatherViewModel.numberOfRow
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WeatherTimeCell
		cell.configureCell(weatherData: weatherViewModel.weatherDataForCell(at: indexPath.row), textColor: weatherViewModel.textColor())
		return cell
	}
	
}

extension WeatherViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 128, height: 110)
	}
}

extension WeatherViewController {
	
	func theme() {
		
		_ = weatherViewModel.isDay
		
		let finalColor: UIColor = weatherViewModel.textColor()
		
		let changeColor = CATransition()
		changeColor.type = kCATransitionFade
		changeColor.duration = 5.0
		
		CATransaction.begin()
		
		rainLabel.textColor = finalColor
		cityLabel.textColor = finalColor
		currentTemperatureLabel.textColor = finalColor
		humidityLabel.textColor = finalColor
		highLowLabel.textColor = finalColor
		weatherConditionLabel.textColor = finalColor
		windDataLabel.textColor = finalColor
		
		CATransaction.setCompletionBlock { [weak self] in
			self?.rainLabel.layer.add(changeColor, forKey: nil)
			self?.cityLabel.layer.add(changeColor, forKey: nil)
			self?.currentTemperatureLabel.layer.add(changeColor, forKey: nil)
			self?.humidityLabel.layer.add(changeColor, forKey: nil)
			self?.highLowLabel.layer.add(changeColor, forKey: nil)
			self?.weatherConditionLabel.layer.add(changeColor, forKey: nil)
			self?.windDataLabel.layer.add(changeColor, forKey: nil)
		}
		
		CATransaction.commit()
		
		UIView.animate(withDuration: 5.0, animations: { [weak self] in
			
			self?.view.backgroundColor = self?.weatherViewModel.backgroundColor()
			self?.sunMoonView.backgroundColor = self?.weatherViewModel.sunMoonColor()
			
		})
		
		collectionView.reloadData()

	}
	
}
