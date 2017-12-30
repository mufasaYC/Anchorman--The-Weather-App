//
//  WeatherViewModel.swift
//  Weather App
//
//  Created by Mustafa Yusuf on 30/12/17.
//  Copyright © 2017 Mustafa Yusuf. All rights reserved.
//

import Foundation
import Alamofire

class Routes {
	
	func fetchWeatherData(city: String, completionHandler: @escaping ( [WeatherData]?, WeatherTodayStats?,  Error? ) -> ()) {
		
		Alamofire.request("http://api.apixu.com/v1/forecast.json?key=YOURAPI", method: .get, parameters: ["q": city]).responseJSON(completionHandler: { res in
			
			switch res.result {
			case .success(let JSON):
				if res.response?.statusCode == 200 || res.response?.statusCode == 201 {
					if let d: NSDictionary = JSON as? NSDictionary {
						if let forecast = d["forecast"] as? NSDictionary {
							if let forecastToday = forecast["forecastday"] as? [NSDictionary] {
								let stats = WeatherTodayStats(dictionary: forecastToday.first!["day"] as? NSDictionary ?? NSDictionary())
								if let hour = forecastToday.first?["hour"] as? [NSDictionary] {
									var weatherDataArray = [WeatherData]()
									for i in hour {
										weatherDataArray.append(WeatherData(dictionary: i))
									}
									completionHandler(weatherDataArray, stats, nil)
									//COMPLETION HANDLER
								}
							}
						}
					}
				} else {
					
				}
				
			case .failure(let error):
				print(error)
				completionHandler(nil, nil, error)
			}
			
		})
		
	}
	
}
