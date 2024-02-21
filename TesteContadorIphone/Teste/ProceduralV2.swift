//
//  ProceduralV2.swift
//  Teste
//
//  Created by Victor Martins Rabelo on 19/02/24.
//

import SwiftUI
import CoreMotion

struct ProceduralV2: View {
    @State private var motionManager = CMMotionManager()
    @State private var activityName = "N/A"
    @State private var counter = 0
    @State var maior = -100.0
    @State var menor = 100.0
    
    private var referenceMovement: MovementInTime = {
        let accelerometer = MovimentBuffer(maxSize: MAXSIZE)
        accelerometer.x = Buffer(maxSize: MAXSIZE, values: [
            0.9694366455078130,
            0.9794769287109380,
            0.9245147705078130,
            0.87823486328125,
            0.7084808349609380,
            0.574859619140625,
            0.2398834228515630,
            -0.06304931640625,
            -0.0582122802734375,
            -0.2672119140625,
            -0.3585662841796880,
            -0.1500396728515630,
            -0.449798583984375,
            -0.38446044921875,
            0.03533935546875,
            0.1890716552734380,
            0.4242095947265630
        ])
        accelerometer.y = Buffer(maxSize: MAXSIZE, values: [
            -0.0088958740234375,
             0.0330047607421875,
             -0.020263671875,
             -0.0071258544921875,
             -0.132659912109375,
             -0.1177520751953125,
             -0.140106201171875,
             -0.2557220458984375,
             -0.0369110107421875,
             -0.05078125,
             -0.2527618408203125,
             -0.1753692626953125,
             -0.2592620849609375,
             -0.23895263671875,
             -0.140655517578125,
             -0.1660003662109375,
             -0.1509552001953125
        ])
        accelerometer.z = Buffer(maxSize: MAXSIZE, values: [
            -0.1572418212890625,
             -0.23583984375,
             -0.1492919921875,
             -0.072723388671875,
             -0.07135009765625,
             -0.190582275390625,
             -0.5478363037109375,
             -0.925933837890625,
             -1.530960083007812,
             -1.398895263671875,
             -1.96417236328125,
             -1.483627319335938,
             -1.33148193359375,
             -1.14849853515625,
             -1.192977905273438,
             -0.8943328857421875,
             -0.4901275634765625
        ])
        
        let gyro = MovimentBuffer(maxSize: MAXSIZE)
        gyro.x = Buffer(maxSize: MAXSIZE, values: [
            0.002315352205187082,
            0.002351304981857538,
            -0.005689044483006001,
            -0.005689044483006001,
            -0.1800318211317062,
            0.206184059381485,
            0.2289969623088837,
            -0.3887695968151093,
            -0.3887695968151093,
            -0.0745575875043869,
            -0.2028846740722656,
            1.005879640579224,
            0.5633469820022583,
            0.4071043729782104,
            -0.1358268111944199,
            0.1179071962833405,
            0.6348070502281189
        ])
        gyro.y = Buffer(maxSize: MAXSIZE, values: [
            -0.009927998296916485,
             0.03686001524329185,
             -0.2131455689668655,
             -0.2131455689668655,
             -1.553295135498047,
             -1.981964945793152,
             -2.908828973770142,
             -3.578547477722168,
             -3.578547477722168,
             -2.494382619857788,
             -3.614272356033325,
             1.420596957206726,
             2.561501979827881,
             2.772757053375244,
             2.698454856872559,
             3.318948984146118,
             2.848701477050781
        ])
        gyro.z = Buffer(maxSize: MAXSIZE, values: [
            0.1001508384943008,
            0.05883987993001938,
            0.122599683701992,
            0.122599683701992,
            0.5205680727958679,
            0.8408446311950684,
            1.000702261924744,
            0.8118201494216919,
            0.8118201494216919,
            0.8135358095169067,
            -0.04154398292303085,
            1.079809069633484,
            0.04368489608168602,
            -0.5710808038711548,
            -0.6685447692871094,
            -0.390357106924057,
            -0.2275093197822571
        ])
        
        let attitude = MovimentBuffer(maxSize: MAXSIZE)
        attitude.x = Buffer(maxSize: MAXSIZE, values: [
            -0.01053775654281491,
             -0.01328102989926816,
             -0.004580423464692118,
             0.009495125050327499,
             0.05360310121377192,
             0.1022844256958185,
             0.1815969917225804,
             0.2635915791604598,
             0.2093552285146269,
             0.1562370944923897,
             0.1346641758409069,
             0.1032188569475147,
             0.1514371658567943,
             0.2095376653609168,
             0.2040537068917857,
             0.1837844267551253,
             0.193798185909083
        ])
        attitude.y = Buffer(maxSize: MAXSIZE, values: [
            1.359281888462894,
            1.360108425091679,
            1.357324719208164,
            1.328949069419288,
            1.244633993727188,
            1.084999745747591,
            0.8631471231415292,
            0.5360576073266115,
            0.1657999445049135,
            -0.1172077912465367,
            -0.3977864831739414,
            -0.5125952771236756,
            -0.3548079997241659,
            -0.08201072124368521,
            0.2200911394266528,
            0.5269733315462846,
            0.8668339574195242
        ])
        attitude.z = Buffer(maxSize: MAXSIZE, values: [
            0.6885501499284534,
            0.7080258581492064,
            0.7064718202021905,
            0.7076330024830935,
            0.704299285395237,
            0.7325307930410839,
            0.7698919807464981,
            0.8380877576034396,
            0.90000014120014,
            0.9158632531039419,
            1.008121924791596,
            1.013043200737616,
            1.125914037431584,
            1.134557451724441,
            1.060297734475012,
            0.9991817297078101,
            0.9468308295097696
        ])
        
        let referenceMovement = MovementInTime(accelerometerBuffer: accelerometer, gyroBuffer: gyro, attitudeBuffer: attitude)
        return referenceMovement
    }()
    
    private var userMovementBuffer = MovementInTime()
    
    var body: some View {
        VStack {
            Text("Contador: \(counter)")
                .font(.system(size: 25))
                .padding()
            
            Button("Start") {
                startMotionUpdates()
//                testeCalibracao()
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
            
            userMovementBuffer.updateWith(accelerometer: motionData.userAcceleration, gyro: motionData.rotationRate, attitude: motionData.attitude)
            
            if userMovementBuffer.isFull {
                let result = userMovementBuffer.compare(to: referenceMovement)
                print("result: \(result)")
                maior = maior < result ? result : maior
                menor = menor > result ? result : menor
                if result < 0.3 {
                    counter+=1
                    userMovementBuffer.clear()
                }
            }
            
        }
    }
    
    private func testeCalibracao() {
        let teste = Buffer(maxSize: MAXSIZE, values: [
            0.9694366455078130,
            0.9794769287109380,
            0.9245147705078130,
            0.87823486328125,
            0.7084808349609380,
            0.574859619140625,
            0.2398834228515630,
            -0.06304931640625,
            -0.0582122802734375,
            -0.2672119140625,
            -0.3585662841796880,
            -0.1500396728515630,
            -0.449798583984375,
            -0.38446044921875,
            0.03533935546875,
            0.1890716552734380,
            0.4242095947265630,
            0.6458587646484380
        ])
        
        let teste2 = Buffer(maxSize: MAXSIZE, values: [
            0.753173828125,
            0.5584716796875,
            0.591094970703125,
            0.50982666015625,
            0.288604736328125,
            0.3919677734375,
            0.141693115234375,
            -0.292388916015625,
            -0.4272308349609380,
            -0.484619140625,
            -0.23583984375,
            -0.5975494384765630,
            -0.673980712890625,
            -0.2363433837890630,
            0.18670654296875,
            0.4355621337890630,
            0.706146240234375,
            0.7091827392578130
        ])
        
        let teste3 = Buffer(maxSize: MAXSIZE, values: [
            0.9694366455078130,
            0.9794769287109380,
            0.9245147705078130,
            0.87823486328125,
            0.7084808349609380,
            0.574859619140625,
            0.2398834228515630,
            -0.06304931640625,
            -0.0582122802734375,
            -0.2672119140625,
            -0.3585662841796880,
            -0.1500396728515630,
            -0.449798583984375,
            -0.38446044921875,
            0.03533935546875,
            0.1890716552734380,
            0.4242095947265630,
            0.6458587646484380
        ])
        
        let result = teste.distance(to: teste2)
        print(result)
    }
    
    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
