//
//  ViewController.swift
//  Weather App
//
//  Created by Mustafa Yusuf on 29/12/17.
//  Copyright © 2017 Mustafa Yusuf. All rights reserved.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import GoogleSignIn

class ViewController: UIViewController {
	
	@IBOutlet weak var facebookView: UIView!
	@IBOutlet weak var googleSignInView: GIDSignInButton!
	
	let x = UIActivityIndicatorView()
	var viewModel = LoginViewModel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		let faceBookLoginButton = LoginButton(readPermissions: [.publicProfile])
		faceBookLoginButton.frame = facebookView.bounds
		faceBookLoginButton.delegate = self
		facebookView.addSubview(faceBookLoginButton)
		googleSignInView.style = .standard
		GIDSignIn.sharedInstance().delegate = self
		GIDSignIn.sharedInstance().uiDelegate = self
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? UserViewController {
			destination.viewModel.name = viewModel.name
			destination.viewModel.imageURL = viewModel.imageURL
		}
	}

	func successfulLogin() {
		let when = DispatchTime.now() + 1
		DispatchQueue.main.asyncAfter(deadline: when, execute: { [weak self] in
			self?.performSegue(withIdentifier: "success", sender: nil)
		})
	}
	
}

//Mark:- Google Sign In Delegates

extension ViewController: GIDSignInDelegate, GIDSignInUIDelegate {
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
		// ...
		if let error = error {
			displayAlert(title: "Failed", message: "Signing in with google failed, try again")
			print("Google Sign In Error: \n", error)
			return
		}
		
		guard let authentication = user.authentication else { return }
		let _ = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
												 accessToken: authentication.accessToken)
		print("Google Signed In")
		viewModel.name = user.profile.name
		viewModel.imageURL = user.profile.imageURL(withDimension: UInt(200))
		
		UserDefaults.standard.set("Google", forKey: "auth")

		successfulLogin()

		//performSegue(withIdentifier: "success", sender: self)
		
	}
	
	func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
		displayAlert(title: "Disconnected", message: "Your Google account link has been disconnected")
	}
	
	func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
		x.frame = view.frame
		view.addSubview(x)
		x.startAnimating()
	}
	
	func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
	}
}

//Mark:- Facebook Sign In Delegates

extension ViewController: LoginButtonDelegate{
	
	func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
		let x = UIActivityIndicatorView()
		x.frame = view.frame
		x.startAnimating()
		switch result {
			
		case .success(grantedPermissions: _, declinedPermissions: _, token: let accessToken):
			print(accessToken.authenticationToken)
			
			
			viewModel.loadFBprofile(completionHandler: { [weak self] error in
				x.stopAnimating()
				self?.view.willRemoveSubview(x)
				if error == nil {
					UserDefaults.standard.set("Facebook", forKey: "auth")
					self?.successfulLogin()
				} else {
					self?.displayAlert(title: "Error", message: "Login via facebook failed")
				}
				
			})
		case .cancelled :
			print("Cancelled")
			displayAlert(title: "Cancelled", message: "The login through facebook was cancelled")
		case .failed(let error) :
			print("Facebook Login Failed")
			displayAlert(title: "Failed", message: "Facebook login has failed, try again")
			print(error.localizedDescription)
		}
	}
	
	func loginButtonDidLogOut(_ loginButton: LoginButton) {
		displayAlert(title: "Logged out", message: "You have successfully disconnected from Facebook")
	}
	
}

extension UIViewController {
	
	func displayAlert(title : String, message : String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
}
