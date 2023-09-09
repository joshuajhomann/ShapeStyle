//
//  ContentView.swift
//  Shape
//
//  Created by Joshua Homann on 8/5/23.
//

import SwiftUI


extension ContentView {
    enum Item: String, Identifiable, Hashable, CaseIterable, CustomStringConvertible {
        case colors, blends, shaders
        var id: String {
            rawValue
        }
        var description: String {
            rawValue.capitalized
        }
    }
}



struct ContentView: View {
    @State var selectedItem: Item? = Item.allCases[0]
    var body: some View {
        NavigationSplitView {
            List(Item.allCases, selection: $selectedItem) { item in
                NavigationLink(String(describing: item), value: item)
            }
            .listStyle(.sidebar)
        } detail: {
            switch selectedItem {
            case .colors: ColorView()
            case .blends: BlendView()
            case .shaders: ShaderView()
            case .none: Text("Select a ShapeStyle")
            }
        }
    }
}

#Preview {
    ContentView()
}
