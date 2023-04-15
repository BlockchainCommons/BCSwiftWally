//
//  ContentView.swift
//  BCWallyDemo-Mac
//
//  Created by Wolf McNally on 10/14/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text(wallyDemo)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
