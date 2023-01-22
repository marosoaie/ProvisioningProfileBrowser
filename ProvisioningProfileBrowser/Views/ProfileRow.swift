//
//  ProfileRow.swift
//  ProvisioningProfileBrowser
//
//  Created by Mihai Arosoaie on 20/03/2022.
//

import SwiftUI


private struct ProfileRowDetails: View {
    private let title: String
    private let value: String

    var body: some View {
        HStack {
            Text(self.title).frame(minWidth: 150, alignment: .topLeading)
            Text(self.value)
        }.padding(Constants.rowTextPadding)

    }

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
}

struct ProfileRow: View {

    private enum Constants {
        static let width: CGFloat = 110
    }
    var file: File
    @State private var showingCertificatesPopover = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                ProfileRowDetails(title: "Title", value: file.title)
                ProfileRowDetails(title: "Subtitle", value: file.subtitle)
                ProfileRowDetails(title: "Details", value: file.details)
                ProfileRowDetails(title: "Xcode managed", value: file.isXcodeManaged)
                ProfileRowDetails(title: "Platforms", value: file.platforms)
                ProfileRowDetails(title: "Application Identifier", value: file.applicationIdentifier)
                ProfileRowDetails(title: "Created on", value: file.createdOn)
                ProfileRowDetails(title: "Expires on", value: file.expiresOn)
            }
            Spacer(minLength: 10)
            VStack(alignment: .trailing, spacing: 5) {
                Button("Certificates") {
                    self.showingCertificatesPopover = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            Spacer(minLength: 50)

        }
        .accentColor(Color.black)
        .background(Color.pink)
        .padding(.init(top: 8, leading: 4, bottom: 8, trailing: 4))
        .popover(isPresented: $showingCertificatesPopover) {
            CertsPopoverView(viewModel: .init(file: file))
                .onDisappear {
                    self.showingCertificatesPopover = false
                }
        }
    }
}

