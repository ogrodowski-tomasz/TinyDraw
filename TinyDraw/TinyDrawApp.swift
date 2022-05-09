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
        WindowGroup {
            ContentView()
                .environmentObject(Drawing()) // Injecting Drawing int oenvironment. Here we are passing the object externally
        }
    }
}
