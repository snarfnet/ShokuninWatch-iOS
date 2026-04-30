import CoreMotion
import SwiftUI
import AudioToolbox

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()

    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    @Published var yaw: Double = 0
    @Published var isLevel: Bool = false

    private var referenceAngle: Double = 0

    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            let p = motion.attitude.pitch * 180 / .pi
            let r = motion.attitude.roll * 180 / .pi
            let y = motion.attitude.yaw * 180 / .pi
            self.pitch = p - self.referenceAngle
            self.roll = r
            self.yaw = y
            let wasLevel = self.isLevel
            self.isLevel = abs(p) < 0.5 && abs(r) < 0.5
            if self.isLevel && !wasLevel {
                AudioServicesPlaySystemSound(1519) // haptic peek
            }
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }

    func resetReference() {
        referenceAngle = pitch + referenceAngle
    }
}
