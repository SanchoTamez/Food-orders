import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let price: Double
}

struct ContentView: View {
    let menuItems: [MenuItem] = [
        MenuItem(title: "Burger", imageName: "hamburger", price: 8.99),
        MenuItem(title: "Fries", imageName: "fries", price: 3.49),
        MenuItem(title: "Taco", imageName: "taco", price: 4.99),
        MenuItem(title: "Salad", imageName: "leaf", price: 6.75),
        MenuItem(title: "Soda", imageName: "cup.and.saucer", price: 2.25)
    ]
    
    @State private var quantities: [UUID: Int] = [:]
    @State private var name = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var delivery = false
    @State private var paymentType = "ApplePay"
    @State private var showSummary = false
    
    let taxRate = 0.0805
    let deliveryRate = 0.10
    
    var totalItems: Int {
        quantities.values.reduce(0, +)
    }
    
    var subtotal: Double {
        menuItems.reduce(0) { result, item in
            result + (Double(quantities[item.id] ?? 0) * item.price)
        }
    }
    
    var tax: Double {
        subtotal * taxRate
    }
    
    var deliveryFee: Double {
        delivery ? subtotal * deliveryRate : 0
    }
    
    var total: Double {
        subtotal + tax + deliveryFee
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Cart Indicator
                    HStack {
                        Text(" Items in Cart: \(totalItems)")
                            .font(.headline)
                        Spacer()
                    }
                    
                    // Menu
                    ForEach(menuItems) { item in
                        HStack {
                            Image(systemName: item.imageName)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.headline)
                                Text(String(format: "$%.2f", item.price))
                                    .font(.subheadline)
                            }
                            Spacer()
                            Stepper(" \(quantities[item.id, default: 0])", value: Binding(
                                get: { quantities[item.id, default: 0] },
                                set: { quantities[item.id] = $0 }
                            ), in: 0...10)
                            .frame(width: 120)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // User Info
                    Group {
                        TextField("Your Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Phone Number", text: $phone)
                            .keyboardType(.phonePad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Delivery Toggle
                    Toggle("Deliver to Address?", isOn: $delivery)
                        .padding(.top)
                    
                    if delivery {
                        TextField("Delivery Address", text: $address)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Payment Type
                    Picker("Payment Method", selection: $paymentType) {
                        Text("ApplePay").tag("ApplePay")
                        Text("Pay at Store").tag("Pay at Store")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical)
                    
                    // Order Button
                    Button("Confirm Order") {
                        showSummary = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(name.isEmpty || phone.isEmpty || totalItems == 0 || (delivery && address.isEmpty))
                    
                }
                .padding()
            }
            .navigationTitle("")
            .sheet(isPresented: $showSummary) {
                OrderSummarySheet(name: name, phone: phone, address: address, delivery: delivery, total: total, paymentType: paymentType)
            }
        }
    }
}

struct OrderSummarySheet: View {
    let name: String
    let phone: String
    let address: String
    let delivery: Bool
    let total: Double
    let paymentType: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("✅ Order Confirmation")
                .font(.title2)
                .bold()
            
            Text("Name: \(name)")
            Text("Phone: \(phone)")
            if delivery {
                Text("Delivery Address: \(address)")
            } else {
                Text("Pickup at Store")
            }
            Text("Payment Method: \(paymentType)")
            Text(String(format: "Total: $%.2f", total))
                .font(.title3)
                .bold()
                .padding(.top)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
