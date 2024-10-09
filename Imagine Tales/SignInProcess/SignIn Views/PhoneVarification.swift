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
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackGroundMesh().ignoresSafeArea()
                VStack {
                    // Phone number input
                    if !isCodeSent {
                        VStack {
                            
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
                            .frame(width: UIScreen.main.bounds.width * 0.7, height: isCompact ? 35 : 55)
                            
                            Button("Send Verification Code") {
                                let fullPhoneNumber = "\(countryCode)\(phoneNumber)"
                                print("Full Phone Number: \(fullPhoneNumber)")
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
                            }
                            .padding()
                            .frame(width: UIScreen.main.bounds.width * 0.7, height: isCompact ? 35 : 55)
                            .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                            .foregroundStyle(.white)
                            .cornerRadius(isCompact ? 6 : 12)
                        }
                    } else {
                        // Code input and verification
                        TextField("Verification code", text: $verificationCode)
                            .customTextFieldStyle(isCompact: isCompact)
                            .keyboardType(.numberPad)
                            .background(colorScheme == .dark ? .black.opacity(0.2) : .white)
                            .cornerRadius(isCompact ? 6 : 12)
                        Button("Edit Number?") {
                            isCodeSent.toggle()
                        }
                        Button("Verify Code") {
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
                        }
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.7, height: isCompact ? 35 : 55)
                        .background(colorScheme == .dark ? Color(hex: "#B43E2B") : Color(hex: "#FF6F61"))
                        .cornerRadius(isCompact ? 6 : 12)
                        
                        Button("Resed Code.") {
                            let fullPhoneNumber = "\(countryCode)\(phoneNumber)"
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
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Phone Number Verification")
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

