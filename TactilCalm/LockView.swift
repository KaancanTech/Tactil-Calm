//
//  LockView.swift
//  Tactil-Calm
//
//  Created by Mixon on 18.11.2025.
//

import SwiftUI

struct LockView: View {
    // --- СОСТОЯНИЕ ИГРЫ ---
    @State private var rotation: Double = 0
    @State private var secretSpot: Double = Double.random(in: 0..<360) // Случайная цель
    @State private var isUnlocked = false // Текущий статус: открыто или нет
    
    var body: some View {
        ZStack {
            // Фон
            Color(hex: "1A1A1A").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                
                // Заголовок / Статус
                VStack(spacing: 20) {
                    Text(isUnlocked ? "ACCESS GRANTED" : "HACK THE SAFE")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(isUnlocked ? .green : .gray)
                        .animation(.easeInOut, value: isUnlocked)
                    
                    Text(isUnlocked ? "Code: \(Int(secretSpot))°" : "Feel the vibration")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.7))
                }
                .padding()

                // --- КОЛЕСО ---
                ZStack {
                    // Внешний диск
                    Circle()
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 300, height: 300)
                        .shadow(color: isUnlocked ? .green.opacity(0.5) : .black.opacity(0.5), radius: 20, x: 0, y: 0) // Светится зеленым при победе
                    
                    // Риски
                    ForEach(0..<12) { index in
                        Rectangle()
                            .fill(isUnlocked ? Color.green : Color.orange)
                            .frame(width: 4, height: 20)
                            .offset(y: -120)
                            .rotationEffect(.degrees(Double(index) * 30))
                    }
                    
                    // Внутренняя часть (Ручка)
                    Circle()
                        .fill(Color(hex: "222222"))
                        .frame(width: 200, height: 200)
                        .overlay(
                            Circle().stroke(Color.black, lineWidth: 4)
                        )
                        // Индикатор
                        .overlay(
                            Circle()
                                .fill(isUnlocked ? Color.green : Color.orange)
                                .frame(width: 15, height: 15)
                                .offset(y: -80)
                                .shadow(color: isUnlocked ? .green : .clear, radius: 5)
                        )
                        
                    // Кнопка перезапуска (появляется в центре при победе)
                    if isUnlocked {
                        Button(action: resetLevel) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 80, height: 80)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .rotationEffect(.degrees(rotation))
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isUnlocked) // Анимация при победе
                .gesture(
                    // Блокируем жесты, если уже выиграли
                    isUnlocked ? nil : DragGesture().onChanged(handleDrag)
                )
                
                // Отображение текущего градуса
                Text("\(Int((Int(rotation) % 360 + 360) % 360))°")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(isUnlocked ? .green : .orange)
                    .opacity(isUnlocked ? 0 : 1) // Скрываем цифры при победе, чтобы не мешали
            }
        }
        .onAppear {
            HapticManagerFirst.shared.prepareHaptics()
            print("🤫 Псс... секретный код: \(Int(secretSpot))")
        }
    }
    
    // --- ЛОГИКА ---
    
    func handleDrag(value: DragGesture.Value) {
        let vector = CGVector(dx: value.location.x - 150, dy: value.location.y - 150)
        let angleRadians = atan2(vector.dy, vector.dx)
        let angleDegrees = angleRadians * 180 / .pi + 90
        
        let currentAngle = angleDegrees
        let normalizedAngle = (Int(currentAngle) % 360 + 360) % 360
        
        // Логика тиков (каждые 3 градуса для большей чувствительности)
        let step: Double = 3
        
        if Int(currentAngle / step) != Int(rotation / step) {
            
            // Проверка победы (допуск +- 2 градуса)
            if abs(Double(normalizedAngle) - secretSpot) < 2 {
                unlockSafe()
            } else {
                // Чем ближе к цели, тем "острее" может быть тик (опционально)
                HapticManagerFirst.shared.playTick()
            }
        }
        rotation = currentAngle
    }
    
    func unlockSafe() {
        guard !isUnlocked else { return }
        
        isUnlocked = true
        HapticManagerFirst.shared.playSuccess() // БУМ!
        print("✅ Сейф открыт!")
        
        // Доворачиваем колесо ровно на секретную точку для красоты
        withAnimation {
            rotation = secretSpot
        }
    }
    
    func resetLevel() {
        withAnimation {
            isUnlocked = false
            rotation = 0 // Сброс ручки в начало
        }
        
        // Генерируем новый код
        secretSpot = Double.random(in: 10..<350)
        print("🎲 Новый уровень! Код: \(Int(secretSpot))")
        
        // Легкая вибрация подтверждения
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}


// Вспомогательное расширение для Hex цветов
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    LockView()
}
