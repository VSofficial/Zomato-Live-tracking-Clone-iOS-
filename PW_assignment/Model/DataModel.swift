//
//  DataModel.swift
//  PW_assignment
//
//  Created by Varun Sharma on 20/04/24.
//

import Foundation


// MARK: - OrderListElement
struct OrderListElement: Codable {
    let deliveryboy, foodname: String
    let time: Int
    let startlat, startlong, endlat, endlong: String
    let id: String
}

typealias OrderList = [OrderListElement]
