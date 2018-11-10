//
//  DrumInstrumentView.swift
//  Abbey Road
//
//  Created by Alex Powell on 11/10/18.
//  Copyright © 2018 Nightshade. All rights reserved.
//

import Foundation
import UIKit

class DrumInstrumentView: UIView {
    
    var stackView = UIStackView(forAutoLayout: ())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(rgb: 0xf19a4a)
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        
        let bassDrumButton = UIButton(forAutoLayout: ())
        bassDrumButton.setImage(UIImage(named: "drums"), for: .normal)
        stackView.addArrangedSubview(bassDrumButton)
        bassDrumButton.autoSetDimensions(to: CGSize(width: 1, height: 1))
        
        let snareDrumButton = UIButton(forAutoLayout: ())
        snareDrumButton.setImage(UIImage(named: "drum-and-drumsticks-top-view"), for: .normal)
        stackView.addArrangedSubview(snareDrumButton)
        snareDrumButton.autoMatch(.height, to: .height, of: bassDrumButton)
        
        let cymbalButton = UIButton(forAutoLayout: ())
        cymbalButton.setImage(UIImage(named: "cymbal"), for: .normal)
        stackView.addArrangedSubview(cymbalButton)
        cymbalButton.autoMatch(.height, to: .height, of: bassDrumButton)
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
