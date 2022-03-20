//
//  CertsPopoverViewViewModel.swift
//  ProvisioningProfileBrowser
//
//  Created by Mihai Arosoaie on 20/03/2022.
//

import Foundation

extension CertsPopoverView {
    @MainActor class ViewModel: ObservableObject {
        @Published var file: File
        
        var certs: [MobileProvision.Certificate] {
            return file.mobileProvision.developerCertificates
        }
        
        init(file: File) {
            self.file = file
        }
    }
}
