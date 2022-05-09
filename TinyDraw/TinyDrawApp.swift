//
//  TinyDrawApp.swift
//  TinyDraw
//
//  Created by Tomasz Ogrodowski on 09/05/2022.
//

import SwiftUI

@main
struct TinyDrawApp: App {
    var body: some Scene {
        // To make a new document call Drawing.init give me the file coming in, and inject it into environment.
        DocumentGroup(newDocument: Drawing.init) { file in
            ContentView()
                .environmentObject(file.document) // Injecting Drawing into environment. Here we are passing the object externally
        }
    }
}
