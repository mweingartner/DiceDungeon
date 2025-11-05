//
//  DiceColor.swift
//  DiceDungeon
//
//  Created by Michael Weingartner on 10/11/25.
//

import SpriteKit

enum DiceColor: String, CaseIterable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    
    var skColor: SKColor {
        switch self {
        case .red:
            return SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
        case .orange:
            return SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        case .yellow:
            return SKColor(red: 1.0, green: 0.9, blue: 0.2, alpha: 1.0)
        case .green:
            return SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
        case .blue:
            return SKColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
        case .purple:
            return SKColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 1.0)
        }
    }
    
    var displayName: String {
        return rawValue.capitalized
    }
}
