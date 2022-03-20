//
//  File.swift
//  ProvisioningProfileBrowser
//
//  Created by Mihai Arosoaie on 20/03/2022.
//


import Foundation

struct File: Identifiable {
    let id: UUID = UUID()
    let path: String
    let mobileProvision: MobileProvision
    
    var title: String {
        return mobileProvision.name
    }
    
    var subtitle: String {
        return mobileProvision.appIDName
    }
    
    var details: String {
        return mobileProvision.entitlements.applicationIdentifier ?? "nil"
    }
}
