//
//  SignInGoogleHelper.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Aaron Lee on 26/01/2025.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel{
    let idToken : String
    let accessToken : String
    let name : String?
    let email : String?
}

final class SignInGoogleHelper{
    
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel{
        //get the top most viewController in Swift
        guard let topVC = Utilities.shared.topViewController() else{
            print("🔥 Error: Could not find topViewController")
            throw URLError(.cannotFindHost)
        }
        
        do{
            print("🟢 Attempting Google Sign-In...")
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
            
            guard let idToken = gidSignInResult.user.idToken?.tokenString else{
                print("🔥 Error: ID Token is nil")
                throw URLError(.badServerResponse)
            }
            
            let accessToken = gidSignInResult.user.accessToken.tokenString
            // Can be used for personalisation / customisation
            let name = gidSignInResult.user.profile?.name
            let email = gidSignInResult.user.profile?.email
            let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken, name: name, email : email)
            
            print("✅ Google Sign-In Successful!")
                    print("🔹 ID Token: \(idToken)")
                    print("🔹 Access Token: \(accessToken)")
                    print("🔹 Name: \(name ?? "No Name")")
                    print("🔹 Email: \(email ?? "No Email")")
            
            return tokens
        }catch {
            print("🔥 Google Sign-In Failed: \(error.localizedDescription)")
            throw error
        }
        
    }
}
