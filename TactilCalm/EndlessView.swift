//
//  EndlessView.swift
//  TactilCalm
//
//  Created by Mixon on 20.11.2025.
//

import SwiftUI

struct EndlessView: View {
    @State private var hapticShapes: [HapticShape] = []
    @State private var lastPlayedShapeId: UUID? = nil // Чтобы не вибрировать постоянно на одной и той же форме
    let images = ["bg1", "bg2", "bg3", "bg4", "bg5", "bg6", "bg7"]

       // Случайный элемент массива
       var randomImage: String {
           images.randomElement() ?? "bg1"
       }
    // Размеры экрана (для генерации позиций)
    @State private var viewSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color(hex: "1A1A1A").edgesIgnoringSafeArea(.all)
            
            VStack {
                // --- Haptic Canvas ---
                GeometryReader { geometry in
                    ZStack {
                        ForEach(hapticShapes) { shape in
                            // Отрисовка форм
                            shapeView(for: shape)
                                .position(shape.position)
                        }
                    }
                    .onAppear {
                        viewSize = geometry.size // Получаем размер при появлении
                        generateShapes(count: Int.random(in: 10...20)) // Генерируем формы
                        HapticManager.shared.prepareHaptics() // Подготавливаем haptics
                    }
                    // --- ЖЕСТ КАСАНИЯ ---
                    .gesture(
                        DragGesture(minimumDistance: 0) // minimumDistance: 0 чтобы ловить даже просто касание
                            .onChanged { value in
                                handleTouch(location: value.location)
                            }
                            .onEnded { _ in
                                lastPlayedShapeId = nil // Сброс при отпускании пальца
                            }
                    )
                }
            }.padding(.top, 30)
            Image(randomImage)
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
            
            
            // Кнопка перезапуска/генерации новых форм
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        generateShapes(count: Int.random(in: 10...20))
                    }) {
                        Image(systemName: "repeat.circle")
                            .font(.largeTitle)
                            .frame(width: 70, height: 70)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                }
                Spacer()
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ---
    
    // 1. ГЕНЕРАЦИЯ ФОРМ
    func generateShapes(count: Int) {
        var newShapes: [HapticShape] = []
        for _ in 0..<count {
            let type = ShapeType.random()
            let size = CGFloat.random(in: 40...120)
            let x = CGFloat.random(in: size/2...(viewSize.width - size/2))
            let y = CGFloat.random(in: size/2...(viewSize.height - size/2))
            
            // Случайные параметры вибрации для каждой формы
            let intensity = Float.random(in: 0.3...1.0)
            let sharpness = Float.random(in: 0.3...1.0)
            
            // Случайный цвет для визуализации
            let color = Color(
                red: Double.random(in: 0.4...0.9),
                green: Double.random(in: 0.4...0.9),
                blue: Double.random(in: 0.4...0.9)
            ).opacity(0.8)
            
            newShapes.append(HapticShape(
                type: type,
                position: CGPoint(x: x, y: y),
                size: size,
                hapticIntensity: intensity,
                hapticSharpness: sharpness,
                color: color
            ))
        }
        hapticShapes = newShapes
        lastPlayedShapeId = nil
        print("Сгенерировано \(count) форм.")
    }
    
    // 2. ОБРАБОТКА КАСАНИЯ
    func handleTouch(location: CGPoint) {
        for shape in hapticShapes {
            if shape.contains(location) {
                if shape.id != lastPlayedShapeId {
                    HapticManager.shared.playHapticFeedback(
                        intensity: shape.hapticIntensity,
                        sharpness: shape.hapticSharpness
                    )
                    lastPlayedShapeId = shape.id
                    break // Вибрируем только для одной формы под пальцем
                }
            }
        }
    }
    
    // 3. ВИЗУАЛИЗАЦИЯ ФОРМ
    @ViewBuilder
    func shapeView(for hapticShape: HapticShape) -> some View {
        switch hapticShape.type {
        case .rectangle:
            RoundedRectangle(cornerRadius: 10)
                .fill(hapticShape.color)
                .frame(width: hapticShape.size, height: hapticShape.size)
                .shadow(color: hapticShape.color.opacity(0.5), radius: 5)
        case .circle:
            Circle()
                .fill(hapticShape.color)
                .frame(width: hapticShape.size, height: hapticShape.size)
                .shadow(color: hapticShape.color.opacity(0.5), radius: 5)
        case .triangle:
            Triangle() // Пользовательская форма для треугольника
                .fill(hapticShape.color)
                .frame(width: hapticShape.size, height: hapticShape.size)
                .shadow(color: hapticShape.color.opacity(0.5), radius: 5)
        }
    }
    
    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
}


#Preview {
    EndlessView()
}
// Вставьте это в HapticPlaygroundView.swift или в отдельный файл
import SwiftUI

enum ShapeType: CaseIterable {
    case circle, rectangle, triangle
    
    // Вспомогательный метод для получения случайного типа
    static func random() -> ShapeType {
        ShapeType.allCases.randomElement()!
    }
}

struct HapticShape: Identifiable {
    let id = UUID()
    let type: ShapeType
    let position: CGPoint // Центр формы
    let size: CGFloat    // Размер (сторона квадрата, диаметр круга)
    let hapticIntensity: Float // Интенсивность вибрации для этой формы
    let hapticSharpness: Float // Резкость вибрации для этой формы
    let color: Color // Цвет для визуализации
    

    func contains(_ point: CGPoint) -> Bool {
        let halfSize = size / 2
        let dx = abs(point.x - position.x)
        let dy = abs(point.y - position.y)
        
        switch type {
        case .rectangle:
            return dx <= halfSize && dy <= halfSize
        case .circle:
            return sqrt(dx*dx + dy*dy) <= halfSize
        case .triangle:

            return dx <= halfSize && dy <= halfSize
        }
    }
}

import CoreHaptics
import UIKit

class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    private var engine: CHHapticEngine?
    
    init() {
        prepareHaptics()
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
        } catch {
            print("Haptic Engine Error: \(error.localizedDescription)")
        }
    }

    func playTick() {
        playHapticFeedback(intensity: 0.7, sharpness: 1.0)
    }
    
    func playSuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    

    func playHapticFeedback(intensity: Float, sharpness: Float, duration: Double = 0.05) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        

        let clampedIntensity = max(0.0, min(1.0, intensity))
        let clampedSharpness = max(0.0, min(1.0, sharpness))
        
        let hapticIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: clampedIntensity)
        let hapticSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: clampedSharpness)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [hapticIntensity, hapticSharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play custom haptic: \(error)")
        }
    }
}
