//
//  RelaxVibratingScreen.swift
//  TactilCalm
//
//  Created by Mixon on 20.11.2025.
//


import SwiftUI
import CoreHaptics

// MARK: - Haptic Engine
final class HapticEngine: ObservableObject {
    private var engine: CHHapticEngine?

    init() {
        prepare()
    }

    func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptics not supported: \(error.localizedDescription)")
        }
    }

    // 1. Пульсация “мягкое дыхание”
    func patternBreath() {
        play([
            CHHapticEvent(eventType: .hapticContinuous,
                          parameters: [
                            .init(parameterID: .hapticIntensity, value: 0.3),
                            .init(parameterID: .hapticSharpness, value: 0.1)
                          ],
                          relativeTime: 0,
                          duration: 1.0),
            CHHapticEvent(eventType: .hapticContinuous,
                          parameters: [
                            .init(parameterID: .hapticIntensity, value: 0.15),
                            .init(parameterID: .hapticSharpness, value: 0.05)
                          ],
                          relativeTime: 1.0,
                          duration: 1.0)
        ])
    }

    // 2. Быстрая “игристая вибрация”
    func patternSpark() {
        var events: [CHHapticEvent] = []
        for i in 0..<6 {
            events.append(
                CHHapticEvent(eventType: .hapticTransient,
                              parameters: [
                                .init(parameterID: .hapticIntensity, value: Float.random(in: 0.3...0.8)),
                                .init(parameterID: .hapticSharpness, value: Float.random(in: 0.5...1.0))
                              ],
                              relativeTime: TimeInterval(i) * 0.15)
            )
        }
        play(events)
    }

    // 3. Вибрация “волна”
    func patternWave() {
        play([
            CHHapticEvent(eventType: .hapticContinuous,
                          parameters: [
                            .init(parameterID: .hapticIntensity, value: 0.1),
                            .init(parameterID: .hapticSharpness, value: 0.1)
                          ],
                          relativeTime: 0,
                          duration: 0.4),
            CHHapticEvent(eventType: .hapticContinuous,
                          parameters: [
                            .init(parameterID: .hapticIntensity, value: 0.4),
                            .init(parameterID: .hapticSharpness, value: 0.3)
                          ],
                          relativeTime: 0.4,
                          duration: 0.4),
            CHHapticEvent(eventType: .hapticContinuous,
                          parameters: [
                            .init(parameterID: .hapticIntensity, value: 0.15),
                            .init(parameterID: .hapticSharpness, value: 0.15)
                          ],
                          relativeTime: 0.8,
                          duration: 0.4)
        ])
    }

    // 4. “Бум-бум” — двойной мягкий удар
    func patternDoubleBeat() {
        play([
            CHHapticEvent(eventType: .hapticTransient,
                          parameters: [
                            .init(parameterID: .hapticIntensity, value: 0.6),
                            .init(parameterID: .hapticSharpness, value: 0.2)
                          ],
                          relativeTime: 0),

            CHHapticEvent(eventType: .hapticTransient,
                          parameters: [
                            .init(parameterID: .hapticIntensity, value: 0.4),
                            .init(parameterID: .hapticSharpness, value: 0.15)
                          ],
                          relativeTime: 0.25)
        ])
    }

    private func play(_ events: [CHHapticEvent]) {
        guard let engine else { return }
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Haptic error:", error.localizedDescription)
        }
    }
}

// MARK: - UI SCREEN
struct RelaxVibrationScreen: View {
    @StateObject private var haptics = HapticEngine()

    @State private var gradientShift = false

    var body: some View {
        ZStack {
            // MARK: Background gradient
            LinearGradient(
                colors: [
                    .purple.opacity(0.8),
                    .blue.opacity(0.8),
                    .pink.opacity(0.7)
                ],
                startPoint: gradientShift ? .topLeading : .bottomTrailing,
                endPoint: gradientShift ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 16).repeatForever(autoreverses: true), value: gradientShift)
            .onAppear { gradientShift.toggle() }

            VStack {
                Text("Relax Patterns")
                    .font(.largeTitle).bold()
                    .padding(.top, 40)
                Spacer()
            }
            // MARK: Buttons grid
            VStack(spacing: 80) {
                HStack(spacing: 40) {
                    hapticButton("Breath", color: .white.opacity(0.35)) {
                        haptics.patternBreath()
                    }
                    hapticButton("Spark", color: .white.opacity(0.35)) {
                        haptics.patternSpark()
                    }
                }

                HStack(spacing: 40) {
                    hapticButton("Wave", color: .white.opacity(0.35)) {
                        haptics.patternWave()
                    }
                    hapticButton("Beat", color: .white.opacity(0.35)) {
                        haptics.patternDoubleBeat()
                    }
                }
            }
        }
    }

    // MARK: Soft Circle Button
    func hapticButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(40)
                .frame(width: 160, height: 160)
                .background(color)
                .clipShape(Circle())
                .shadow(color: .white.opacity(0.15), radius: 10, x: 0, y: 4)
        }
    }
}


#Preview {
    RelaxVibrationScreen()
}
