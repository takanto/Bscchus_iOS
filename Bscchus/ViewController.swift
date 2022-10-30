//
//  ViewController.swift
//  Bscchus
//
//  Created by 菅剛大 on 2022/09/14.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBAction func home( _ seg: UIStoryboardSegue) {
    }
    
    @IBOutlet weak var upload: UIButton!
    @IBOutlet weak var imageView: UIImageView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        upload.isUserInteractionEnabled = false
        upload.isHidden = true
        // Do any additional setup after loading the view.
    }

    var imagePicker: UIImagePickerController!
    var image: UIImage?
    
    @IBAction func CameraButtonClicked(_ sender: Any) {
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        //imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("image exist")
            self.image = image
            imageView.image = image
            upload.isUserInteractionEnabled = true
            upload.isHidden = false
        }
    }
    
    
    @IBAction func uploadClicked(_ sender: Any) {
        //self.performSegue(withIdentifier: "showPhotoS", sender: sender)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showPhotoS") {
            let newVC = segue.destination as! SecViewController
            newVC.image = image
        }
    }
    
}

