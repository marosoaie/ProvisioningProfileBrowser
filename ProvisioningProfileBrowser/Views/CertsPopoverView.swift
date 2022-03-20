//
//  CertsPopoverView.swift
//  ProvisioningProfileBrowser
//
//  Created by Mihai Arosoaie on 20/03/2022.
//

import SwiftUI

struct CertsPopoverView: View {
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            List(viewModel.certs) { cert in
                Text(cert.subjectName + " " + cert.expiresOn)
            }
        }.padding()
            .frame(width: 500, height: 500, alignment: .leading)
    }
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}
