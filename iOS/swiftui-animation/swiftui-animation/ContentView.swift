//
//  ContentView.swift
//  swiftui-animation
//
//  Created by Wing on 20/8/2023.
//

import SwiftUI

struct ContentView: View {
    @State var flag = false
    var body: some View {
        Group {
            if flag {
                Rectangle()
                    .onTapGesture {
                        withAnimation { flag.toggle() }
                    }
                    .id("1")
                    .frame(width: 200, height: 100)
                    
                    .transition(.slide)
            } else {
                Rectangle()
                    .onTapGesture {
                        withAnimation { flag.toggle() }
                    }
                    .id("1")
                    .frame(width: 100, height: 100)
                    
                    .transition(.slide)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
