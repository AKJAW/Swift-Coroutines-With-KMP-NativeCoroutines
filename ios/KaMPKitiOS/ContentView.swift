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
                    Label("Adapter", systemImage: "list.dash")
                }
                .tag(Tab.combine)
            NativeCombineBreedListScreen()
                .tabItem {
                    Label("Native", systemImage: "list.dash")
                }
                .tag(Tab.combine)
            CoroutinesExampleScreen()
                .tabItem {
                    Label("Examples", systemImage: "list.dash")
                }
                .tag(Tab.combine)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
