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

    var isXcodeManaged: String {
        return String(describing: mobileProvision.isXcodeManaged)
    }

    var platforms: String {
        return String(mobileProvision.platform.joined(separator: " || "))
    }

    var applicationIdentifier: String {
        return mobileProvision.entitlements.applicationIdentifier ?? "nil"
    }

    var createdOn: String {
        return String(describing: mobileProvision.creationDate)
    }

    var expiresOn: String {
        return String(describing: mobileProvision.expirationDate)
    }

    var isDistribution: Bool {
        return self.mobileProvision.developerCertificates.contains { cert in
            cert.subjectName.localizedStandardContains("apple distribution")
        }
    }
}
