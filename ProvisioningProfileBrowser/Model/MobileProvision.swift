//
//  MobileProvision.swift
//  Fluux.io
//
//  Created by Mickaël Rémond on 03/11/2018.
//  Copyright © 2018 ProcessOne.
//  Distributed under Apache License v2
//
import Foundation

/* Decode mobileprovision plist file
 Usage:

 1. To get mobileprovision data as embedded in your app:
 MobileProvision.read()
 2. To get mobile provision data from a file on disk:

 MobileProvision.read(from: "my.mobileprovision")

*/

struct MobileProvision: Decodable {
    var name: String
    var appIDName: String
    var platform: [String]
    var isXcodeManaged: Bool? = false
    var creationDate: Date
    var expirationDate: Date
    var entitlements: Entitlements
    var developerCertificates: [Certificate]
    
    // ugly and inefficient - fixme
    var searchText: String {
        var searchTexts = [name, entitlements.applicationIdentifier]
        searchTexts += entitlements.keychainAccessGroups
        searchTexts += platform
        searchTexts += developerCertificates.map(\.decodedCertificate.allStringValues)
        return searchTexts.compactMap { $0 }.joined(separator: " ")
    }

    private enum CodingKeys : String, CodingKey {
        case name = "Name"
        case appIDName = "AppIDName"
        case platform = "Platform"
        case isXcodeManaged = "IsXcodeManaged"
        case creationDate = "CreationDate"
        case expirationDate = "ExpirationDate"
        case entitlements = "Entitlements"
        case developerCertificates = "DeveloperCertificates"
    }

    struct Certificate: Decodable, Identifiable {
        let id = UUID()

        let data: Data
        let certificate: SecCertificate
        let decodedCertificate: [String: Any]

        var certvalue: String {
            return (decodedCertificate["2.5.4.3"] as? [String: Any])?["value"] as? String ?? ""
        }
        
        var expiresOn: String {
            return ((decodedCertificate["2.5.29.24"] as? [String: Any])?["value"] as? Date ?? Date.init(timeIntervalSince1970: 0)).description
        }
        
        var subjectName: String {
            guard let l1 = decodedCertificate["2.16.840.1.113741.2.1.1.1.8"] as? [String: Any] else {
                return ""
            }
            guard let l2 = l1["value"] as? [[String: Any]] else {
                return ""
            }
            
            return l2.compactMap {
                ($0["value"] as? CustomStringConvertible)?.description ?? "undescribable"
            }.joined(separator: " || ")

        }

        var publicKeyData: Data {
            guard let l1 = decodedCertificate["2.16.840.1.113741.2.1.1.1.10"] as? [String: Any] else {
                return Data()
            }
            return l1["value"] as? Data ?? Data()
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let data = try container.decode(Data.self)
            guard let certificate = SecCertificateCreateWithData(nil, data as CFData) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "\(data)")
            }
            self.certificate = certificate
            self.data = data
            let values = SecCertificateCopyValues(certificate, nil, nil) as? [String: Any] ?? [:]
//            print(values)
            self.decodedCertificate = values
            
        }

    }
    // Sublevel: decode entitlements informations
    struct Entitlements: Decodable {
        let keychainAccessGroups: [String]
        let getTaskAllow: Bool
        let apsEnvironment: Environment
        let applicationIdentifier: String?

        private enum CodingKeys: String, CodingKey {
            case keychainAccessGroups = "keychain-access-groups"
            case getTaskAllow = "get-task-allow"
            case apsEnvironment = "aps-environment"
            case applicationIdentifier = "application-identifier"
        }

        enum Environment: String, Decodable {
            case development, production, disabled
        }

        init(keychainAccessGroups: Array<String>, getTaskAllow: Bool, apsEnvironment: Environment, applicationIdentifier: String?) {
            self.keychainAccessGroups = keychainAccessGroups
            self.getTaskAllow = getTaskAllow
            self.apsEnvironment = apsEnvironment
            self.applicationIdentifier = applicationIdentifier
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let keychainAccessGroups: [String] = (try? container.decode([String].self, forKey: .keychainAccessGroups)) ?? []
            let getTaskAllow: Bool = (try? container.decode(Bool.self, forKey: .getTaskAllow)) ?? false
            let apsEnvironment: Environment = (try? container.decode(Environment.self, forKey: .apsEnvironment)) ?? .disabled
            let applicationIdentifier = try container.decodeIfPresent(String.self, forKey: .applicationIdentifier)

            self.init(keychainAccessGroups: keychainAccessGroups, getTaskAllow: getTaskAllow, apsEnvironment: apsEnvironment, applicationIdentifier: applicationIdentifier)
        }
    }
}

// Factory methods
extension MobileProvision {

    struct MobileProvisionError: Error {
        let description: String
    }

    // Read a .mobileprovision file on disk
    static func read(from profilePath: String) throws -> MobileProvision {
        let data = try Data.init(contentsOf: URL(fileURLWithPath: profilePath))
        guard let plistDataString = String(data: data, encoding: .isoLatin1) else {
            throw MobileProvisionError(description: "unable to decode data using .isoLatin1 encoding")
        }

        // Skip binary part at the start of the mobile provisionning profile
        let scanner = Scanner(string: plistDataString)
        guard scanner.scanUpTo("<plist", into: nil) != false else {
            throw MobileProvisionError(description: "scanner.scanUpTo(\"<plist\", into: nil) failed")
        }

        // ... and extract plist until end of plist payload (skip the end binary part.
        var extractedPlist: NSString?
        guard scanner.scanUpTo("</plist>", into: &extractedPlist) != false else {
            throw MobileProvisionError(description: "scanner.scanUpTo(\"<plist\", into: &extractedPlist) failed")
        }

        guard let plist = extractedPlist?.appending("</plist>").data(using: .isoLatin1) else {
            throw MobileProvisionError(description: "unable to convert plist to data")
        }
        let decoder = PropertyListDecoder()
        return try decoder.decode(MobileProvision.self, from: plist)
    }
}
