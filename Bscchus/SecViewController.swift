//
//  SecViewController.swift
//  Bscchus
//
//  Created by 菅剛大 on 2022/09/14.
//

import UIKit
import CoreMotion

class SecViewController: UIViewController {
    
    @IBOutlet weak var gyrox: UILabel!
    @IBOutlet weak var gyroy: UILabel!
    @IBOutlet weak var gyroz: UILabel!
    
    @IBOutlet weak var accelx: UILabel!
    @IBOutlet weak var accely: UILabel!
    @IBOutlet weak var accelz: UILabel!
    
    @IBOutlet weak var resultShow: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    var motion = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultShow.isUserInteractionEnabled = false
        resultShow.isHidden = true
        
        MyAccel()
        MyGyro()
        
        if (image != nil) {
            self.imageView.image = image
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
        
        // Do any additional setup after loading the view.
    }
    
    var gyroListx = Array<Double>()
    var gyroListy = Array<Double>()
    var gyroListz = Array<Double>()
    func MyGyro() {
        motion.gyroUpdateInterval = 0.5
        motion.startGyroUpdates(to: OperationQueue.current!) { (data,error) in
            if let trueData = data {
                self.gyrox.text = "\(trueData.rotationRate.x)"
                self.gyroy.text = "\(trueData.rotationRate.y)"
                self.gyroz.text = "\(trueData.rotationRate.z)"
                if self.gyroListx.count < 16 {
                    self.gyroListx.append(trueData.rotationRate.x)
                    self.gyroListy.append(trueData.rotationRate.y)
                    self.gyroListz.append(trueData.rotationRate.z)
                }
                else if self.gyroListx.count == 16 {
                    self.motion.stopGyroUpdates()
                    self.resultShow.isUserInteractionEnabled = true
                    self.resultShow.isHidden = false
                }
                else {
                    
                }
            }
        }
    }
    
    var accelListx = Array<Double>()
    var accelListy = Array<Double>()
    var accelListz = Array<Double>()
    func MyAccel() {
        motion.accelerometerUpdateInterval = 0.5
        motion.startAccelerometerUpdates(to: OperationQueue.current!) { (data,error) in
            if let myData = data {
                self.accelx.text = "\(myData.acceleration.x)"
                self.accely.text = "\(myData.acceleration.y)"
                self.accelz.text = "\(myData.acceleration.z)"
                if self.accelListx.count < 16 {
                    self.accelListx.append(myData.acceleration.x)
                    self.accelListy.append(myData.acceleration.y)
                    self.accelListz.append(myData.acceleration.z)
                }
                else if self.accelListx.count == 16 {
                    self.motion.stopAccelerometerUpdates()
                }
                else {
                    
                }
            }
        }
    }
    
    @IBAction func resultClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "result", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "result") {
            let resultVC = segue.destination as! ResultViewController
            resultVC.selfie = image
            resultVC.gyroListx = gyroListx
            resultVC.gyroListy = gyroListy
            resultVC.gyroListz = gyroListz
            resultVC.accelListx = accelListx
            resultVC.accelListy = accelListy
            resultVC.accelListz = accelListz
        }
    }

}
