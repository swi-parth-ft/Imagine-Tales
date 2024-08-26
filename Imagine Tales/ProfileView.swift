//
//  ProfileView.swift
//  Imagine Tales
//
//  Created by Parth Antala on 8/14/24.
//

import SwiftUI
import FirebaseFirestore

final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: AuthDataResultModel? = nil
    @Published var child: UserChildren?
    @Published var pin: String = ""
    
    func loadUser() throws {
        user = try AuthenticationManager.shared.getAuthenticatedUser()
    }
    func logOut() throws {
        try AuthenticationManager.shared.SignOut()
    }
    
    func fetchChild(ChildId: String) {
        let docRef = Firestore.firestore().collection("Children2").document(ChildId)
        
        
        docRef.getDocument(as: UserChildren.self) { result in
                switch result {
                case .success(let document):
                    self.child = document
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
        }
    func getPin() throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        Firestore.firestore().collection("users").document(authDataResult.uid).getDocument { doc, error in
            if let doc = doc, doc.exists {
                self.pin = doc.get("pin") as? String ?? "0"
                print(self.pin)
            }
        }
        
       // Firestore.firestore().collection("users").document(userId).updateData(["pin": pin])
    }
    
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    @Binding var reload: Bool
    
    @AppStorage("childId") var childId: String = "Default Value"
    @AppStorage("ipf") private var ipf: Bool = true
    @State private var isAddingPin = false
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color(hex: "#FFFFF1").ignoresSafeArea()
                VStack {
                        Button("Log out") {
                            Task {
                                do {
                                    try viewModel.logOut()
                                    childId = ""
                                    showSignInView = true
                                } catch {
                                    print(error.localizedDescription)
                                }
                                
                            }
                        }
                        .padding()
                        .frame(width:  UIScreen.main.bounds.width * 0.7)
                        .background(Color(hex: "#FF6F61"))
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    
                    Button("Parent Dashboard") {
                        
                        isAddingPin = true
                    }
                    
                    
                    
                }
                .padding([.trailing, .leading])
                .padding(.top, 100)
                .onChange(of: reload) { 
                    try? viewModel.loadUser()
                    viewModel.fetchChild(ChildId: childId)
                    try? viewModel.getPin()
                }
                .sheet(isPresented: $isAddingPin) {
                    PinView()
               
                }
                
                
            }
            .navigationTitle("Hey, \(viewModel.child?.name ?? "N/A")")
            .onAppear {
                try? viewModel.loadUser()
                viewModel.fetchChild(ChildId: childId)
                try? viewModel.getPin()
            }
        }
        
     
        
            
        
    }
}

struct PinView: View {
    @State private var pin = ""
    private let otpLength: Int = 4
    
    @AppStorage("ipf") private var ipf: Bool = true
    @StateObject private var viewModel = ProfileViewModel()
    
    @State private var otp: [String] = Array(repeating: "", count: 4)
       @FocusState private var focusedIndex: Int?
    
    var body: some View {
        ZStack {
            Color(hex: "#FFFFF1").ignoresSafeArea()
        VStack {
            
            Text("Enter Parent PIN")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 2)
            
            HStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { index in
                    TextField("", text: $otp[index])
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .keyboardType(.numberPad)
                        .focused($focusedIndex, equals: index)
                        .onChange(of: otp[index]) { newValue in
                            if newValue.count > 1 {
                                otp[index] = String(newValue.prefix(1))
                            }
                            if !newValue.isEmpty && index < 3 {
                                focusedIndex = index + 1
                            }
                            
                            if newValue.isEmpty && index > 0 {
                                focusedIndex = index - 1
                            }
                        }
                }
            }
            .padding()
            
            
            Button("Enter to the boring side") {
                print(viewModel.pin)
                if otp.joined() == viewModel.pin {
                    ipf = true
                }
            }
        }
        
    }
                    
                
        .onAppear {
            try? viewModel.getPin()
            focusedIndex = 0
          
        }
    }
   
}

#Preview {
    ProfileView(showSignInView: .constant(false), reload: .constant(false))

}


