//
//  ProfileRow.swift
//  ProvisioningProfileBrowser
//
//  Created by Mihai Arosoaie on 20/03/2022.
//

import SwiftUI

struct ProfileRow: View {
    var file: File
    @State private var showingPopover = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(file.title).padding(Constants.rowTextPadding)
            Text(file.subtitle).padding(Constants.rowTextPadding)
            Text(file.details).padding(Constants.rowTextPadding)
        }
        .accentColor(Color.black)
        .background(Color.pink)
        .padding(.init(top: 8, leading: 4, bottom: 8, trailing: 4))
        .onTapGesture {
            self.showingPopover = true
        }
        .popover(isPresented: $showingPopover) {
            CertsPopoverView(viewModel: .init(file: file))
        }
    }
}

