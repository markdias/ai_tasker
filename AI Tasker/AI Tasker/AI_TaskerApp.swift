//
//  PromptodoApp.swift
//  Promptodo
//
//  Created by Mark Dias on 01/11/2025.
//  Updated to use SwiftUI + SwiftData on 02/11/2025.
//

import SwiftUI
import SwiftData

@main
struct PromptodoApp: App {
    let modelContainer: ModelContainer

    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView(appState: appState)
                .modelContainer(modelContainer)
        }
    }

    init() {
        let schema = Schema([
            ProjectLocal.self,
            TaskLocal.self,
            PromptLocal.self,
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
}
