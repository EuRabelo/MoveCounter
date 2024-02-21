import SwiftUI
import CoreMotion

struct RotationData {
    var yaw: Double = 0.0
    var pitch: Double = 0.0
    var roll: Double = 0.0
}

struct RotationMonitorView: View {
    @State private var rotationData = RotationData()
    let motionManager = CMMotionManager()
    @State private var maxYaw: Double = 0.0
    @State private var minYaw: Double = 0.0
    @State private var maxPitch: Double = 0.0
    @State private var minPitch: Double = 0.0
    @State private var maxRoll: Double = 0.0
    @State private var minRoll: Double = 0.0
    @State private var valorNormalizado: Double = 0.0

    var body: some View {
        VStack {
            Text("Max/Min Rotation Values")
                .font(.title)

            Text("Yaw: \(maxYaw, specifier: "%.2f") / \(minYaw, specifier: "%.2f")")
            Text("Pitch: \(maxPitch, specifier: "%.2f") / \(minPitch, specifier: "%.2f")")
            Text("Roll: \(maxRoll, specifier: "%.2f") / \(minRoll, specifier: "%.2f")")

            Spacer()
            
            Text("Current Rotation Values")
                .font(.title)

            Text("Yaw: \(rotationData.yaw, specifier: "%.2f")")
            Text("Pitch: \(rotationData.pitch, specifier: "%.2f")")
            Text("Roll: \(rotationData.roll, specifier: "%.2f")")
        }
        .padding()
        .onAppear {
            // Configurar a captura de dados de sensores (substitua isso com sua lógica real)
            // Supondo que você tem uma função para atualizar a rotação
            startSensorUpdates()
        }
    }

    
    private func startSensorUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
                if let attitude = motion?.attitude {
                    
                    rotationData.yaw = attitude.yaw * (180.0 / Double.pi)
                    rotationData.pitch = attitude.pitch * (180.0 / Double.pi)
                    rotationData.roll = attitude.roll * (180.0 / Double.pi)
                    
                    // Atualizar valores máximos e mínimos
                    maxYaw = max(maxYaw, rotationData.yaw)
                    minYaw = min(minYaw, rotationData.yaw)
                    maxPitch = max(maxPitch, rotationData.pitch)
                    minPitch = min(minPitch, rotationData.pitch)
                    maxRoll = max(maxRoll, rotationData.roll)
                    minRoll = min(minRoll, rotationData.roll)
                }
                
            }
            print("sem suporte")
        }
    }
}

struct RotationMonitorView_Previews: PreviewProvider {
    static var previews: some View {
        RotationMonitorView()
    }
}



/*
 anotações:
 
 para bicepis: 
    yaw: -0,25 0,25 = 0.5
    pitch: -0,9 1,26 = 2.16 -> unico fator
    roll: 0,5 -0,49 = 1
 
crucifixo:
 yaw: -1.77 2.06 = 3.8
 pitch: 0 1.53 = 1.53
 roll: -2.30 0.43 = 2.73 -> deveria ser o unico fator para resolver isso

 
 
em algulos do roll:
 bicepis: 82,65 -45,56
 tricepis: 179,79 -179,94
 
 elevação frontal: 179,9 -179,9
 elevação lateral: 0 -176,42
 
 peito: 0 154,92
 costas: 30,29 -154,58
 
*/
