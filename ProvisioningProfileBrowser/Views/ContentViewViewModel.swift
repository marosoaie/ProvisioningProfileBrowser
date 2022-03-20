//
//  ContentViewViewModel.swift
//  ProvisioningProfileBrowser
//
//  Created by Mihai Arosoaie on 20/03/2022.
//

import Foundation
import Combine

extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        static let fileManager = FileManager.default
        static let rootFolder = fileManager.homeDirectoryForCurrentUser.path + "/Library/MobileDevice/Provisioning Profiles"
        @Published var files: [File] = []
        
        @Published var filteredFiles: [File] = []
        
        var publisher: AnyCancellable?
        
        @Published var searchText: String = ""

        func loadProvisioningProfiles() async throws -> [File] {
            return try Self.fileManager.contentsOfDirectory(atPath: Self.rootFolder)
                .filter { $0.hasSuffix("mobileprovision") }
                .map { Self.rootFolder + "/" + $0  }
                .map { try ($0, MobileProvision.read(from: $0)) }
                .map(File.init)
        }

        init() {
            self.publisher = $searchText
                .receive(on: RunLoop.main)
                .sink(receiveValue: { str in
                    if !self.searchText.isEmpty {
                        self.filteredFiles = self.files.filter {
                            $0.mobileProvision.searchText.contains(self.searchText)
                        }
                    } else {
                        self.filteredFiles = self.files
                    }
                })

            Task {
                do {
                    let files = try await self.loadProvisioningProfiles()
                    self.files = files
                    self.filteredFiles = files
                } catch {
                    print(error)
                }
            }
        }
    }
}
