//
//  SettingsView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Aaron Lee on 21/01/2025.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject{
    
    @Published var authProviders : [AuthProviderOption] = []
    @Published var authUser : AuthDataResultModel? = nil
    
    func loadAuthProviders(){
        if let providers =  try? AuthenticationManager.shared.getProviders(){
            authProviders = providers
        }
    }
    
    func loadAuthUser(){
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
        
    }
    
    func signOut() throws{
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws{
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else{
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws{
        let email = "hello123@gmail.com"
        try await AuthenticationManager.shared.UpdateEmail(email: email)
    }
    
    func updatePassword() async throws{
        let password = "Hello123!"
        try await AuthenticationManager.shared.UpdatePassword(password: password)
    }
    
    func linkGoogleAccount() async throws{
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        self.authUser = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
    }
    
    func linkEmailAccount() async throws{
        let email = "hello123@gmail.com"
        let password = "Hello123!"
        self.authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List{
            Button("Log out"){
                Task{
                    do{
                        try viewModel.signOut()
                        showSignInView = true
                    }catch{
                        print(error)
                    }
                }
                
            }
            
            if viewModel.authProviders.contains(.email){
                emailSection
            }
            
            if viewModel.authUser?.isAnonymous == true{
                anonymousSection
            }
            
        }
        
        .onAppear{
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
        .navigationBarTitle("Settings")
    }
}

#Preview {
    NavigationStack{
        SettingsView(showSignInView: .constant(false))
    }
   
}

extension SettingsView{
    private var emailSection: some View{
        Section {
            Button("Reset password"){
                Task{
                    do{
                        try await viewModel.resetPassword()
                        print("PASSWORD RESET")
                        showSignInView = true
                    }catch{
                        print(error)
                    }
                }
            }
            
            
            Button("Update email"){
                Task{
                    do{
                        try await viewModel.updateEmail()
                        print("EMAIL UPDATED")
                        showSignInView = true
                    }catch{
                        print(error)
                    }
                }
            }
            
            Button("Update password"){
                Task{
                    do{
                        try await viewModel.updatePassword()
                        print("PASSWORD UPDATED")
                        showSignInView = true
                    }catch{
                        print(error)
                    }
                }
            }
        } header: {
            Text("Email functions")
        }
    }
    
    private var anonymousSection: some View{
        Section {
            Button("Link Google Account"){
                Task{
                    do{
                        try await viewModel.linkGoogleAccount()
                        print("GOOGLE LINKED")
                    }catch{
                        print(error)
                    }
                }
            }
            
            
            Button("Link Email Account"){
                Task{
                    do{
                        try await viewModel.linkEmailAccount()
                        print("EMAIL LINKED")
                    }catch{
                        print(error)
                    }
                }
            }
            
        } header: {
            Text("Create Account")
        }
    }
}
