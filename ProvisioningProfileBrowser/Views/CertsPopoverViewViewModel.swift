//
//  CertsPopoverViewViewModel.swift
//  ProvisioningProfileBrowser
//
//  Created by Mihai Arosoaie on 20/03/2022.
//

import Foundation
import Combine

extension CertsPopoverView {
    @MainActor class ViewModel: ObservableObject {
        @Published var file: File

        @Published var selectedCertId: MobileProvision.Certificate.ID?
        
        var certs: [MobileProvision.Certificate] {
            return file.mobileProvision.developerCertificates
        }

        var selectedCert: String {
            return file.mobileProvision.developerCertificates.first(where: {
                self.selectedCertId != nil && $0.id == self.selectedCertId
            })?.publicKeyData.base64EncodedString() ?? "No selection"
        }

        private var cancellable: AnyCancellable?
        
        init(file: File) {
            self.file = file
            self.cancellable = selectedCertId
                .publisher
                .sink { id in
                    let cert = file.mobileProvision.developerCertificates.first(where: {
                        self.selectedCertId != nil && $0.id == self.selectedCertId
                    })
                    let publicKeyData = cert?.publicKeyData.base64EncodedString()
                    print("Selected cert with name: \(cert?.subjectName ?? "no cert") and data: \(publicKeyData ?? "No data")")
            }
        }
    }
}
