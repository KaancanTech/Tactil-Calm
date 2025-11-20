//
//  HapticManager.swift
//  Tactil-Calm
//
//  Created by Mixon on 18.11.2025.
//

import Foundation
import CoreHaptics
import UIKit

class HapticManagerFirst: ObservableObject {
    // Синглтон для удобного доступа
    static let shared = HapticManagerFirst()
    
    private var engine: CHHapticEngine?
    
    init() {
        prepareHaptics()
    }
    
    // 1. Подготовка движка (обязательно при запуске)
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // Перезапуск движка, если приложение ушло в фон и вернулось
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
        } catch {
            print("Haptic Engine Error: \(error.localizedDescription)")
        }
    }
    
    // 2. Легкий механический щелчок (как шестеренка)
    func playTick() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        // Создаем резкое, короткое событие (Transient)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0) // Максимальная резкость
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
    
    // 3. Тяжелый удар (когда замок открыт)
    func playSuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
