import SwiftUI
import Drops
import Firebase
import FirebaseAuth

struct PhoneVarification: View {
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var verificationID: String? = nil // Store verification ID
    @State private var isCodeSent: Bool = false
    let isCompact: Bool
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var countryCode: String = "+1"
    // Filter the country code to ensure it starts with a plus and contains only numbers
        func filterCountryCode(_ code: String) -> String {
            var filtered = code.filter { "+0123456789".contains($0) }
            if !filtered.starts(with: "+") {
                filtered = "+" + filtered
            }
            return filtered
        }
        
        // Ensure the phone number contains only digits
        func filterPhoneNumber(_ number: String) -> String {
            return number.filter { "0123456789".contains($0) }
        }
    
    func extractPhoneNumber(from input: String) -> String {
        let allowedCharacters = CharacterSet.decimalDigits
        let filtered = input.unicodeScalars.filter { allowedCharacters.contains($0) }
        return String(String.UnicodeScalarView(filtered))
    }
    
    private func deleteUserData(userId: String, completion: @escaping (Error?) -> Void) {
            // Reference to the collection
            let collectionRef = Firestore.firestore().collection("phoneNumbers")

            // Query the document where the 'email' field matches the provided email
        collectionRef.whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    // Iterate through the documents that match the query
                    for document in querySnapshot!.documents {
                        // Delete each document
                        collectionRef.document(document.documentID).delete { error in
                            if let error = error {
                                print("Error deleting document: \(error)")
                            } else {
                                print("Document successfully deleted!")
                            }
                        }
                    }
                }
            }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh().ignoresSafeArea()
                VStack {
                    // Phone number input
                    if !isCodeSent {
                        VStack {
                            Text("Phone Number")
                                .font(.title)
                            Text("Please enter your phone number to receive a verification code.")
                                .frame(width: isCompact ? UIScreen.main.bounds.width * 0.6 : UIScreen.main.bounds.width * 0.3)
                                .multilineTextAlignment(.center)
                            HStack {
                                TextField("Country Code", text: $countryCode)
                                    .padding()
                                    .keyboardType(.numberPad)
                                    .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                    .frame(width: isCompact ? 70 : 100, height: isCompact ? 35 : 55)
                                    .cornerRadius(isCompact ? 6 : 12)
                                
                                
                                // Phone Number Field
                                TextField("Phone Number", text: $phoneNumber)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .frame(height: isCompact ? 35 : 55)
                                    .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                                    .cornerRadius(isCompact ? 6 : 12)
                                
                                Spacer()
                                
                            }
                            .frame(width: isCompact ? UIScreen.main.bounds.width * 0.7 : UIScreen.main.bounds.width * 0.5, height: isCompact ? 35 : 55)
                            
                            Button {
                                let fullPhoneNumber = "\(countryCode)\(phoneNumber)"
                                let fullPhoneNumberToSave = "\(countryCode)\(extractPhoneNumber(from: phoneNumber))"
                                    registerPhoneNumber(fullPhoneNumberToSave) { success in
                                        if success {
                                            // Proceed with OTP verification and account creation
                                            print("Phone number is available, proceed with OTP.")
                                            sendPhoneVerification(phoneNumber: fullPhoneNumber) { id, error in
                                                if let error = error {
                                                    print("Error sending code: \(error.localizedDescription)")
                                                    Drops.show("Error sending code, Try again!")
                                                    deleteUserData(userId: Auth.auth().currentUser?.uid ?? "") {_ in
                                                        
                                                    }
                                                } else {
                                                    self.verificationID = id // Store verification ID
                                                    self.isCodeSent = true
                                                    print("Verification code sent")
                                                    Drops.show("Verification code sent.")
                                                }
                                            }
                                        } else {
                                            // Show error to user: Phone number is already in use
                                            print("Phone number is already in use.")
                                            Drops.show("Phone number is already in use.")
                                        }
                                    }
                                
                                
                            } label: {
                                Text("Send Verification Code")
                                    .padding()
                                    .frame(width: isCompact ? UIScreen.main.bounds.width * 0.7 : UIScreen.main.bounds.width * 0.5, height: isCompact ? 35 : 55)
                                    .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                                    .foregroundStyle(.white)
                                    .cornerRadius(isCompact ? 6 : 12)
                            }
                            
                        }
                    } else {
                        let fullPhoneNumber = "\(countryCode)\(phoneNumber)"
                        Text("Verification Code")
                            .font(.title)
                        Text("Enter the verification code sent to \(fullPhoneNumber).")
                            .frame(width: isCompact ? UIScreen.main.bounds.width * 0.6 : UIScreen.main.bounds.width * 0.3)
                            .multilineTextAlignment(.center)
                        // Code input and verification
                        TextField("Verification code", text: $verificationCode)
                            .keyboardType(.numberPad)
                            .padding()
                            .frame(width: isCompact ? UIScreen.main.bounds.width * 0.7 : UIScreen.main.bounds.width * 0.5, height: isCompact ? 35 : 55)
                            .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                            .cornerRadius(isCompact ? 6 : 12)
                        Button {
                            deleteUserData(userId: Auth.auth().currentUser?.uid ?? "") {_ in 
                                
                            }
                            isCodeSent.toggle()
                        } label: {
                            Text("Edit Number?")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                        }
                        
                        Spacer()
                            .frame(height: 200)
                        
                        Button {
                            if let id = verificationID { // Ensure verification ID exists
                                verifyPhoneNumber(verificationID: id, verificationCode: verificationCode) { success, error in
                                    if success {
                                        print("Phone number verified")
                                        Drops.show("Successfully verified phone number.")
                                        dismiss()
                                    } else if let error = error {
                                        print("Verification failed: \(error.localizedDescription)")
                                        Drops.show("Verification failed, Try again!.")
                                    }
                                }
                            }
                        } label: {
                            Text("Verify Code")
                                .padding()
                                .frame(width: isCompact ? UIScreen.main.bounds.width * 0.7 : UIScreen.main.bounds.width * 0.5, height: isCompact ? 35 : 55)
                                .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                                .foregroundStyle(.white)
                                .cornerRadius(isCompact ? 6 : 12)
                        }
                        
                        
                        
                        Button {
                            let fullPhoneNumber = "\(countryCode)\(phoneNumber))"
                            sendPhoneVerification(phoneNumber: fullPhoneNumber) { id, error in
                                if let error = error {
                                    print("Error sending code: \(error.localizedDescription)")
                                    Drops.show("Error sending code, Try again!")
                                } else {
                                    self.verificationID = id // Store verification ID
                                    self.isCodeSent = true
                                    print("Verification code sent")
                                    Drops.show("Verification code sent.")
                                }
                            }
                        } label: {
                            Text("Resend Code")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                appState.isInSignInView = true
            }
        }
    }
    
    func registerPhoneNumber(_ phoneNumber: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let phoneNumberRef = db.collection("phoneNumbers").document(phoneNumber)
        
        // Check if the phone number already exists
        phoneNumberRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Phone number is already linked to an account
                completion(false)  // Registration failed, phone number in use
            } else {
                // Phone number is not in use, create a new document
                phoneNumberRef.setData([
                    "userId": Auth.auth().currentUser?.uid ?? "",
                    "phoneNumber": phoneNumber
                ]) { error in
                    if let error = error {
                        print("Error saving phone number: \(error)")
                        completion(false)
                    } else {
                        completion(true)  // Registration success
                    }
                }
            }
        }
    }
}

func sendPhoneVerification(phoneNumber: String, completion: @escaping (String?, Error?) -> Void) {
    PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
        if let error = error {
            completion(nil, error)
        } else {
            completion(verificationID, nil) // Pass back the verification ID
        }
    }
}

func verifyPhoneNumber(verificationID: String, verificationCode: String, completion: @escaping (Bool, Error?) -> Void) {
    let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)

    Auth.auth().currentUser?.link(with: credential) { authResult, error in
        if let error = error {
            completion(false, error)
        } else {
            completion(true, nil)
        }
    }
}

#Preview {
    PhoneVarification(isCompact: false)
}

