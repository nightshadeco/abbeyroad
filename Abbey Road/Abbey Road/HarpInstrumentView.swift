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
    
    let harpstring1View = UIView(forAutoLayout: ())
    let harpstring2View = UIView(forAutoLayout: ())
    let harpstring3View = UIView(forAutoLayout: ())
    let harpstring4View = UIView(forAutoLayout: ())
    let harpstring5View = UIView(forAutoLayout: ())
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(rgb: 0xf4817c)
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        
//        let harpButton = UIButton(forAutoLayout: ())
//        harpButton.setImage(UIImage(named: "harp"), for: .normal)
//        stackView.addArrangedSubview(harpButton)
//        harpButton.autoSetDimensions(to: CGSize(width: 1, height: 1))
//        harpButton.addTarget(self, action: #selector(harpTapped), for: .touchDown)
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        for i in 0..<5 {
            let harpstringView = UIView(forAutoLayout: ())
            harpstringViews.append(harpstringView)
            harpstringView.backgroundColor = .red
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
        let stringWidth = self.bounds.width / (CGFloat(harpstringViews.count) + CGFloat(1))
        var stringNum = 0
        if pos.x < stringWidth + stringWidth*0.5 {
            stringNum = 0
        } else if pos.x < stringWidth + stringWidth*0.5*2 {
            stringNum = 1
        } else if pos.x < stringWidth + stringWidth*0.5*3 {
            stringNum = 2
        } else if pos.x < stringWidth + stringWidth*0.5*4 {
            stringNum = 3
        } else {
            stringNum = 4
        }
        
        let instrumentMessage = InstrumentMessage()
        instrumentMessage.instrument = .Harp
        instrumentMessage.action = stringNum
        musicService.send(instrumentMessage: instrumentMessage)
    }
    
}

