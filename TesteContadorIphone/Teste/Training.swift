//import SwiftUI
//import CoreMotion
//
//struct TrainingView: View {
//    @State private var buttonText = "Iniciar"
//    let motionManager = CMMotionManager()
//
//    var body: some View {
//        VStack {
//            Button(action: {
//                if self.buttonText == "Iniciar" {
//                    self.startButtonPressed()
//                } else {
//                    self.stopButtonPressed()
//                }
//            }) {
//                Text(buttonText)
//                    .padding()
//                    .foregroundColor(.white)
//                    .background(Color.blue)
//                    .cornerRadius(8)
//            }
//        }
//        .padding()
//    }
//
//    func startButtonPressed() {
//        // Iniciar a captura de dados do acelerômetro e giroscópio
//        motionManager.startAccelerometerUpdates()
//        motionManager.startGyroUpdates()
//
//        // Atualizar o texto do botão
//        buttonText = "Parar"
//    }
//
//    func stopButtonPressed() {
//        // Parar a captura de dados do acelerômetro e giroscópio
//        motionManager.stopAccelerometerUpdates()
//        motionManager.stopGyroUpdates()
//
//        // Atualizar o texto do botão
//        buttonText = "Iniciar"
//    }
//
//    func captureMotionData() -> String {
//        guard let accelerometerData = motionManager.accelerometerData else { return }
//        guard let gyroData = motionManager.gyroData else { return }
//
//        // Aqui você tem acesso aos dados do acelerômetro e giroscópio
//        let accelerometerX = accelerometerData.acceleration.x
//        let accelerometerY = accelerometerData.acceleration.y
//        let accelerometerZ = accelerometerData.acceleration.z
//
//        let gyroX = gyroData.rotationRate.x
//        let gyroY = gyroData.rotationRate.y
//        let gyroZ = gyroData.rotationRate.z
//
//        // Adicione lógica para salvar ou processar os dados conforme necessário
//        writeToExistingFile("Acelerômetro: X \(accelerometerX), Y \(accelerometerY), Z \(accelerometerZ)\n")
//        writeToExistingFile("Giroscópio: X \(gyroX), Y \(gyroY), Z \(gyroZ)\n")
//        return ""
//    }
//
//    func writeToExistingFile(_ text: String) {
//        // Adicione lógica para abrir o arquivo existente, adicionar texto e salvar
//        // Por exemplo, você pode usar FileManager para manipular arquivos
//        let filePath = "/caminho/do/seu/arquivo.txt"
//
//        do {
//            let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: filePath))
//            fileHandle.seekToEndOfFile()
//            fileHandle.write(text.data(using: .utf8)!)
//            fileHandle.closeFile()
//        } catch {
//            print("Erro ao escrever no arquivo: \(error)")
//        }
//    }
//}
