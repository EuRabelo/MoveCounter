import SwiftUI
import CoreMotion
import CoreML

struct AICountingViewWORKING: View {
    @State private var motionManager = CMMotionManager()
    @State private var activityName = "N/A"
    @State private var counter = 0
    @State private var previousStateIn: MLMultiArray?// = MLMultiArray()
    @State private var previousStateInAux = Buffer(maxSize: MAXPREVIOUES)
    @State private var accelerometerXAux = Buffer(maxSize: MAXSIZE)
    @State private var accelerometerYAux = Buffer(maxSize: MAXSIZE)
    @State private var accelerometerZAux = Buffer(maxSize: MAXSIZE)
    @State private var gyroXAux = Buffer(maxSize: MAXSIZE)
    @State private var gyroYAux = Buffer(maxSize: MAXSIZE)
    @State private var gyroZAux = Buffer(maxSize: MAXSIZE)
    @State private var attitudePitchAux = Buffer(maxSize: MAXSIZE)
    @State private var attitudeRollAux = Buffer(maxSize: MAXSIZE)
    @State private var attitudeYawAux = Buffer(maxSize: MAXSIZE)
    
    let activityClassifier = try! MyActivityClassifier(configuration: .init())
    
    var body: some View {
        VStack {
            Text("Contador: \(counter)")
                .font(.system(size: 25))
                .padding()
            
            Button("Start") {
                startMotionUpdates()
            }
            .padding()
            
            Button("Stop") {
                stopMotionUpdates()
            }
            .padding()
        }
        .onAppear {
            motionManager.startDeviceMotionUpdates()
        }
        .onDisappear {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    private func startMotionUpdates() {
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { motionData, error in
            guard let motionData = motionData else { return }
            
            accelerometerXAux.add(motionData.userAcceleration.x)
            accelerometerYAux.add(motionData.userAcceleration.y)
            accelerometerZAux.add(motionData.userAcceleration.z)
            gyroXAux.add(motionData.rotationRate.x)
            gyroYAux.add(motionData.rotationRate.y)
            gyroZAux.add(motionData.rotationRate.z)
            attitudePitchAux.add(motionData.attitude.pitch)
            attitudeRollAux.add(motionData.attitude.roll)
            attitudeYawAux.add(motionData.attitude.yaw)
            
            if accelerometerXAux.isFull {
                do {
                    if previousStateIn == nil {
                        previousStateIn = try MLMultiArray(Array(repeating: 0.0, count: MAXPREVIOUES))
                    }
                    
                    let accelerometerX = try MLMultiArray(accelerometerXAux.values)
                    let accelerometerY = try MLMultiArray(accelerometerYAux.values)
                    let accelerometerZ = try MLMultiArray(accelerometerZAux.values)
                    
                    let gyroX = try MLMultiArray(gyroXAux.values)
                    let gyroY = try MLMultiArray(gyroYAux.values)
                    let gyroZ = try MLMultiArray(gyroZAux.values)
                    
                    let attitudePitch = try MLMultiArray(attitudePitchAux.values)
                    let attitudeRoll = try MLMultiArray(attitudeRollAux.values)
                    let attitudeYaw = try MLMultiArray(attitudeYawAux.values)
                    
                    var prediction: MyActivityClassifierOutput
                    
                    let input = MyActivityClassifierInput(accelerometerAccelerationX: accelerometerX,
                                                          accelerometerAccelerationY: accelerometerY,
                                                          accelerometerAccelerationZ: accelerometerZ,
                                                          gyroRotationX: gyroX,
                                                          gyroRotationY: gyroY,
                                                          gyroRotationZ: gyroZ,
                                                          motionPitch: attitudePitch,
                                                          motionRoll: attitudeRoll,
                                                          motionYaw: attitudeYaw,
                                                          stateIn: previousStateIn!)
                    
                    prediction = try activityClassifier.prediction(input: input)
                    
                    activityName = prediction.label
                    print("activityName: \(activityName)")
                    if activityName == "bicepis" {
                        counter+=1
//                        previousStateIn = nil
                        accelerometerXAux.clear()
                        accelerometerYAux.clear()
                        accelerometerZAux.clear()
                        gyroXAux.clear()
                        gyroYAux.clear()
                        gyroZAux.clear()
                        attitudePitchAux.clear()
                        attitudeRollAux.clear()
                        attitudeYawAux.clear()
                        
                    }
                    // Atualize o estado para o próximo ciclo
//                    print("state out: \(prediction.stateOut)")
                    previousStateIn = prediction.stateOut
                } catch {
                    print("Error making prediction: \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
