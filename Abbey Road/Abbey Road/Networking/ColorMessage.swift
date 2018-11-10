//
//  ColorMessage.swift
//  Abbey Road
//
//  Created by Alex Powell on 11/10/18.
//  Copyright © 2018 Nightshade. All rights reserved.
//

import Foundation
import UIKit

struct ColorMessage {
    var color: UIColor!
    var colorString: String {
        if color == .red {
            return "R"
        } else if color == .green {
            return "G"
        }
        return "_"
    }
}
