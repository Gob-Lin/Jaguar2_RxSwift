//
//  EdetailModel.swift
//  Jaguar2
//
//  Created by Paolo Piccini on 25/03/23.
//

import Foundation

struct ContentModel  {

    var id: String
    var icon: String
    var type: String

    init(id: String, icon: String, type:String) {
        self.id = id
        self.icon = icon
        self.type = type
    }

    func description() -> String {
        return "id = \(self.id) icon = \(self.icon) type = \(self.type)"
    }
}
