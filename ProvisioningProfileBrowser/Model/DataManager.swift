//
//  DataManager.swift
//  ProvisioningProfileBrowser
//
//  Created by Mihai Arosoaie on 22/01/2023.
//

import Foundation
import Algorithms
actor DataManager {

    private static let debug = true
    private static let prefixes = ["🍅", "🥝", "🫐", "🍒", "🍑", "🍐", "🍏", "🥭", "🍍", "🍌", "🍋", "🍊", "🍉", "🍇"]
    private static var prefixIndex = 0

    let files: [File]

    init(files: [File]) {
        self.files = files
    }

    private var tasks: [Task<[File], Never>] = []

    func filterFiles(searchText: String, showOnlyDistributionProfiles: Bool, showExpiredProfiles: Bool) async -> [File] {
        if DataManager.prefixIndex >= DataManager.prefixes.count {
            DataManager.prefixIndex = 0
        }
        let prefix = DataManager.prefixes[DataManager.prefixIndex] + " "
        DataManager.prefixIndex += 1

        if DataManager.debug {
            print(prefix, "FilterFiles called with searchText: \(searchText) showOnlyDistributionProfiles: \(showOnlyDistributionProfiles) showExpiredProfiles: \(showExpiredProfiles)")
        }
        for task in tasks {
            task.cancel()
        }
        tasks = []

        let files = self.files
        let chunks = Array(files.enumerated()).chunked { lhs, rhs in
            lhs.offset / 20 == rhs.offset / 20
        }
        if DataManager.debug {
            print(prefix, chunks.map { $0.count })
        }
        let filterTask = Task { () -> [File] in
            if DataManager.debug {
                print(prefix, "TOTAL: \(files.count)")
            }
             return await withTaskGroup(of: [File].self, returning: [File].self, body: { group in
                 for (taskIndex, chunk) in chunks.enumerated() {
                    guard !Task.isCancelled else {
                        return []
                    }
                    _ = group.addTaskUnlessCancelled {
                        var filteredFiles: [File] = []
                        for (index, file) in chunk.enumerated() {
                            guard !Task.isCancelled else {
                                if DataManager.debug {
                                    print(prefix, "Task \(taskIndex) canceled! at index \(index)")
                                }

                                return []
                            }
                            if DataManager.debug {
                                print(prefix, "task: \(taskIndex) index \(index)")
                            }

                            let containsSeachText = {
                                if searchText.isEmpty {
                                    return true
                                } else {
                                    return file.element.mobileProvision.searchText.contains(searchText)
                                }
                            }()

                            let isDistribution = {
                                if showOnlyDistributionProfiles {
                                    return file.element.isDistribution
                                } else {
                                    return true
                                }
                            }()

                            let showExpiredProfiles = {
                                if showExpiredProfiles {
                                    return true
                                } else {
                                    return file.element.mobileProvision.expirationDate >= Date()
                                }
                            }()

                            if containsSeachText && isDistribution && showExpiredProfiles {
                                filteredFiles.append(file.element)
                            }

                        }

                        return filteredFiles
                    }

                }
                 return await group.reduce([], +)
            })
        }
        self.tasks = [filterTask]

        return await filterTask.value
    }

}
