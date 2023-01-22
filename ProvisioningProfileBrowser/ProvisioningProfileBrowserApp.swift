//
//  ProvisioningProfileBrowserApp.swift
//  ProvisioningProfileBrowser
//
//  Created by Mihai Arosoaie on 20/03/2022.
//

import SwiftUI

@main
struct ProvisioningProfileBrowserApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear() {
                    NSPasteboard.general.declareTypes([.string], owner: nil)
                }
        }
    }
}
