//
//  InstrumentMessage.swift
//  Abbey Road
//
//  Created by Alex Powell on 11/10/18.
//  Copyright © 2018 Nightshade. All rights reserved.
//

import Foundation

class InstrumentMessage: NSObject {
    enum Instrument: String {
        case Drum = "D"
        case Harp = "H"
    }
    
    var instrument = Instrument.Drum
    var action: Int = 0
    
}
