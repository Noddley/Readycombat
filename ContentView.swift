//
//  ContentView.swift
//  Ready Combat login app
//
//  Created by Easton Spehar on 6/27/24.
//
import SwiftUI
import CoreImage.CIFilterBuiltins

// Model for QR Code Data
struct QRCodeData: Identifiable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var nickname: String
    var email: String
    var qrCodeImage: Data?

    init(id: UUID = UUID(), firstName: String, lastName: String, nickname: String, email: String, qrCodeImage: UIImage?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.nickname = nickname
        self.email = email
        self.qrCodeImage = qrCodeImage?.pngData()
    }
}

class QRCodeStore: ObservableObject {
    @Published var qrCodes: [QRCodeData] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private let userDefaultsKey = "savedQRCodes"

    init() {
        loadFromUserDefaults()
    }
    
    func addQRCode(_ qrCode: QRCodeData) {
        qrCodes.append(qrCode)
    }
    
    func deleteQRCode(at indexSet: IndexSet) {
        qrCodes.remove(atOffsets: indexSet)
    }
    
    private func saveToUserDefaults() {
        do {
            let data = try JSONEncoder().encode(qrCodes)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Failed to save QR codes: \(error)")
        }
    }
    
    private func loadFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            qrCodes = try JSONDecoder().decode([QRCodeData].self, from: data)
        } catch {
            print("Failed to load QR codes: \(error)")
        }
    }
}

struct ContentView: View {
    // State variables to store the user input
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var nickname: String = ""
    @State private var email: String = ""
    
    // Inject QRCodeStore instance
    @ObservedObject var qrCodeStore: QRCodeStore = QRCodeStore()
    
    // State variable to control navigation
    @State private var shouldNavigate = false
    
    // State variable to track which text field is focused
    @FocusState private var focusedField: Field?

    // Enum to represent different text fields
    private enum Field {
        case firstName, lastName, nickname, email
    }
    
    // Computed property to check if all fields are filled out
    private var canSubmit: Bool {
        return !firstName.isEmpty && !lastName.isEmpty && !nickname.isEmpty && !email.isEmpty
    }

    // Star Wars color scheme
    let darkOverlayColor = Color.blue.opacity(0.2) // Dark blue with more transparency
    let lightTextColor = Color.white
    let accentColor = Color(red: 191/255, green: 157/255, blue: 97/255) // Star Wars yellow with RGB values

    var body: some View {
        NavigationView {
            ZStack {
                // Background image
                Image("rc-kids app background") // Replace with your background image name
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.8) // Adjust the opacity as needed

                // Transparent overlay
                darkOverlayColor
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Logo at the top
                    Image("Ready-Combat-Full-White") // Replace with your logo image name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 330.0, height: 100)
                        .padding(.bottom, 40)

                    // Text fields for user input
                    Group {
                        TextField("First Name", text: $firstName)
                            .focused($focusedField, equals: .firstName)
                            .onTapGesture {
                                focusedField = .firstName
                            }
                        TextField("Last Name", text: $lastName)
                            .focused($focusedField, equals: .lastName)
                            .onTapGesture {
                                focusedField = .lastName
                            }
                        TextField("Nickname", text: $nickname)
                            .focused($focusedField, equals: .nickname)
                            .onTapGesture {
                                focusedField = .nickname
                            }
                        TextField("Email", text: $email)
                            .focused($focusedField, equals: .email)
                            .onTapGesture {
                                focusedField = .email
                            }
                    }
                    .padding()
                    .background(lightTextColor)
                    .foregroundColor(.black)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(accentColor, lineWidth: 1))
                    .frame(width: 300) // Fixed width

                    // Submit button
                    Button(action: {
                        // Handle submit action
                        guard canSubmit else { return }
                        var qrCodeData = QRCodeData(firstName: firstName, lastName: lastName, nickname: nickname, email: email, qrCodeImage: nil)
                        generateQRCode(for: &qrCodeData)
                        qrCodeStore.addQRCode(qrCodeData)
                        shouldNavigate = true
                        clearFields() // Clear fields after submission
                    }) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(canSubmit ? accentColor : Color.gray)
                            .cornerRadius(5)
                            .frame(width: 300) // Fixed width
                            .opacity(canSubmit ? 1.0 : 0.5)
                            .disabled(!canSubmit) // Disable button if not all fields are filled
                    }
                    .padding(.top, 20)

                    // Navigation link to view tickets
                    NavigationLink(
                        destination: NewScreenView(qrCodeStore: qrCodeStore),
                        isActive: $shouldNavigate,
                        label: {
                            Text("View Tickets")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(accentColor)
                                .cornerRadius(5)
                                .frame(width: 300) // Fixed width
                        }
                    )
                    .disabled(qrCodeStore.qrCodes.isEmpty) // Disable navigation link if no tickets exist
                }
                .padding()
            }
            .navigationBarTitle("", displayMode: .inline) // Remove title for iPhone layout
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use StackNavigationViewStyle for iPad
        
    }
    
    // Function to generate QR code
    private func generateQRCode(for qrCodeData: inout QRCodeData) {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        // Format data with identifiers
        let qrData = """
            FName: \(qrCodeData.firstName)
            LName: \(qrCodeData.lastName)
            Nickname: \(qrCodeData.nickname)
            Email: \(qrCodeData.email)
            """.data(using: .utf8)!
        
        filter.setValue(qrData, forKey: "inputMessage")
        
        if let ciImage = filter.outputImage {
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let uiImage = UIImage(cgImage: cgImage)
                qrCodeData.qrCodeImage = uiImage.pngData()
            }
        }
    }

    
    // Function to clear input fields
    private func clearFields() {
        firstName = ""
        lastName = ""
        nickname = ""
        email = ""
    }
}

struct NewScreenView: View {
    // Inject QRCodeStore instance
    @ObservedObject var qrCodeStore: QRCodeStore

    var body: some View {
        List {
            Section(header: Text("Ticket Details").font(.title).fontWeight(.bold)) {
                ForEach(qrCodeStore.qrCodes) { qrCodeData in
                    TicketInfoView(qrCodeData: qrCodeData)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                }
                .onDelete(perform: qrCodeStore.deleteQRCode)
            }
        }
        .listStyle(InsetGroupedListStyle()) // Optional: Adjust list style as needed
        .navigationBarTitle("Tickets", displayMode: .inline)
        .navigationBarItems(trailing: EditButton())
    }
}

struct TicketInfoView: View {
    @State var qrCodeData: QRCodeData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("First Name: \(qrCodeData.firstName)")
            Text("Last Name: \(qrCodeData.lastName)")
            Text("Nickname: \(qrCodeData.nickname)")
            Text("Email: \(qrCodeData.email)")
            
            if let qrCodeImageData = qrCodeData.qrCodeImage, let uiImage = UIImage(data: qrCodeImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.top, 10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 3)
        .padding(.vertical, 5)
    }
}

struct QRCodeFullScreenView: View {
    var qrCodeData: QRCodeData
    
    var body: some View {
        VStack {
            Text("QR Code Full Screen")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            if let qrCodeImageData = qrCodeData.qrCodeImage, let uiImage = UIImage(data: qrCodeImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
            
            Spacer()
        }
        .background(Color.black)
        .foregroundColor(.white)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
