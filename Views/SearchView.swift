import SwiftUI

struct SearchView: View {
    @State private var query = ""

    var body: some View {
        List {
            Text("Searching for: \(query)")
        }
        .searchable(text: $query)
        .navigationTitle("Search")
    }
}
