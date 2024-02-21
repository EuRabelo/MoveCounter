import SwiftUI
import CoreMotion
import CoreML

struct AICountingView: View {
    //    @State private var accelerometerData: CMAccelerometerData?
    //    @State private var gyroscopeData: CMGyroData?
    //    @State private var motionData: CMDeviceMotion?
    @State private var artigo = Artigo()
    
    var body: some View {
        VStack {
//                        Text("Accelerometer Data: \(formattedAccelerometerData)")
//                        Text("Gyroscope Data: \(formattedGyroscopeData)")
//                        Text("Motion Data: \(formattedMotionData)")
                        Text("predição:\(artigo.resultado)")
                        Button("Start") {
                            artigo.startDeviceMotion()
                        }
                        Button("Stop") {
                            artigo.stopDeviceMotion()
                        }
                    }
        }
    }
    
    class Artigo {
        @Published var resultado = 0
        @Published var contador = 0
        
        struct ModelConstants {
            static let numOfFeatures = 9
            // Must be the same value you used while training
            static let predictionWindowSize = 25
            // Must be the same value you used while training
            static let sensorsUpdateFrequency = 1.0 / 10.0
            static let hiddenInLength = 20
            static let hiddenCellInLength = 200
        }
        private let classifier = MyActivityClassifier()
        private let modelName:String = "MyActivityClassifier"
        var currentIndexInPredictionWindow = 0
        let accX = try? MLMultiArray(
            shape: [ModelConstants.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        let accY = try? MLMultiArray(
            shape: [ModelConstants.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        let accZ = try? MLMultiArray(
            shape: [ModelConstants.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        let rotX = try? MLMultiArray(
            shape: [ModelConstants.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        let rotY = try? MLMultiArray(
            shape: [ModelConstants.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        let rotZ = try? MLMultiArray(
            shape: [ModelConstants.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        let motX = try? MLMultiArray(
            shape: [ModelConstants.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        let motY = try? MLMultiArray(
            shape: [ModelConstants.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        let motZ = try? MLMultiArray(
            shape: [ModelConstants.predictionWindowSize] as [NSNumber],
            dataType: MLMultiArrayDataType.double)
        var currentState = try? MLMultiArray(
            shape: [(ModelConstants.hiddenInLength +
              ModelConstants.hiddenCellInLength) as NSNumber],
            dataType: MLMultiArrayDataType.double)
        let motionManager = CMMotionManager()
        
        func startDeviceMotion() {
            guard motionManager.isDeviceMotionAvailable else {
                debugPrint("Core Motion Data Unavailable!")
                return
            }
            motionManager.deviceMotionUpdateInterval = ModelConstants.sensorsUpdateFrequency
            motionManager.showsDeviceMovementDisplay = true
            motionManager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
                guard let motionData = motionData else { return }
                // Add motion data sample to array
                self.addMotionDataSampleToArray(motionSample: motionData)
            }
        }
        
        func stopDeviceMotion() {
            guard motionManager.isDeviceMotionAvailable else {
                debugPrint("Core Motion Data Unavailable!")
                return
            }
            // Stop streaming device data
            motionManager.stopDeviceMotionUpdates()
            // Reset some parameters
            currentIndexInPredictionWindow = 0
        }
        
        func activityPrediction() -> Int? {
          // Perform prediction
            let modelPrediction = try? classifier.prediction(accelerometerAccelerationX: accX!, accelerometerAccelerationY: accY!, accelerometerAccelerationZ: accZ!, gyroRotationX: rotX!, gyroRotationY: rotY!, gyroRotationZ: rotZ!, motionPitch: motX!, motionRoll: motY!, motionYaw: motZ!, stateIn: currentState!)
        // Update the state vector
            print("model: \(modelPrediction)")
            if let modelPrediction = modelPrediction {
                currentState = modelPrediction.stateOut
            }
        // Return the predicted activity
            if let modelPrediction = modelPrediction {
                contador += 1
                return contador
            } else {
                return nil
            }
        }
        
        func addMotionDataSampleToArray(motionSample: CMDeviceMotion) {
            // Using global queue for building prediction array
            DispatchQueue.global().async {
                self.rotX![self.currentIndexInPredictionWindow] = motionSample.rotationRate.x as NSNumber
                self.rotY![self.currentIndexInPredictionWindow] = motionSample.rotationRate.y as NSNumber
                self.rotZ![self.currentIndexInPredictionWindow] = motionSample.rotationRate.z as NSNumber
                self.accX![self.currentIndexInPredictionWindow] = motionSample.userAcceleration.x as NSNumber
                self.accY![self.currentIndexInPredictionWindow] = motionSample.userAcceleration.y as NSNumber
                self.accZ![self.currentIndexInPredictionWindow] = motionSample.userAcceleration.z as NSNumber
                self.motX![self.currentIndexInPredictionWindow] = motionSample.attitude.pitch as NSNumber
                self.motY![self.currentIndexInPredictionWindow] = motionSample.attitude.roll as NSNumber
                self.motZ![self.currentIndexInPredictionWindow] = motionSample.attitude.yaw as NSNumber
                
                // Update prediction array index
                self.currentIndexInPredictionWindow += 1
                
                // If data array is full - execute a prediction
                if (self.currentIndexInPredictionWindow == ModelConstants.predictionWindowSize) {
                    // Move to main thread to update the UI
                    DispatchQueue.main.async {
                        // Use the predicted activity
                        self.resultado = self.activityPrediction() ?? self.resultado
//                                       self.label.text = self.activityPrediction() ?? "N/A"
                    }
                    // Start a new prediction window from scratch
                    self.currentIndexInPredictionWindow = 0
                }
            }
        }
    }
