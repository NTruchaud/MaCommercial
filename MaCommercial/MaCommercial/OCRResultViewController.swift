//
//  OCRResultViewController.swift
//  MaCommercial
//
//  Created by iem on 10/06/2015.
//

import UIKit

extension String {
    var isBlank: Bool {
        get {
            let trimmed = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            return trimmed.isEmpty
        }
    }
}

class OCRResultViewController: UIViewController, UIViewDragDropDelegate, UITextFieldDelegate {

    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var labelPropos: UILabel!
    @IBOutlet weak var labelInformation: UILabel!
    @IBOutlet weak var separator: UIView!
    
    var keys: [String]?
    var image: UIImage?
    var completionHandler: (([String: String]) -> ())?
    
    var texts = [UITextField]()
    var depots = [UIView]()
    var relations : [UITextField?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageGet = image {
            executeOCR(image: imageGet)
            self.showImage.image = imageGet
        }
        
        self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
    }
    
    func setUpDragDrop(elements: [String]) {
        let widthResultString : CGFloat = 150
        let heightResultString : CGFloat = 30
        let widthKey : CGFloat = 400
        
        //Get informations
        var posX = self.separator.frame.origin.x - widthResultString - 10
        var posY = self.labelPropos.frame.origin.y + self.labelPropos.frame.height + 10
        
        //Set Result string
        for var i = 0; i < elements.count; i++ {
            if !elements[i].isEmpty && !elements[i].isBlank {
                let text = UITextField(frame: CGRect(x: posX, y: posY, width: widthResultString, height: heightResultString))
                text.text = elements[i]
                text.delegate = self
                self.view.addSubview(text)
            
                posY += heightResultString
                texts.append(text)
            }
        }
        
        //Reset
        posY = self.labelInformation.frame.origin.y + self.labelInformation.frame.height + 10
        posX = self.labelInformation.frame.origin.x  + (widthKey / 2) + 10
        
        //Set Keys
        if keys != nil {
            for key in keys! {
                var content = UIView(frame: CGRect(x: posX, y: posY, width: widthKey, height: heightResultString))
                content.layer.borderWidth = 1
                content.layer.borderColor = UIColor.blackColor().CGColor
                
                var label = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: widthKey - 300, height: heightResultString))
                label.text = key
                
                var depot = UIView(frame: CGRect(x: CGFloat(label.frame.width + 10), y: 0, width: widthKey - 100, height: heightResultString))
                content.layer.borderWidth = 1
                content.layer.borderColor = UIColor.blackColor().CGColor
                
                content.addSubview(label)
                content.addSubview(depot)
                self.view.addSubview(content)
                
                posY += heightResultString
                depots.append(content)
            }
        }
        
        relations = [UITextField?](count: keys!.count, repeatedValue: nil)
        
        for textField in texts {
            textField.makeDraggableWithDropViews(depots, delegate: self)
        }
    }
    
    func executeOCR(#image: UIImage) {
        let tesseract = G8Tesseract(language: "eng+fra", engineMode: .TesseractCubeCombined)
        tesseract.pageSegmentationMode = .Auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        
        var result = tesseract.recognizedText.componentsSeparatedByString("\n")
        setUpDragDrop(result)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        if completionHandler != nil {
            var returnValue: [String:String] = [:]
            for var i = 0; i < keys!.count; i++ {
                if let relation = relations![i] {
                    returnValue[keys![i]] = relation.text
                }
            }
            completionHandler!(returnValue)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - UIViewDragDropDelegate
    func view(view: UIView!, wasDroppedOnDropView drop: UIView!) {
        var index = find(texts, view as! UITextField)
        if index != nil {
            relations![index!] = view as? UITextField
            view.makeDraggableWithDropViews([], delegate: nil)
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }

}
