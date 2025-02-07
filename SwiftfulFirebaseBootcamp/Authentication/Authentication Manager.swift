//
//  Authentication Manager.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Aaron Lee on 21/01/2025.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

struct AuthDataResultModel {
    let uid : String
    let email : String?
    let photoURL : String?
    // because the provider shows nothing for anonymous
    let isAnonymous : Bool
    
    init(user : User){
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
}

enum AuthProviderOption : String{
    case email = "password"
    case google = "google.com"
}

final class AuthenticationManager{
    
    static let shared = AuthenticationManager()
    private init(){}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user:user)
    }
    
    // one user can login with different providers
    func getProviders() throws -> [AuthProviderOption]{
        guard let providerData = Auth.auth().currentUser?.providerData else{
            throw URLError(.badServerResponse)
        }
        var providers : [AuthProviderOption] = []
        
        for provider in providerData{
            if let option  = AuthProviderOption(rawValue: provider.providerID){
                providers.append(option)
            }else{
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        
        return providers
    }
    
    
    func signOut() throws{
        try Auth.auth().signOut()
    }
}


//MARK : SIGN IN EMAIL
extension AuthenticationManager{
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user : authDataResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user : authDataResult.user)

    }
    
    func resetPassword(email:String) async throws{
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func UpdatePassword(password:String) async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    func UpdateEmail(email:String) async throws{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        try await user.updateEmail(to: email)
    }
}

//MARK : SIGN IN SSO
extension AuthenticationManager{
    
    @discardableResult
    func signInWithGoogle(tokens : GoogleSignInResultModel) async throws -> AuthDataResultModel{
//        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
//        return try await signIn(credential: credential)
    
        print("🟢 Attempting Firebase Sign-In with Google...")

           let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
           
           do {
               let authDataResult = try await signIn(credential: credential)
               print("✅ Firebase Sign-In Successful!")
               print("🔹 User ID: \(authDataResult.uid)")
               print("🔹 User Email: \(authDataResult.email ?? "No Email")")
               return authDataResult
           } catch {
               print("🔥 Firebase Sign-In Failed: \(error.localizedDescription)")
               throw error
           }
        
    }
    
    func signIn(credential:AuthCredential) async throws -> AuthDataResultModel{
//        let authDataResult = try await Auth.auth().signIn(with: credential)
//        return AuthDataResultModel(user: authDataResult.user)
        do {
               let authDataResult = try await Auth.auth().signIn(with: credential)
               print("✅ Authenticated with Firebase!")
               return AuthDataResultModel(user: authDataResult.user)
           } catch {
               print("🔥 Error during Firebase Sign-In: \(error.localizedDescription)")
               throw error
           }
    }
    
}

// MARK : SIGN IN ANONYMOUS
extension AuthenticationManager{
    
    @discardableResult
    func signInAnonymous() async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func linkEmail(email:String, password: String) async throws -> AuthDataResultModel {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        return try await linkCredential(credential: credential)

    }
    
    func linkGoogle(tokens : GoogleSignInResultModel        ) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await linkCredential(credential: credential)
    }

    
    private func linkCredential(credential: AuthCredential) async throws -> AuthDataResultModel{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badURL)
        }
        let authDataResult = try await user.link(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
}
