//
//  WeatherTimeCell.swift
//  Weather App
//
//  Created by Mustafa Yusuf on 30/12/17.
//  Copyright © 2017 Mustafa Yusuf. All rights reserved.
//

import UIKit

class WeatherTimeCell: UICollectionViewCell {
    
	@IBOutlet weak var temperatureLabel: UILabel!
	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var timeLabel: UILabel!
	
	func configureCell(weatherData: WeatherData, textColor: UIColor) {
		timeLabel.text = weatherData.time.timeOfDay()
		temperatureLabel.text = String(describing: weatherData.tempC) + "°"
		timeLabel.textColor = textColor
		temperatureLabel.textColor = textColor
		iconImageView.image = UIImage()
		iconImageView.downloadedFrom(url: URL(string: "http://" + String(describing: weatherData.iconImageURL.suffix(weatherData.iconImageURL.count - 2))) ?? URL(string: "http://cdn.apixu.com/weather/64x64/night/116.png")!)
	}
	
}

extension UIImageView {
	
	func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
		contentMode = mode
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
				let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
				let data = data, error == nil,
				let image = UIImage(data: data)
				else { return }
			DispatchQueue.main.async() { () -> Void in
				self.image = image
			}
			}.resume()
	}
	func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
		guard let url = URL(string: link) else { return }
		downloadedFrom(url: url, contentMode: mode)
	}
	
}


extension Date {
	
	func timeOfDay() -> String {
		
		let calendar = Calendar(identifier: .gregorian)
		let hour = calendar.component(.hour, from: self)
		if hour > 12 {
			return "\(hour-12) pm"
		}
		
		return "\(hour == 0 ? 12: hour) am"
	}
	
	
}
