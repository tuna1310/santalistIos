import SwiftUI
import SwiftData

/// Main root view coordinating the 3 tabs: Recipients | Timeline | Budget
public struct ContentView: View {
    @State private var selectedTab: Int = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            PeopleView()
                .tabItem {
                    Label("Recipients", systemImage: "person.2.fill")
                }
                .tag(0)

            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "clock.arrow.circlepath")
                }
                .tag(1)

            BudgetView()
                .tabItem {
                    Label("Budget", systemImage: "chart.pie.fill")
                }
                .tag(2)
        }
        .tint(Color("PineGreen"))
    }
}

public typealias MainTabView = ContentView
