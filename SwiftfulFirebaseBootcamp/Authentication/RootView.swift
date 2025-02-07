//
//  RootView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Aaron Lee on 21/01/2025.
//

import SwiftUI
import FirebaseAuth
struct RootView: View {
    @State private var showSignInView : Bool = false
    
    var body: some View {
        
        ZStack{
            if !showSignInView{
                NavigationStack{
                    SettingsView(showSignInView: $showSignInView)
                }
            }
        }
        // runs the code when Rootview appears on screen
        .onAppear{
            // returns nil if the function throws an error
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            
            // if authUser is nil, showSignInView = true
            self.showSignInView = authUser == nil
            
        }
        
        .fullScreenCover(isPresented: $showSignInView){
            NavigationStack{
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    RootView()
}
