//
//  ContentView.swift
//  Teste
//
//  Created by Victor Martins Rabelo on 03/01/24.
//

import SwiftUI
import CoreMotion

struct CountingView: View {
    
    @State private var rotationX: Double = 0.0
    @State private var rotationY: Double = 0.0
    @State private var rotationZ: Double = 0.0
    @State private var movementCount: Int = 0
    @State private var isMoving: Bool = false
//    private let braceDetectionManager = BraceDetectionManager()
    private let motionManager = CMMotionManager()
    
    var body: some View {
        VStack {
            Text("Angulo do braço")
                .font(.title)
                .padding()
            
            
            Text(String(format: "Rotação :x %.2f", rotationX))
                .font(.largeTitle)
                .padding()
            
            Text(String(format: "Rotação Y: %.2f", rotationY))
                .font(.largeTitle)
                .padding()
            
            Text(String(format: "Rotação Z: %.2f", rotationZ))
                .font(.largeTitle)
                .padding()
            
            Text("Repetições: \(movementCount)")
                .padding()
            
            Spacer()
        }
        .onAppear {
            startDeviceMotionUpdates()
        
//            braceDetectionManager.startDeviceMotionUpdate { angle in
//                angleValue = angle
//                
//                if angle > 0.8 && !isArmFolded {
//                    foldCount += 1
//                    isArmFolded = true
//                } else if angle <= 0.8 {
//                    isArmFolded = false
//                }
//            }
        }
    }
    func startDeviceMotionUpdates() {
            if motionManager.isDeviceMotionAvailable {
                motionManager.deviceMotionUpdateInterval = 0.1
                motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
                    if let attitude = motion?.attitude {
                        self.rotationX = attitude.pitch
                        self.rotationY = attitude.roll * (180.0 / Double.pi)
                        self.rotationZ = attitude.yaw
                        
                        let treshold = 0.7
                        
//                        let rollInDegrees = rotationY * (180.0 / Double.pi)
                        
                        
                        // Verificar se houve um movimento significativo
                        //                        if abs(self.rotationX) > treshold || abs(self.rotationY) > treshold || abs(self.rotationZ) > treshold {
                        if abs(self.rotationY) > treshold &&
                            !self.isMoving {
                            self.isMoving = true
                            self.movementCount += 1
                        } else {
                            self.isMoving = false
                        }
                    }
                }
            } else {
                print("O acelerômetro e/ou giroscópio não está disponível.")
            }
        }
}

//struct BraceAngle_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//
//}

struct BraceDetectionManager {
    let motionManager = CMMotionManager()
    
    func startDeviceMotionUpdate(completion: @escaping (Double)-> Void) {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
                if let attitude = motion?.attitude {
                    let pitch = attitude.pitch
                    completion(pitch)
                }
            }
            print("sem suporte")
        }
    }
}
/*
 em algulos do roll:
  bicepis: 82,65 -45,56
  tricepis: 179,79 -179,94
  
  elevação frontal: 179,9 -179,9
  elevação lateral: 0 -176,42
  
  peito: 0 154,92
  costas: 30,29 -154,58
 */
