import SwiftUI
import CoreMotion

class DisplacementCalculator: ObservableObject {
    @Published var displacementX: Double = 0.0
    @Published var displacementY: Double = 0.0
    @Published var displacementZ: Double = 0.0

    private var accelerationBufferX: [Double] = []
        private var accelerationBufferY: [Double] = []
        private var accelerationBufferZ: [Double] = []
        private let bufferSize = 5  // Tamanho do buffer para o filtro de média móvel

    
    
    
    private let motionManager = CMMotionManager()
    private var startTime: TimeInterval?
    private var initialPosition: (x: Double, y: Double, z: Double)?

    init() {
        setupMotionManager()
    }

    private func setupMotionManager() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1

            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (accelerometerData, error) in
                guard let self = self else { return }

                if let accelerometerData = accelerometerData {
                    let acceleration = accelerometerData.acceleration
//                    print("x: \(String(format: "%.2f", acceleration.x))")
//                    print("y: \(String(format: "%.2f", acceleration.y))")
//                    print("z: \(String(format: "%.2f", acceleration.z))")
                    print("zsum: \(String(format: "%.2f", acceleration.z+acceleration.x+acceleration.y))")
//                    self.calculateDisplacement(acceleration: acceleration)
                }
            }
        }
    }

    private func calculateDisplacement(acceleration: CMAcceleration) {
        let currentTime = CACurrentMediaTime()

        if startTime == nil {
            startTime = currentTime
            initialPosition = (0.0, 0.0, 0.0)
            return
        }

        guard let initialPosition = initialPosition else { return }

        let timeElapsed = currentTime - startTime!
        let gravity = 9.8

        let displacementX = initialPosition.x + 0.5 * acceleration.x * pow(timeElapsed, 2) * gravity
        let displacementY = initialPosition.y + 0.5 * acceleration.y * pow(timeElapsed, 2) * gravity
        let displacementZ = initialPosition.z + 0.5 * acceleration.z * pow(timeElapsed, 2) * gravity

        DispatchQueue.main.async {
            self.displacementX = displacementX
            self.displacementY = displacementY
            self.displacementZ = displacementZ
        }
    }
}

struct DisplacementView: View {
    @ObservedObject var displacementCalculator = DisplacementCalculator()

    var body: some View {
        VStack {
            Text("Deslocamento X: \(String(format: "%.2f", displacementCalculator.displacementX)) cm")
            Text("Deslocamento Y: \(String(format: "%.2f", displacementCalculator.displacementY)) cm")
            Text("Deslocamento Z: \(String(format: "%.2f", displacementCalculator.displacementZ)) cm")
        }
        .padding()
    }
}
