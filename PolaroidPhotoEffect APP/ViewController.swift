//
//  ViewController.swift
//  PolaroidPhotoEffect APP
//
//  Created by Chandu .. on 10/16/24.
//

import UIKit
import Photos

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var grainSlider: UISlider!
    @IBOutlet weak var grainValueLabel: UILabel!
    @IBOutlet weak var scratchSlider: UISlider!
    @IBOutlet weak var scratchValueLabel: UILabel!
    var originalImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        grainSlider.value = 0
        scratchSlider.value = 0
        updateGrainValueLabel()
        updateScratchValueLabel()
    }
    
    @IBAction func selectPhoto(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func applyEffects(_ sender: UIButton) {
        guard let originalImage = self.originalImage else { return }
        
        // Get the intensity values from the sliders
        let grainIntensity = Int(grainSlider.value)
        let scratchIntensity = Int(scratchSlider.value)
        
        // If both sliders are set to 0, revert to the original image
        if grainIntensity == 0 && scratchIntensity == 0 {
            imageView.image = originalImage
        } else {
            // Apply effects only if there is a non-zero value
            imageView.image = applyGrainAndScratches(to: originalImage, grain: grainIntensity, scratches: scratchIntensity)
        }
    }
    @IBAction func grainSliderChanged(_ sender: UISlider) {
        updateGrainValueLabel()
    }
    
    @IBAction func scratchSliderChanged(_ sender: UISlider) {
        updateScratchValueLabel()
    }
    
    private func updateGrainValueLabel() {
        grainValueLabel.text = "Grain Intensity: \(Int(grainSlider.value))"
    }
    
    private func updateScratchValueLabel() {
        scratchValueLabel.text = "Scratch Intensity: \(Int(scratchSlider.value))"
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            originalImage = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func applyGrainAndScratches(to image: UIImage, grain: Int, scratches: Int) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        
        // Draw the original image
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        // Apply grain
        if grain > 0 {
            for _ in 0..<(grain * 100) {
                let x = CGFloat(arc4random_uniform(UInt32(image.size.width)))
                let y = CGFloat(arc4random_uniform(UInt32(image.size.height)))
                let grainSize = CGFloat(arc4random_uniform(5)) // Random grain size
                let grainRect = CGRect(x: x, y: y, width: grainSize, height: grainSize)
                context?.setFillColor(UIColor(white: 1, alpha: 0.5).cgColor)
                context?.fill(grainRect)
            }
        }
        
        // Apply scratches
        if scratches > 0 {
            for _ in 0..<(scratches * 30) {
                let startX = CGFloat(arc4random_uniform(UInt32(image.size.width)))
                let startY = CGFloat(arc4random_uniform(UInt32(image.size.height)))
                 
                // Calculate random scratch length but ensure it remains within the image bounds
                let lengthX = CGFloat(arc4random_uniform(50)) - 25 // Randomize length with some variation
                let lengthY = CGFloat(arc4random_uniform(50)) - 25
                
                let endX = min(max(startX + lengthX, 0), image.size.width) // Ensure endX is within bounds
                let endY = min(max(startY + lengthY, 0), image.size.height) // Ensure endY is within bounds
                
                context?.setStrokeColor(UIColor(white: 0, alpha: 0.5).cgColor)
                context?.setLineWidth(1)
                //context?.setLineWidth(CGFloat(scratches) * 0.5) // Increased thickness based on intensity
                context?.move(to: CGPoint(x: startX, y: startY))
                context?.addLine(to: CGPoint(x: endX, y: endY))
                context?.strokePath()
            }
        }
        
        let processedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return processedImage
    }
}
