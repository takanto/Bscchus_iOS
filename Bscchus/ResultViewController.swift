//
//  ResultViewController.swift
//  Bscchus
//
//  Created by 菅剛大 on 2022/10/23.
//

import UIKit
import TensorFlowLite

class ResultViewController: UIViewController {
    
    @IBOutlet weak var savedView: UIView!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var gyroResult: UILabel!
    @IBOutlet weak var accelResult: UILabel!
    var selfie: UIImage?
    
    var gyroListx: [Double]?
    var gyroListy: [Double]?
    var gyroListz: [Double]?
    
    var accelListx: [Double]?
    var accelListy: [Double]?
    var accelListz: [Double]?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = selfie
        selfie = resizeImage(image: selfie!)
        runModels()
        print(gyroListx!)
        
        // Do any additional setup after loading the view.
    }
    
    func runModels() {
        // selfie model
        let VGGmodelPath = Bundle.main.path(forResource: "vgg", ofType: "tflite")
        let modelPath = Bundle.main.path(forResource: "logistic", ofType: "tflite")
        let ANNmodelPath = Bundle.main.path(forResource: "ANN", ofType: "tflite")
        //let AccelmodelPath = Bundle.main.path(forResource: "model", ofType: "tflite")
        
        
        // convert UIImage to CGImage
        
        if selfie == nil {
            print("selfie not set")
        }
        let image: CGImage! = selfie?.cgImage
        if image == nil {
            print("nil")
        }
        let context = CGContext(
          data: nil,
          width: 512, height: 512,
          bitsPerComponent: 8, bytesPerRow: 512 * 4,
          space: CGColorSpaceCreateDeviceRGB(),
          bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        // preprocessing image
        context!.draw(image, in: CGRect(x: 0, y: 0, width: 512, height: 512))
        let imageData = context!.data
        
        var inputData = Data()
        
        for row in 0..<512
        {
            for col in 0..<512
            {
                let offset = 4 * (row * context!.width + col)
                // (Ignore offset 0, the unused alpha channel)
                let red = imageData!.load(fromByteOffset: offset+1, as: UInt8.self)
                let green = imageData!.load(fromByteOffset: offset+2, as: UInt8.self)
                let blue = imageData!.load(fromByteOffset: offset+3, as: UInt8.self)

                // Normalize channel values to [-1.0, 1.0].
                var normalizedRed = (Float32(red) / 255.0)*2 - 1
                var normalizedGreen = (Float32(green) / 255.0)*2 - 1
                var normalizedBlue = (Float32(blue) / 255.0)*2 - 1

                // Append normalized values to Data object in RGB order.
                let elementSize = MemoryLayout.size(ofValue: normalizedRed)
                var bytes = [UInt8](repeating: 0, count: elementSize)
                memcpy(&bytes, &normalizedRed, elementSize)
                inputData.append(&bytes, count: elementSize)
                memcpy(&bytes, &normalizedGreen, elementSize)
                inputData.append(&bytes, count: elementSize)
                memcpy(&bytes, &normalizedBlue, elementSize)
                inputData.append(&bytes, count: elementSize)
          }
        }
        
        // Preprocessing accelerometers and gyroscopes
        
        var new_gyroListx: [Float] = []
        var new_gyroListy: [Float] = []
        var new_gyroListz: [Float] = []
        var new_accelListx: [Float] = []
        var new_accelListy: [Float] = []
        var new_accelListz: [Float] = []
        
        // converting double to float
        for i in 0..<16 {
            let gyrox_val = Float(gyroListx![i])
            let gyroy_val = Float(gyroListy![i])
            let gyroz_val = Float(gyroListz![i])
            let accelx_val = Float(accelListx![i])
            let accely_val = Float(accelListy![i])
            let accelz_val = Float(accelListz![i])
            
            new_gyroListx.append(gyrox_val)
            new_gyroListy.append(gyroy_val)
            new_gyroListz.append(gyroz_val)
            new_accelListx.append(accelx_val)
            new_accelListy.append(accely_val)
            new_accelListz.append(accelz_val)
        }
        
        // converting float array into data
        let inputGyrox = Data(fromArray: new_gyroListx)
        let inputGyroy = Data(fromArray: new_gyroListy)
        let inputGyroz = Data(fromArray: new_gyroListz)
        let inputAccelx = Data(fromArray: new_accelListx)
        let inputAccely = Data(fromArray: new_accelListy)
        let inputAccelz = Data(fromArray: new_accelListz)

        // Selfie ML predictions
        do {
            let VGGinterpreter = try Interpreter(modelPath: VGGmodelPath!)
            try VGGinterpreter.allocateTensors()
            try VGGinterpreter.copy(inputData, toInputAt: 0)
            try VGGinterpreter.invoke()
            let VGGoutputTensor = try VGGinterpreter.output(at: 0)
            
            let interpreter = try Interpreter(modelPath: modelPath!)
            try interpreter.allocateTensors()
            try interpreter.copy(VGGoutputTensor.data, toInputAt: 0)
            try interpreter.invoke()
            let outputTensor = try interpreter.output(at: 0)
            print(outputTensor.dataType)
            
            let selfie_result = outputTensor.data.toArray(type: Float32.self)
            result.text = "Selfie: \(selfie_result[0])"
            
            //if (error != nil) {/* Error */}
        }
        catch {
            print(error)
        }
        
        // accelerometers and gyroscope predictions
        do {
            let ANNinterpreter = try Interpreter(modelPath: ANNmodelPath!)
            try ANNinterpreter.allocateTensors()
            try ANNinterpreter.copy(inputGyrox, toInputAt: 0)
            try ANNinterpreter.invoke()
            let ANNoutputTensor_gyrox = try ANNinterpreter.output(at: 0)
            
            try ANNinterpreter.copy(inputGyroy, toInputAt: 0)
            try ANNinterpreter.invoke()
            let ANNoutputTensor_gyroy = try ANNinterpreter.output(at: 0)
            
            try ANNinterpreter.copy(inputGyroz, toInputAt: 0)
            try ANNinterpreter.invoke()
            let ANNoutputTensor_gyroz = try ANNinterpreter.output(at: 0)
            
            try ANNinterpreter.copy(inputAccelx, toInputAt: 0)
            try ANNinterpreter.invoke()
            let ANNoutputTensor_accelx = try ANNinterpreter.output(at: 0)
            
            try ANNinterpreter.copy(inputAccely, toInputAt: 0)
            try ANNinterpreter.invoke()
            let ANNoutputTensor_accely = try ANNinterpreter.output(at: 0)
            
            try ANNinterpreter.copy(inputAccelz, toInputAt: 0)
            try ANNinterpreter.invoke()
            let ANNoutputTensor_accelz = try ANNinterpreter.output(at: 0)
            
            let gyrox_result = ANNoutputTensor_gyrox.data.toArray(type: Float32.self)
            let gyroy_result = ANNoutputTensor_gyroy.data.toArray(type: Float32.self)
            let gyroz_result = ANNoutputTensor_gyroz.data.toArray(type: Float32.self)
            let accelx_result = ANNoutputTensor_accelx.data.toArray(type: Float32.self)
            let accely_result = ANNoutputTensor_accely.data.toArray(type: Float32.self)
            let accelz_result = ANNoutputTensor_accelz.data.toArray(type: Float32.self)
            
            gyroResult.text = "Gyroscope: \((gyrox_result[0] + gyroy_result[0] + gyroz_result[0])/3)"
            accelResult.text = "Accelerometer: \((accelx_result[0] + accely_result[0] + accelz_result[0])/3)"
        }
        catch {
            print(error)
        }
    }
    
    @IBAction func backPushed(_ sender: Any) {
        performSegue(withIdentifier: "tohome", sender: sender)
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, nil, nil)

    }
    
    func resizeImage (image: UIImage) -> UIImage? {
        
        var newsize : CGSize
        
        newsize = CGSize(width: 512, height: 512)
        
        
        let rect = CGRect(origin: .zero, size: newsize)
        
        UIGraphicsBeginImageContextWithOptions(newsize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Data {

    init<T>(fromArray values: [T]) {
        self = values.withUnsafeBytes { Data($0) }
    }

    func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
        var array = Array<T>(repeating: 0, count: self.count/MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
        return array
    }
}
