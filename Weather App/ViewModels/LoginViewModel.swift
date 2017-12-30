//
//  LoginViewModel.swift
//  Weather App
//
//  Created by Mustafa Yusuf on 30/12/17.
//  Copyright © 2017 Mustafa Yusuf. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class LoginViewModel {

	var name: String?
	var imageURL: URL?
	
	func loadFBprofile(completionHandler: @escaping (Error?) -> ()) {
		
		FBSDKProfile.loadCurrentProfile(completion: { [weak self] profile, error in
			
			if error == nil {
				self?.name = profile?.firstName
				self?.imageURL = profile?.imageURL(for: .square, size: CGSize(width: 200, height: 200))
				completionHandler(nil)
			} else {
				completionHandler(error)
			}
		})
	}
	
}
