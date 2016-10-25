//
//  Types.swift
//  FinalProj
//
//  Created by Saeedeh Salimian on 8/2/16.
//  Copyright © 2016 hassaninc. All rights reserved.
//

import Foundation
// Helper functions so you don't have to write them yourself.

struct DefaultsKeys {
    static let pictures = "pictures"
}


struct DefaultsValues {
    static let pictures = [UIImage(named: "portrait01")!,
                           UIImage(named: "portrait02")!,
                           UIImage(named: "portrait03")!,
                           UIImage(named: "portrait04")!]
}


struct Messages {
    static let ColorModelChanged = "local Gallery Model Changed"
}