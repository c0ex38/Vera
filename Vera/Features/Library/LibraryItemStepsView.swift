import SwiftUI

struct LibraryItemStepsView: View {
    let steps: [InstructionStep]
    @State private var currentStepIndex = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Step Progress Indicator
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentStepIndex ? Color.themePrimary : Color.themeTextSecondary.opacity(0.2))
                        .frame(height: 4)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            
            // TabView for swiping through steps
            TabView(selection: $currentStepIndex) {
                ForEach(steps.indices, id: \.self) { index in
                    stepCard(steps[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(minHeight: 450)
            
            // Navigation Buttons
            HStack(spacing: 20) {
                Button(action: {
                    withAnimation {
                        if currentStepIndex > 0 { currentStepIndex -= 1 }
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(currentStepIndex > 0 ? .themePrimary : .themeTextSecondary.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .background(Color.themeSurface)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                }
                .disabled(currentStepIndex == 0)
                
                Spacer()
                
                // Step Counter
                Text("\(currentStepIndex + 1) / \(steps.count)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.themeTextSecondary)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        if currentStepIndex < steps.count - 1 { currentStepIndex += 1 }
                    }
                }) {
                    Image(systemName: currentStepIndex == steps.count - 1 ? "checkmark" : "arrow.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(currentStepIndex == steps.count - 1 ? Color.green : Color.themePrimary)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
        }
    }
    
    private func stepCard(_ step: InstructionStep) -> some View {
        VStack(spacing: 24) {
            // Image/Icon Section
            ZStack {
                Circle()
                    .fill(Color.themePrimary.opacity(0.1))
                    .frame(width: 140, height: 140)
                
                if let imageName = step.imageName {
                    Image(systemName: imageName)
                        .font(.system(size: 60))
                        .foregroundColor(.themePrimary)
                } else {
                    Text("\(step.stepNumber)")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.themePrimary)
                }
            }
            .padding(.top, 20)
            
            VStack(spacing: 12) {
                Text(step.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.themeText)
                    .multilineTextAlignment(.center)
                
                ScrollView {
                    Text(step.description)
                        .font(.system(size: 17))
                        .lineSpacing(6)
                        .foregroundColor(.themeTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
                .frame(maxHeight: 180)
            }
            
            Spacer()
        }
        .padding(30)
        .background(Color.themeSurface)
        .cornerRadius(32)
        .shadow(color: .black.opacity(0.03), radius: 15, y: 10)
        .padding(.horizontal, 24)
    }
}

#Preview {
    LibraryItemStepsView(steps: [
        InstructionStep(stepNumber: 1, title: "Niyet ve Besmele", description: "Eûzü billâhi mineş-şeytânir-racîm. Bismillâhirrahmânirrahîm diyerek abdeste başlanır.", imageName: "drop.fill"),
        InstructionStep(stepNumber: 2, title: "Elleri Yıkama", description: "Eller bileklere kadar üç defa yıkanır. Parmak aralarının iyice yıkanmasına dikkat edilir.", imageName: "hand.point.up.braille.fill")
    ])
}
