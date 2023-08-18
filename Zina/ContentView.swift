import SwiftUI

struct MaterialList: Identifiable {
    var id: String
    var size: Double
    var isChecked = false
}

struct CapsuleTextField: View {
    @FocusState private var amountIsFocused: Bool
    
    var text: String
    var value: Binding<Double>
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.zeroSymbol = ""
        return formatter
        }()
    
    var body: some View {
        TextField(text, value: value, formatter: formatter)
            .keyboardType(.decimalPad)
            .focused($amountIsFocused)
            .multilineTextAlignment(.center)
    }
}

struct ContentView: View {
    @FocusState private var amountIsFocused: Bool
    @State private var surface = "Roof"
    @State private var roofType = ""
    @State private var length = 0.0
    @State private var width = 0.0
    @State private var length1 = 0.0
    @State private var width1 = 0.0
    @State private var height = 0.0
    @State private var roofMaterials = [
        MaterialList(id: "C-8", size: 1.15, isChecked: false),
        MaterialList(id: "C-10", size: 1.15, isChecked: false),
        MaterialList(id: "C-21", size: 1, isChecked: false),
        MaterialList(id: "C-44", size: 1, isChecked: false),
        MaterialList(id: "МП-18", size: 1.1, isChecked: false),
        MaterialList(id: "МП-20", size: 1.1, isChecked: false),
        MaterialList(id: "МЧ", size: 1.1, isChecked: false),
        MaterialList(id: "H-60", size: 0.845, isChecked: false),
        MaterialList(id: "H-75", size: 0.75, isChecked: false),
        MaterialList(id: "H-114 (600)", size: 0.75, isChecked: false),
        MaterialList(id: "H-114 (750)", size: 0.75, isChecked: false),
        MaterialList(id: "HC-35", size: 1, isChecked: false),
    ]
    @State private var facadeMaterials = [
        MaterialList(id: "КД", size: 0.226, isChecked: false),
        MaterialList(id: "WS", size: 0.33, isChecked: false),
        MaterialList(id: "Lb", size: 0.24, isChecked: false),
    ]
    
    let surfaceTypes = ["Roof", "Facade"]
    let roofTypes = ["1x", "2x", "4x", "4x4"]
    
    var body: some View {
        NavigationView {
            Form{
                VStack(spacing:15){
                    Section(header:Text("Select type of surface").bold()) {
                        Picker("Type of surface", selection: $surface)
                            {ForEach(surfaceTypes, id: \.self) {Text($0)}}
                            .pickerStyle(.segmented)
                    }
                    VStack(spacing:15) {
                        HStack{
                            CapsuleTextField(text: "Length", value: $length)
                            CapsuleTextField(text: "Width", value: $width)
                            if surface == "Roof"{
                                Picker("", selection: $roofType)
                                    {ForEach (roofTypes, id: \.self) {Text($0)}}
                                    .foregroundColor(.gray)
                                    .pickerStyle(.menu)
                            
                            } else {
                                CapsuleTextField(text: "Height", value: $height)
                                    .padding(.vertical, 6)
                            }
                        }
                        if surface == "Roof" && roofType == "4x"{
                            HStack{
                                CapsuleTextField(text: "Length 1", value: $length1)
                                CapsuleTextField(text: "Width1", value: $width1)
                                CapsuleTextField(text: "", value: $height)
                            }
                        }
                        Section{
                            Button("Reset") {length=0.0; width=0.0; height=0.0; length1=0.0; width1=0.0}
                                .buttonStyle(.borderless).tint(.red).cornerRadius(15)
                        }
                    }
                }
                Section {
                    ForEach(surface == "Roof" ? $roofMaterials: $facadeMaterials)
                        {$material in Toggle(material.id, isOn: $material.isChecked)
                            material.isChecked ?
                                Section {
                                    Text("\(calculate(material:$material)) ")
                                        .foregroundStyle(.cyan).font(.system(size: 15))
                                } : nil
                            }
                        }
            }
            .navigationTitle("Materials calculating")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {amountIsFocused = false}
                        .foregroundColor(.cyan)
                    }
                }
            }
        }
    
    func calculate(material: Binding<MaterialList>) -> String {
        var message = ""
        var bay = 0.0
        let materialSize: Double = Double("\(material.size.wrappedValue)") ?? 0
        
        switch material.id {
        case "Lb", "КД", "WS":
            if length == 0.0 || width == 0.0 || height == 0.0{
                return "Установи длину, ширину, высоту"
            }
            if length < 0.5{
                return "- Минимальная длина 0.5мм"
            }
            if length > 6{
                message += "- Внимание! Возможная длина 0.5 - 6м. \n"
            }
            if length == width{
                bay = 1
            }
            else{
                bay = round((length/width) * 100) / 100
            }
            
            let materialCount = round(height / materialSize * bay * 100) / 100
            let additional1 = round(length / 3 * 100) / 100
            let additional2 = round(height / 3 * bay * 100) / 100
            message += "- Кол-во плашек: \(materialCount)\n"
            message += "- Кол-во пролётов: \(bay)\n"
            message += "- Начальная планка: \(additional1)\n"
            message += "- Стыковочная планка: \(additional2)\n"
            
            return message
            
        default:
            if length == 0.0 || width == 0.0 {
                return "Установи длину, ширину"
            }
            if width > 12 {
                message += "- Внимание! Возможная длина 0.5 - 12м. \n"
            }
            
            var materialCount = round(length / materialSize * 100) / 100
            
            var additional1 = length / 2
            var additional2 = width * 2 / 2
            
            if roofType == "2x" {
                materialCount = materialCount * 2
                additional1 = additional1 * 2
                additional2 = additional2 * 2
            }
            if roofType == "4x4" {
                materialCount = materialCount * 4
                additional1 = additional1 * 4
                additional2 = additional2 * 4
            }
            if roofType == "4x" {
                if length == 0.0 || width == 0.0 || length1 == 0.0 || width1 == 0.0 {
                    return "Установи дополнительные длину, ширину"
                }
                let materialCount1 = round(length1 / materialSize * 2 * 100) / 100
                materialCount = materialCount1 + (materialCount * 2)
                let add1 = length1 / 2 * 2
                additional1 = add1 + (additional1 * 2)
                let add2 = width1 * 2 / 2
                additional2 = add2 + (additional2 * 2)
            }
            
            message += "- Кол-во листов: \(materialCount)\n"
            message += "- Конёк: \(additional1)\n"
            message += "- Карнизная: \(additional1)\n"
            message += "- Торцевая: \(additional2)"
            
            return message
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
