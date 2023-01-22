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
        Table(viewModel.certs, selection: $viewModel.selectedCertId) {
            TableColumn("Subject Name", value: \.subjectName).width(800)
            TableColumn("Expires On", value: \.expiresOn)
        }
            .padding()
            .frame(width: 1100, height: 500, alignment: .leading)
            .layoutPriority(0)
        Button {
            NSPasteboard.general.setString(viewModel.selectedCert, forType: .string)
        } label: {
            Text("Selected: \(viewModel.selectedCert)")
                .textSelection(.enabled)
                .padding()
                .layoutPriority(1)
                .lineLimit(10)
                .onHover { _ in
                    print(viewModel.selectedCert)
                }
        }

    }
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}
