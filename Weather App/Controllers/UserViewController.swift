
//
//  UserViewController.swift
//  Weather App
//
//  Created by Mustafa Yusuf on 30/12/17.
//  Copyright © 2017 Mustafa Yusuf. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

	let viewModel = UserViewModel()
	
	@IBOutlet weak var nameLabel: UILabel!
	
	@IBOutlet weak var profileImageView: UIImageView!
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		nameLabel.text = viewModel.name ?? ""
		profileImageView.downloadedFrom(url: viewModel.imageURL ?? URL(string: "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png")!)
	}
	
}
