//
//  ContentView.swift
//  TimiIOS
//
//  Created by Aleksander Jaworski on 04/04/2022.
//  Copyright © 2022 Touchlab. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: Tab = .combine

    enum Tab {
        case combine
        case async
    }

    var body: some View {
        TabView(selection: $selection) {
            CoroutinesBreedListScreen()
                .tabItem {
                    Label("Coroutines", systemImage: "list.dash")
                }
                .tag(Tab.combine)
            AdapterBreedListScreen()
                .tabItem {
                    Label("Kampkit", systemImage: "list.dash")
                }
                .tag(Tab.combine)
            AdapterBreedListScreen()
                .tabItem {
                    Label("Combine", systemImage: "list.dash")
                }
                .tag(Tab.combine)
            AdapterBreedListScreen()
                .tabItem {
                    Label("Async", systemImage: "stopwatch")
                }
                .tag(Tab.async)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
