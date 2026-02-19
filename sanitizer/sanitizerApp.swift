//
//  sanitizerApp.swift
//  sanitizer
//
//  Created by Harsh Vasudeva on 19/02/26.
//

import SwiftUI
import CoreData

@main
struct sanitizerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
