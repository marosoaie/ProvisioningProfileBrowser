//
//  Extensions.swift
//  ProvisioningProfileBrowser
//
//  Created by Mihai Arosoaie on 20/03/2022.
//

import Foundation

extension Dictionary where Key == String, Value == Any {

    var allStringValues: String {
        var result: String = ""
        for v in self.values {
            if let v = v as? String {
                result += " " + v
            } else if let v = v as? [String: Any] {
                result += " " + v.allStringValues
            }  else if let v = v as? [[String: Any]] {
                result += " " + v.map { $0.allStringValues }.joined(separator: " ")
            }
        }
        return result
    }
}
