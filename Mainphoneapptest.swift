import SwiftUI
import AssetsLibrary

struct ContentView: View {
    @State private var field1: String = ""
    @State private var field2: String = ""
    @State private var field3: String = ""
    @State private var field4: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                Image(systemName: "Ready.combat.logo")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding().secondary
            }
            
            TextField("Field 1", text: $field1)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
            TextField("Field 2", text: $field2)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
            TextField("Field 3", text: $field3)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
            TextField("Field 4", text: $field4)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
            
            Button("Submit") {
                let dataString = "Field 1: \(field1)\nField 2: \(field2)\nField 3: \(field3)\nField 4: \(field4)"
                print(dataString)
            }
            .padding()
            
            Spacer()
            
            HStack {
                Spacer()
                Image(systemName: "arrowtriangle.left.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(#colorLiteral(red: 0.7490196228027344, green: 0.615686297416687, blue: 0.3764705955982208, alpha: 1.0)))
                    .padding()
            }
        }
        .padding()
        .background(Color(#colorLiteral(red: 0.7490196228027344, green: 0.615686297416687, blue: 0.3764705955982208, alpha: 1.0)))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

