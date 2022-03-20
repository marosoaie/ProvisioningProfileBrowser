//
//  ContentView.swift
//  ProvisioningProfileBrowser
//
//  Created by Mihai Arosoaie on 20/03/2022.
//

import SwiftUI
import Combine

enum Constants {
    enum WindowSize {
        static let minWidth : CGFloat = 600
        static let minHeight : CGFloat = 600
        static let maxWidth : CGFloat = 1080
        static let maxHeight : CGFloat = 700
    }
    
    static let rowTextPadding = EdgeInsets(top: 4, leading: 4, bottom: 8, trailing: 4)
}


struct ContentView: View {

    @StateObject private var viewModel: ViewModel

    var body: some View {
        TextField("", text: $viewModel.searchText)
            .textFieldStyle(PlainTextFieldStyle())
            .background(RoundedRectangle(cornerRadius: 2).stroke(Color.white))
            .padding(.init(top: 24, leading: 40, bottom: 12, trailing: 40))
        List(viewModel.filteredFiles) { file in
            ProfileRow(file: file)
        }
        .frame(minWidth: Constants.WindowSize.minWidth, minHeight: Constants.WindowSize.minHeight)
        .frame(maxWidth: Constants.WindowSize.maxWidth, maxHeight: Constants.WindowSize.maxHeight)
        .textSelection(.enabled)

    }
    
    init() {
        self._viewModel = StateObject(wrappedValue: ViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
