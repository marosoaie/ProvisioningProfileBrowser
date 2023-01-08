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
        Table(viewModel.certs) {
            TableColumn("Subject Name", value: \.subjectName).width(800)
            TableColumn("Expires On", value: \.expiresOn)
        }
        .padding()
            .frame(width: 1000, height: 500, alignment: .leading)
    }
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}
