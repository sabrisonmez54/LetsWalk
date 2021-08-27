//
//  Step.swift
//  LetsWalk
//
//  Created by Sabri Sönmez on 8/24/21.
//

import Foundation

struct Step: Identifiable {
    let id = UUID()
    let count: Int
    let date: Date
}
