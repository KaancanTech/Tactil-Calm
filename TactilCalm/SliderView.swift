//
//  SliderView.swift
//  Tactil-Calm
//
//  Created by Mixon on 18.11.2025.
//


import SwiftUI

struct MultiSliderView: View {
    // Список всех ползунков на уровне
    @State private var sliders: [SliderItem] = []
    @State private var isLevelComplete: Bool = false
    
    // Допуск: насколько близко нужно быть к цели (0.01 = 1%)
    let tolerance: Double = 1.0
    
    var body: some View {
        ZStack {
            Color(hex: "1A1A1A").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("COINCIDENCE MATRIX")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                
                // --- СПИСОК ПОЛЗУНКОВ ---
                ForEach($sliders) { $slider in
                    VStack(alignment: .center) {
                        // Визуальный индикатор (например, 50/100)
                        Text(slider.isLockedIn ? "✅ Done" : "Current: \(Int(slider.currentValue))")
                            .font(.callout).bold()
                            .foregroundColor(slider.isLockedIn ? .green : .orange)
                            .padding(.bottom)
                        
                        // Сам ползунок
                        Slider(value: $slider.currentValue, in: 0...100, step: 1) {
                            // Пустой лэйбл
                        } minimumValueLabel: {
                            Text("0")
                                .foregroundStyle(.gray)
                        } maximumValueLabel: {
                            Text("100")
                                .foregroundStyle(.gray)
                        }
                        .tint(slider.isLockedIn ? .green : .orange)
                        .padding(.horizontal)
                        // Логика проверки при изменении значения
                        .onChange(of: slider.currentValue) { newValue in
                            checkSliderLock(for: slider.id, newValue: newValue)
                        }
                    }
                }.padding()
                
                Spacer()
                
                // --- КНОПКА ПЕРЕЗАПУСКА (появляется при победе) ---
                
                    Button(action: resetLevel) {
                        Text("NEW LEVEL")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .padding()
                    .transition(.scale)
                    .opacity(isLevelComplete ? 1 : 0)
            }
            .padding()
        }
        .onAppear(perform: generateLevel)
    }
    
    // --- ФУНКЦИИ ЛОГИКИ ИГРЫ ---
    
    // 1. ГЕНЕРАЦИЯ УРОВНЯ
    func generateLevel() {
        // Выбираем случайное количество ползунков (от 2 до 6)
        let count = Int.random(in: 2...4)
        var newSliders: [SliderItem] = []
        
        for _ in 0..<count {
            // Случайная цель от 10 до 90 (чтобы избежать краев)
            let target = Double.random(in: 10...90).rounded()
            let slider = SliderItem(targetValue: target)
            newSliders.append(slider)
        }
        
        sliders = newSliders
        isLevelComplete = false

    }
    
    // 2. ПРОВЕРКА ОДНОГО ПОЛЗУНКА
    func checkSliderLock(for id: UUID, newValue: Double) {
        guard let index = sliders.firstIndex(where: { $0.id == id }) else { return }
        
        let slider = sliders[index]
        
        // Считаем разницу между текущим значением и целью
        let difference = abs(newValue - slider.targetValue)
        
        // Если попали в допуск
        if difference <= tolerance {
            if !slider.isLockedIn {
                // Только что попали: фиксируем, играем тик
                sliders[index].isLockedIn = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                
                // Проверяем, выиграна ли вся игра
                checkWinCondition()
            }
        } else {
            // Если вышли из допуска, разблокируем
            if slider.isLockedIn {
                sliders[index].isLockedIn = false
                isLevelComplete = false
            }
        }
    }
    
    // 3. ПРОВЕРКА ПОБЕДЫ
    func checkWinCondition() {
        let allLocked = sliders.allSatisfy { $0.isLockedIn == true }
        
        if allLocked {
            isLevelComplete = true
            // Используем мощный тик из HapticManager (если он есть)
            HapticManager.shared.playSuccess()
        } else {
            isLevelComplete = false
        }
    }
    
    // 4. ПЕРЕЗАПУСК
    func resetLevel() {
        withAnimation {
            isLevelComplete = false
        }
        // С небольшой задержкой, чтобы анимация прошла
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            generateLevel()
        }
    }
}


// Структура для одного ползунка
struct SliderItem: Identifiable {
    let id = UUID()
    // Текущее значение ползунка
    var currentValue: Double = 0
    // Значение, которое нужно угадать (цель)
    let targetValue: Double
    // Флаг, который становится true, когда цель угадана
    var isLockedIn: Bool = false
}

#Preview {
    MultiSliderView()
}
