//
//  ContentView.swift
//  TimiIOS
//
//  Created by Aleksander Jaworski on 04/04/2022.
//  Copyright © 2022 Touchlab. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: Tab = .async

    enum Tab {
        case coroutines
        case adapter
        case combine
        case async
        case example
    }

    var body: some View {
        TabView(selection: $selection) {
            CoroutinesBreedListScreen()
                .tabItem {
                    Label("Coroutines", systemImage: "list.dash")
                }
                .tag(Tab.coroutines)
            AdapterBreedListScreen()
                .tabItem {
                    Label("Adapter", systemImage: "list.dash")
                }
                .tag(Tab.adapter)
            NativeCombineBreedListScreen()
                .tabItem {
                    Label("Combine", systemImage: "list.dash")
                }
                .tag(Tab.combine)
            NativeAsyncBreedListScreen()
                .tabItem {
                    Label("Async", systemImage: "list.dash")
                }
                .tag(Tab.async)
            CoroutinesExampleScreen()
                .tabItem {
                    Label("Examples", systemImage: "list.dash")
                }
                .tag(Tab.example)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
