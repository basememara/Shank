//
//  ContentView.swift
//  ShankExamples
//
//  Created by Basem Emara on 2019-09-08.
//  Copyright © 2019 Zamzam Inc. All rights reserved.
//

import SwiftUI

@available(iOS 13.0.0, *)
struct ContentView: View {
    var body: some View {
        Text("Hello World")
    }
}

#if DEBUG
@available(iOS 13.0.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
