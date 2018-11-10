//
//  InstrumentView.swift
//  Abbey Road
//
//  Created by Alex Powell on 11/10/18.
//  Copyright © 2018 Nightshade. All rights reserved.
//

import Foundation
import UIKit

class InstrumentView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .green
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
