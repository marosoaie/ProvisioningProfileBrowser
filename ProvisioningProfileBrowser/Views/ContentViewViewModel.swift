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
//        static let rootFolder = fileManager.homeDirectoryForCurrentUser.path + "/TestProvArchive"
        @Published var files: [File] = []

        @Published var showOnlyDistributionProfiles = false
        @Published var showExpiredProfiles = false

        @Published var filteredFiles: [File] = []

        private var bag = Set<AnyCancellable>()
        
        @Published var searchText: String = ""

        func loadProvisioningProfiles() async throws -> [File] {
            return try Self.fileManager.contentsOfDirectory(atPath: Self.rootFolder)
                .filter { $0.hasSuffix("mobileprovision") }
                .map { Self.rootFolder + "/" + $0  }
                .map { try ($0, MobileProvision.read(from: $0)) }
                .map(File.init)
        }

        private lazy var dataManager = DataManager(files: self.files)

        private func filterFiles() async {
            self.filteredFiles = await self.dataManager.filterFiles(searchText: self.searchText, showOnlyDistributionProfiles: self.showOnlyDistributionProfiles, showExpiredProfiles: self.showExpiredProfiles)
        }

        init() {
            self.bag.insert(
                $showOnlyDistributionProfiles
                    .receive(on: RunLoop.main)
                    .sink { _ in
                        Task {
                            await self.filterFiles()
                        }
                    }
            )

            self.bag.insert(
                $showExpiredProfiles
                    .receive(on: RunLoop.main)
                    .sink { _ in
                        Task {
                            await self.filterFiles()
                        }
                    }
            )

            self.bag.insert(
                $searchText
                    .receive(on: RunLoop.main)
                    .sink(receiveValue: { value in
                        print("$searchText sinkd with \(value)")

                        Task {
                            await self.filterFiles()
                        }
                    })
            )

            Task {
                do {
                    let files = try await self.loadProvisioningProfiles()
                    self.files = files
                    await self.filterFiles()
                } catch {
                    print(error)
                }
            }
        }
    }
}




