// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            ForEach(0..<5) { _ in
                HStack {
                    ForEach(0..<5) { _ in
                        Rectangle()
                            .foregroundColor(.blue)
                            .padding(-3)
                    }
                }
            }
        }.frame(width: 400, height: 400)
        .padding(7)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
