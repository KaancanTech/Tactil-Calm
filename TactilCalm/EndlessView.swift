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
    @State private var particles: [TrailParticle] = []
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
            ZStack {
                Image(randomImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                SwiftUITrailView(particles: $particles)
                // СЛОЙ ЖЕСТОВ
                            Color.clear
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { value in
                                            // А. Вибрация
                                            handleTouch(location: value.location)
                                            
                                            // Б. Добавляем частицу в хвост
                                            addParticle(at: value.location)
                                        }
                                        .onEnded { _ in
                                            lastPlayedShapeId = nil
                                        }
                                )
                // Кнопка перезапуска/генерации новых форм
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            generateShapes(count: Int.random(in: 10...20))
                        }) {
                            Image(systemName: "repeat.circle")
                                .font(.largeTitle)
                                .frame(width: 50, height: 50)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                    }
                    Spacer()
                }.padding(.top, 20)
            }
            
        }
    }
    
    // --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ---
    func addParticle(at location: CGPoint) {
            // Генерируем цвет, зависящий от времени (для радуги) или позиции
            let hue = Double(particles.count % 20) / 20.0
            let color = Color(hue: hue, saturation: 1.0, brightness: 1.0)
            
            let newParticle = TrailParticle(position: location, color: color)
            particles.append(newParticle)
        }
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

import SwiftUI

struct TrailParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var creationDate = Date()
    var color: Color
}

struct SwiftUITrailView: View {
    // Принимаем массив частиц от родителя
    @Binding var particles: [TrailParticle]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date
                
                // Перебираем все частицы
                for particle in particles {
                    // Сколько времени прошло с момента создания частицы?
                    let timeAlive = now.timeIntervalSince(particle.creationDate)
                    let lifeTime: TimeInterval = 0.5 // Хвост живет 0.5 секунды
                    
                    // Если время жизни вышло — не рисуем (или рисуем с 0 прозрачностью)
                    if timeAlive < lifeTime {
                        
                        // Вычисляем прозрачность (от 1.0 до 0.0)
                        let fade = 1.0 - (timeAlive / lifeTime)
                        
                        // Вычисляем размер (уменьшается к концу)
                        let size = 20.0 * fade
                        
                        // Рисуем круг
                        var path = Path()
                        path.addEllipse(in: CGRect(
                            x: particle.position.x - size/2,
                            y: particle.position.y - size/2,
                            width: size,
                            height: size
                        ))
                        
                        // Добавляем эффект свечения
                        context.addFilter(.blur(radius: 3))
                        
                        context.fill(
                            path,
                            with: .color(particle.color.opacity(fade))
                        )
                    }
                }
            }
            // Важный момент: удаляем старые частицы из массива, чтобы не забить память
            .onChange(of: timeline.date) { newDate in
                cleanUpParticles(currentTime: newDate)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false) // Пропускаем касания
    }
    
    func cleanUpParticles(currentTime: Date) {
        // Удаляем частицы, которые старше 0.6 секунды
        // (чуть больше lifeTime, чтобы они успели исчезнуть визуально)
        if particles.count > 100 { // Оптимизация: чистим только если их много
             particles.removeAll(where: { currentTime.timeIntervalSince($0.creationDate) > 0.6 })
        }
    }
}
