//
//  StarryView.swift
//  Weather App
//
//  Created by Mustafa Yusuf on 30/12/17.
//  Copyright © 2017 Mustafa Yusuf. All rights reserved.
//

import UIKit

class StarryView: UIView {
	
	override class var layerClass : AnyClass {
		return CAEmitterLayer.self
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.setup()
	}
	
	fileprivate var emitter: CAEmitterLayer {
		return layer as! CAEmitterLayer
	}
	
	fileprivate var particle: CAEmitterCell!
	
	func setup() {
		emitter.emitterMode = kCAEmitterLayerOutline
		emitter.emitterShape = kCAEmitterLayerCircle
		emitter.renderMode = kCAEmitterLayerOldestFirst
		emitter.preservesDepth = true
		
		particle = CAEmitterCell()
		
		particle.contents = UIImage(named: "star")!.cgImage
		particle.birthRate = 10
		
		particle.lifetime = 50
		particle.lifetimeRange = 5
		
		particle.velocity = 20
		particle.velocityRange = 10
		
		particle.scale = 0.02
		particle.scaleRange = 0.1
		particle.scaleSpeed = 0.02
		
		emitter.emitterCells = [particle]
	}
	
	var emitterTimer: Timer?
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		
		if self.window != nil {
			if emitterTimer == nil {
				emitterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(randomizeEmitterPosition), userInfo: nil, repeats: true)
			}
		} else if emitterTimer != nil {
			emitterTimer?.invalidate()
			emitterTimer = nil
		}
	}
	
	@objc func randomizeEmitterPosition() {
		let sizeWidth = max(bounds.width, bounds.height)
		let radius = CGFloat(arc4random()).truncatingRemainder(dividingBy: sizeWidth)
		emitter.emitterSize = CGSize(width: radius, height: radius)
		particle.birthRate = 10 + sqrt(Float(radius))
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		emitter.emitterPosition = self.center
		emitter.emitterSize = self.bounds.size
	}
}
