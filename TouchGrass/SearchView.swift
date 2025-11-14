//  SearchView.swift
//  TouchGrass
//
//  Created by Ben Keane on 11/10/25.
//

import SwiftUI

// TODO: FINISH SearchView
struct SearchView: View {
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    @State private var searchText = ""
    
    var body: some View {
        
    }
}
            

#Preview {
    SearchView()
        .environmentObject(FirebaseFunctions())
}
