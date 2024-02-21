//
//  CommonClasses.swift
//  Teste
//
//  Created by Victor Martins Rabelo on 19/02/24.
//

let MAXSIZE = 20
let MAXPREVIOUES = 400

import Foundation
import CoreMotion

class Buffer {
    var values: [Double]
    var isFull: Bool {
        get { values.count >= maxSize }
    }
    let maxSize: Int
    
    init(maxSize: Int, values: [Double] = []) {
        self.maxSize = maxSize
        self.values = values
    }
    
    func clear() {
        values = []
    }
    
    func add(_ value: Double) {
        if isFull {
            values.removeLast()
        }
        values.insert(value, at: 0)
    }
    
    func distance(to buffer: Buffer) -> Double {
        return dynamicTimeWarpingTo(values, buffer.values)
    }
    
    private func dynamicTimeWarpingTo(_ sequence1: [Double], _ sequence2: [Double]) -> Double {
        // Criar uma matriz de custo
        var costMatrix = Array(repeating: Array(repeating: 0.0, count: sequence2.count), count: sequence1.count)
        
        // Preencher a matriz de custo com as diferenças entre os pontos das sequências
        for i in 0..<sequence1.count {
            for j in 0..<sequence2.count {
                let cost = abs(sequence1[i] - sequence2[j]) // Aqui, estamos usando a diferença absoluta como medida de custo
                costMatrix[i][j] = cost
            }
        }
        
        // Criar uma matriz para armazenar os caminhos ótimos
        var dtwMatrix = Array(repeating: Array(repeating: Double.infinity, count: sequence2.count + 1), count: sequence1.count + 1)
        
        // Inicializar os valores da primeira linha e coluna da matriz DTW
        dtwMatrix[0][0] = 0.0
        for i in 1...sequence1.count {
            dtwMatrix[i][0] = Double.infinity
        }
        for j in 1...sequence2.count {
            dtwMatrix[0][j] = Double.infinity
        }
        
        // Calcular o DTW
        for i in 1...sequence1.count {
            for j in 1...sequence2.count {
                let cost = costMatrix[i-1][j-1]
                dtwMatrix[i][j] = cost + min(dtwMatrix[i-1][j], // Acima
                                              dtwMatrix[i][j-1], // À esquerda
                                              dtwMatrix[i-1][j-1]) // Diagonal
            }
        }
        
        // Retornar o valor DTW normalizado pela soma do comprimento das sequências
        return dtwMatrix[sequence1.count][sequence2.count] / Double(sequence1.count + sequence2.count)
    }
}

class MovementInTime {
    private var accelerometerBuffer: MovimentBuffer
    private var gyroBuffer: MovimentBuffer
    private var attitudeBuffer: MovimentBuffer
    var isFull: Bool {
        get { accelerometerBuffer.isFull && gyroBuffer.isFull && attitudeBuffer.isFull }
    }
    
    init(accelerometerBuffer: MovimentBuffer = MovimentBuffer(maxSize: MAXSIZE),
         gyroBuffer: MovimentBuffer = MovimentBuffer(maxSize: MAXSIZE),
         attitudeBuffer: MovimentBuffer = MovimentBuffer(maxSize: MAXSIZE)
    ) {
        self.accelerometerBuffer = accelerometerBuffer
        self.gyroBuffer = gyroBuffer
        self.attitudeBuffer = attitudeBuffer
    }
    
    func updateWith(accelerometer: CMAcceleration, gyro: CMRotationRate, attitude: CMAttitude) {
        accelerometerBuffer.update(x: accelerometer.x, y: accelerometer.y, z: accelerometer.z)
        gyroBuffer.update(x: gyro.x, y: gyro.y, z: gyro.z)
        attitudeBuffer.update(x: attitude.pitch, y: attitude.roll, z: attitude.yaw)
    }
    
    func clear() {
        accelerometerBuffer.clear()
        gyroBuffer.clear()
        attitudeBuffer.clear()
    }
    
    //Retorna um numero que é a média da diferença 
    func compare(to movement: MovementInTime) -> Double {
        let accelerometerDiference = accelerometerBuffer.distance(to: movement.accelerometerBuffer)
        let gyroDiference = gyroBuffer.distance(to: movement.gyroBuffer)
        let attitudeDiference = attitudeBuffer.distance(to: movement.attitudeBuffer)
        
        return (accelerometerDiference + gyroDiference + attitudeDiference)/3
    }
}

class MovimentBuffer {
    private let maxSize: Int
    lazy var x = Buffer(maxSize: maxSize)
    lazy var y = Buffer(maxSize: maxSize)
    lazy var z = Buffer(maxSize: maxSize)
    var isFull: Bool {
        get { x.isFull && y.isFull && z.isFull }
    }
    
    init(maxSize: Int) {
        self.maxSize = maxSize
    }
    
    func distance(to buffer: MovimentBuffer) -> Double {
        let distanceX = x.distance(to: buffer.x)
        let distanceY = y.distance(to: buffer.y)
        let distanceZ = z.distance(to: buffer.z)
        
        return (distanceX + distanceY + distanceZ)/3
    }

    func update(x: Double, y: Double, z: Double) {
        self.x.add(x)
        self.y.add(y)
        self.z.add(z)
    }
    
    func clear() {
        x.clear()
        y.clear()
        z.clear()
    }
}
