import SwiftUI

struct RootView: View {
    var selectedTab: Int = 0

    var body: some View {
        TabView(selection: .constant(selectedTab)) {
            NavigationStack { FirstScreen() }
                .tabItem { Label("First View", systemImage: "1.square") }
                .tag(0)
            NavigationStack { SecondScreen() }
                .tabItem { Label("Second View", systemImage: "2.square") }
                .tag(1)
        }
    }
}
