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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(rgb: 0xf4817c)
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        
        let harpButton = UIButton(forAutoLayout: ())
        harpButton.setImage(UIImage(named: "harp"), for: .normal)
        stackView.addArrangedSubview(harpButton)
        harpButton.autoSetDimensions(to: CGSize(width: 1, height: 1))
        harpButton.addTarget(self, action: #selector(harpTapped), for: .touchDown)
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func harpTapped() {
        print("harp")
        let instrumentMessage = InstrumentMessage()
        instrumentMessage.instrument = .Harp
        instrumentMessage.action = 0
        musicService.send(instrumentMessage: instrumentMessage)
    }
    
}

