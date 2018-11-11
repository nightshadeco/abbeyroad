//
//  HarpInstrumentView.swift
//  Abbey Road
//
//  Created by Bridgette on 11/11/18.
//  Copyright © 2018 Nightshade. All rights reserved.
//

import Foundation
import UIKit

class HarpInstrumentView: UIView {
    
    var stackView = UIStackView(forAutoLayout: ())
    var musicService: MusicService!
    
    var harpstringViews = [UIView]()
    
    var lastPannedNum = -1
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(rgb: 0xf4817c)
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        
        let harpButton = UIButton(forAutoLayout: ())
        harpButton.setImage(UIImage(named: "harp"), for: .normal)
        stackView.addArrangedSubview(harpButton)
        harpButton.autoSetDimensions(to: CGSize(width: 1, height: 1))
//        harpButton.addTarget(self, action: #selector(harpTapped), for: .touchDown)
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(viewPanned))
//        addGestureRecognizer(panGesture)
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        for i in 0..<5 {
            let harpstringView = UIView(forAutoLayout: ())
            harpstringViews.append(harpstringView)
            harpstringView.backgroundColor = UIColor(rgb: 0x666666)
            addSubview(harpstringView)
            harpstringView.autoPinEdge(toSuperviewEdge: .left)
            harpstringView.autoPinEdge(toSuperviewEdge: .right)
            addConstraint(NSLayoutConstraint(item: harpstringView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: CGFloat(i+1)/6.0, constant: 0))
            harpstringView.autoSetDimension(.height, toSize: 2.0 * (5.0-CGFloat(i)) + 2.0)
        }
 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        print("harp")
        
        let pos = sender.location(in: self)
        let stringWidth = self.bounds.height / CGFloat(harpstringViews.count + 1)
        var stringNum = 0
        if pos.y < stringWidth + stringWidth*0.5 {
            stringNum = 0
        } else if pos.y < stringWidth*2 + stringWidth*0.5 {
            stringNum = 1
        } else if pos.y < stringWidth*3 + stringWidth*0.5 {
            stringNum = 2
        } else if pos.y < stringWidth*4 + stringWidth*0.5 {
            stringNum = 3
        } else {
            stringNum = 4
        }
        
        let instrumentMessage = InstrumentMessage()
        instrumentMessage.instrument = .Harp
        instrumentMessage.action = stringNum
        musicService.send(instrumentMessage: instrumentMessage)
    }
    
    @objc func viewPanned(_ sender: UIPanGestureRecognizer) {
        if sender.state == .changed {
            let pos = sender.location(in: self)
            let stringWidth = self.bounds.height / CGFloat(harpstringViews.count + 1)
            var stringNum = 0
            if pos.y < stringWidth + stringWidth*0.5 {
                stringNum = 0
            } else if pos.y < stringWidth*2 + stringWidth*0.5 {
                stringNum = 1
            } else if pos.y < stringWidth*3 + stringWidth*0.5 {
                stringNum = 2
            } else if pos.y < stringWidth*4 + stringWidth*0.5 {
                stringNum = 3
            } else {
                stringNum = 4
            }
            
            if stringNum != lastPannedNum {
                let instrumentMessage = InstrumentMessage()
                instrumentMessage.instrument = .Harp
                instrumentMessage.action = stringNum
                musicService.send(instrumentMessage: instrumentMessage)
                lastPannedNum = stringNum
            }
        } else if sender.state == .began {
            lastPannedNum = -1
        }
    }
    
}

