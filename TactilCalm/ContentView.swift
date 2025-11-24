//
//  ContentView.swift
//  TactilCalm
//
//  Created by Mixon on 19.11.2025.
//

import SwiftUI

struct ContentView: View {
        var body: some View {
            NavigationStack {
                ZStack {
                    // Используем темный фон
                    Color(hex: "1A1A1A").edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 10) {
                        
                        // --- СТИЛЬНЫЙ ЗАГОЛОВОК ---
                        VStack {
                            Image(systemName: "lock.shield.fill") // Системная иконка
                                .font(.system(size: 40, weight: .ultraLight))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.orange, Color.green) // Двухцветный символ
                                .padding(.bottom, 5)
                            
                            Text("TACTIL-CALM")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .gray, radius: 3)
                        }
                        .padding(.bottom, 20)
                        
                        // --- КНОПКИ ПЕРЕХОДА ---
                        VStack(spacing: 30) {
                            NavigationLink(destination: EndlessView()) {
                                Text("Endless🧬")
                                    .font(.system(size: 24, weight: .medium))
                            }.buttonStyle(GlowingButtonStyle(glowColor: .pink))
                            // Кнопка 1: СЕЙФ (ОРАНЖЕВОЕ СВЕЧЕНИЕ)
                            NavigationLink(destination: LockView()) {
                                Text("Unlock Safe 🔒")
                                    .font(.system(size: 24, weight: .medium))
                            }
                            .buttonStyle(GlowingButtonStyle(glowColor: .orange))
                            
                            // Кнопка 2: МАТРИЦА (ЗЕЛЕНОЕ СВЕЧЕНИЕ)
                            NavigationLink(destination: MultiSliderView()) {
                                Text("Coincidence Matrix 📊")
                                    .font(.system(size: 24, weight: .medium))
                            }
                            .buttonStyle(GlowingButtonStyle(glowColor: .green))
                            NavigationLink(destination: RelaxVibrationScreen()) {
                                Text("Relax Patterns 🧿")
                                    .font(.system(size: 24, weight: .medium))
                            }
                            .buttonStyle(GlowingButtonStyle(glowColor: .blue))
                        }
                        .padding(.horizontal, 30)
                    }.padding(.bottom, 40)
                }
            }
        }
    }


// Вставьте этот код в отдельный файл Swift или перед MainMenuView
struct GlowingButtonStyle: ButtonStyle {
    // Цвет, который будет светиться (оранжевый или зеленый)
    var glowColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.title3, design: .monospaced, weight: .bold))
            .foregroundColor(.white)
            .padding(.vertical, 30)
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "222222")) // Темный фон кнопки
            .cornerRadius(20)
            .overlay(
                // 1. КОНТУР
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
            )
            // 2. ЗЕЛЕНАЯ/ОРАНЖЕВАЯ ТЕНЬ (СВЕЧЕНИЕ)
            .shadow(color: glowColor.opacity(configuration.isPressed ? 0.8 : 0.4), radius: 12, x: 0, y: 0)
            // 3. ВНУТРЕННЯЯ ТЕНЬ (для объема)
            .shadow(color: .black.opacity(0.9), radius: 5, x: 2, y: 2)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}

