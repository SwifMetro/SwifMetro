import SwiftUI

// Example app showing SwiftMetro hot reload in action
@main
struct ExampleApp: App {
    init() {
        #if DEBUG
        // Start SwiftMetro hot reload
        SwiftMetro.shared.start()
        
        // Optional: Configure callbacks
        SwiftMetro.shared.onReload = {
            print("🔥 App reloaded!")
        }
        
        SwiftMetro.shared.onConnect = {
            print("✅ Connected to SwiftMetro bundler")
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var counter = 0
    @State private var backgroundColor = Color.blue
    @State private var fontSize: CGFloat = 24
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Hero section
                VStack(spacing: 10) {
                    Text("🔥 SwiftMetro")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Hot Reload Demo")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [backgroundColor, backgroundColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(radius: 10)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(.spring(), value: isAnimating)
                
                // Counter section
                VStack(spacing: 15) {
                    Text("Counter: \(counter)")
                        .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                    
                    HStack(spacing: 20) {
                        Button(action: { counter -= 1 }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                        }
                        
                        Button(action: { counter += 1 }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                // Controls
                VStack(alignment: .leading, spacing: 15) {
                    Text("Try changing these values in code:")
                        .font(.headline)
                    
                    HStack {
                        Text("• backgroundColor = .")
                        Text("blue").foregroundColor(.blue).bold()
                    }
                    
                    HStack {
                        Text("• fontSize = ")
                        Text("24").foregroundColor(.orange).bold()
                    }
                    
                    HStack {
                        Text("• Add new UI elements")
                    }
                }
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(10)
                
                // Action buttons
                HStack(spacing: 15) {
                    Button("Animate") {
                        withAnimation {
                            isAnimating.toggle()
                        }
                    }
                    .buttonStyle(ModernButtonStyle(color: .purple))
                    
                    Button("Random Color") {
                        backgroundColor = [.blue, .red, .green, .orange, .purple].randomElement()!
                    }
                    .buttonStyle(ModernButtonStyle(color: .orange))
                    
                    Button("Log to Console") {
                        SwiftMetro.shared.log("Button tapped at \(Date())")
                    }
                    .buttonStyle(ModernButtonStyle(color: .green))
                }
                
                Spacer()
                
                // Instructions
                Text("Save this file to see hot reload in action! 🚀")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .navigationBarHidden(true)
        }
        .enableHotReload() // Enable hot reload for this view
    }
}

// Custom button style
struct ModernButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Additional demo views
struct DetailView: View {
    @State private var text = "Edit me and save!"
    @State private var sliderValue: Double = 50
    @State private var isToggled = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Detail View")
                .font(.largeTitle)
                .bold()
            
            TextField("Enter text", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Slider(value: $sliderValue, in: 0...100)
                .padding()
            
            Toggle("Feature Toggle", isOn: $isToggled)
                .padding()
            
            if isToggled {
                Text("Feature is enabled!")
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .enableHotReload()
    }
}

// Grid demo view
struct GridDemoView: View {
    let items = Array(1...20)
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(items, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(Double(item) / 20))
                        .frame(height: 80)
                        .overlay(
                            Text("\(item)")
                                .foregroundColor(.white)
                                .font(.title2.bold())
                        )
                }
            }
            .padding()
        }
        .enableHotReload()
    }
}

// Animation demo
struct AnimationDemoView: View {
    @State private var isRotating = false
    @State private var isScaling = false
    
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "flame.fill")
                .font(.system(size: 100))
                .foregroundColor(.orange)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .scaleEffect(isScaling ? 1.5 : 1.0)
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isRotating)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isScaling)
                .onAppear {
                    isRotating = true
                    isScaling = true
                }
            
            Text("SwiftMetro")
                .font(.largeTitle.bold())
            
            Text("Hot reload preserves animations!")
                .foregroundColor(.gray)
        }
        .enableHotReload()
    }
}

// List demo
struct ListDemoView: View {
    @State private var items = ["Swift", "SwiftUI", "UIKit", "Combine", "Core Data"]
    @State private var newItem = ""
    
    var body: some View {
        VStack {
            List {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Image(systemName: "chevron.right.circle.fill")
                            .foregroundColor(.blue)
                        Text(item)
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
                .onDelete { indexSet in
                    items.remove(atOffsets: indexSet)
                }
            }
            
            HStack {
                TextField("Add item", text: $newItem)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Add") {
                    if !newItem.isEmpty {
                        items.append(newItem)
                        newItem = ""
                    }
                }
                .buttonStyle(ModernButtonStyle(color: .blue))
            }
            .padding()
        }
        .enableHotReload()
    }
}