import SwiftUI
import Firebase
import FirebaseAuth

struct PhoneVarification: View {
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var verificationID: String? = nil // Store verification ID
    @State private var isCodeSent: Bool = false

    var body: some View {
        VStack {
            // Phone number input
            TextField("Phone number", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.phonePad)
                .padding()

            Button("Send Verification Code") {
                sendPhoneVerification(phoneNumber: phoneNumber) { id, error in
                    if let error = error {
                        print("Error sending code: \(error.localizedDescription)")
                    } else {
                        self.verificationID = id // Store verification ID
                        self.isCodeSent = true
                        print("Verification code sent")
                    }
                }
            }
            .padding()

            if isCodeSent {
                // Code input and verification
                TextField("Verification code", text: $verificationCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Verify Code") {
                    if let id = verificationID { // Ensure verification ID exists
                        verifyPhoneNumber(verificationID: id, verificationCode: verificationCode) { success, error in
                            if success {
                                print("Phone number verified")
                            } else if let error = error {
                                print("Verification failed: \(error.localizedDescription)")
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
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
    PhoneVarification()
}
