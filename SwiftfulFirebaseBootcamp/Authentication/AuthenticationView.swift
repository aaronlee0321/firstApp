//
//  AuthenticationView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Aaron Lee on 20/01/2025.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class AuthenticationViewModel : ObservableObject{
    
    func signInGoogle() async throws{
        let helper = SignInGoogleHelper()
        do {
                let tokens = try await helper.signIn()
                
                print("✅ Google Sign-In Successful!")
                print("🔹 ID Token: \(tokens.idToken)")
                print("🔹 Access Token: \(tokens.accessToken)")
                print("🔹 Name: \(tokens.name ?? "No Name")")
                print("🔹 Email: \(tokens.email ?? "No Email")")
                
                try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
                print("🟢 Successfully called signInWithGoogle()")
                
            } catch {
                print("🔥 Error in signInGoogle(): \(error.localizedDescription)")
            }
       
    }
    
    func signInAnonymously() async throws{
        try await AuthenticationManager.shared.signInAnonymous()
    }
    
}

struct AuthenticationView: View {
      
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack{
            
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInAnonymously()
                        showSignInView = false // hides AuthenticationView
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Sign In Anonymously")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
            })
            
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height:55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel (scheme: .light, style: .wide, state: .normal)){
                Task{
                    do{
                        try await viewModel.signInGoogle()
                        showSignInView = false
                        print("Signed in Google succesfully")
                    }catch{
                        print(error)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

struct AuthenticationView_Preview: PreviewProvider{
    static var previews: some View{
        NavigationStack{
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
