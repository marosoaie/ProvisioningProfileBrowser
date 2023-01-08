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

        @Published var showOnlyDistributionProfiles = false
        @Published var showExpiredProfiles = false

        
        @Published var filteredFiles: [File] = []
        
        var publisher: AnyCancellable?

        private var bag = Set<AnyCancellable>()
        
        @Published var searchText: String = ""

        func loadProvisioningProfiles() async throws -> [File] {
            return try Self.fileManager.contentsOfDirectory(atPath: Self.rootFolder)
                .filter { $0.hasSuffix("mobileprovision") }
                .map { Self.rootFolder + "/" + $0  }
                .map { try ($0, MobileProvision.read(from: $0)) }
                .map(File.init)
        }

        private func filterFiles() {
            let searchText = self.searchText
            let showOnlyDistributionProfiles = self.showOnlyDistributionProfiles
            let showExpiredProfiles = self.showExpiredProfiles

            let files = self.files
            DispatchQueue.global(qos: .background).async {

                let filteredFiles = files.filter { file in
                    let containsSeachText = {
                        if searchText.isEmpty {
                            return true
                        } else {
                            return file.mobileProvision.searchText.contains(searchText)
                        }
                    }()

                    let isDistribution = {
                        if showOnlyDistributionProfiles {
                            return file.isDistribution
                        } else {
                            return true
                        }
                    }()

                    let showExpiredProfiles = {
                        if showExpiredProfiles {
                            return true
                        } else {
                            return file.mobileProvision.expirationDate >= Date()
                        }
                    }()

                    return containsSeachText && isDistribution && showExpiredProfiles
                }

                DispatchQueue.main.async {
                    self.filteredFiles = filteredFiles
                }
                
            }
        }

        init() {
            self.bag.insert(
                $showOnlyDistributionProfiles
                    .receive(on: RunLoop.main)
                    .sink { _ in
                        self.filterFiles()
                    }
            )

            self.bag.insert(
                $showExpiredProfiles
                    .receive(on: RunLoop.main)
                    .sink { _ in
                        self.filterFiles()
                    }
            )

            self.bag.insert(
                $searchText
                    .receive(on: RunLoop.main)
                    .sink(receiveValue: { _ in
                        self.filterFiles()
                    })
            )

            Task {
                do {
                    let files = try await self.loadProvisioningProfiles()
                    self.files = files
                    self.filterFiles()
                } catch {
                    print(error)
                }
            }
        }
    }
}
