//
//  ListPresentationController.swift
//  MaCommercial
//
//  Created by iem on 05/06/2015.
//  Copyright (c) 2015 Sarah LAFORETS. All rights reserved.
//

import UIKit
import AVFoundation

class ListPresentationController: UICollectionViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let reuseIdentifier = "ListPresentationCell"
    
    var presentations : [Presentation]?
    var loader : Loader?
    
    var maxFinish = 0;
    var nbFinish = 0

    override func viewDidLoad() {
        // Init Loader
        loader = Loader(view: self.view)
        super.viewDidLoad()
        
        self.title = NSLocalizedString("presentations_list_title", comment:"")
        
        self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
        
        presentations = [Presentation]()
        var presentation = Presentation()
        loader?.showLoader()
        DataManager.sharedInstance.get(presentation, parameters: nil) { (json) -> () in
            if let data = json {
                for (key, value) in data {
                    var tmpPresentation = Presentation()
                    tmpPresentation.fromJSON(value)
                    presentations!.append(tmpPresentation)
                    loader?.hideLoader()
                }
            }           
            
            self.collectionView?.reloadData()
        }
    }
    
    func getThumbnailPdf(cell: ListPresentationCollectionViewCell, url:NSURL, pageNumber:Int) {
        var imageData = NSData(contentsOfURL: NSBundle.mainBundle()
            .URLForResource("loading", withExtension: "gif")!)
        cell.imagePresentation.image = UIImage.animatedImageWithData(imageData!)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            var pdf:CGPDFDocumentRef = CGPDFDocumentCreateWithURL(url as CFURLRef);
            var page = CGPDFDocumentGetPage(pdf, pageNumber)
            
            var pageRect:CGRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
            var pdfScale:CGFloat = cell.frame.width/pageRect.size.width;
            pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
            pageRect.origin = CGPointZero;
            
            UIGraphicsBeginImageContext(pageRect.size);
            
            var context:CGContextRef = UIGraphicsGetCurrentContext();
            
            CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
            CGContextFillRect(context,pageRect);
            CGContextSaveGState(context);
            
            CGContextTranslateCTM(context, 0.0, pageRect.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, pageRect, 0, true));
            
            CGContextDrawPDFPage(context, page);
            CGContextRestoreGState(context);
            
            var thm:UIImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            cell.imagePresentation.image = thm
        })
    }
    
    func getThumbnailImage(cell: ListPresentationCollectionViewCell, url: NSURL) {
        var imageData = NSData(contentsOfURL: NSBundle.mainBundle()
            .URLForResource("loading", withExtension: "gif")!)
        cell.imagePresentation.image = UIImage.animatedImageWithData(imageData!)
        
        
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                let data = NSData(contentsOfURL: url)
                if data != nil {
                
                    let imageOriginal = UIImage(data: data!)
                    if let image = imageOriginal {
                        UIGraphicsBeginImageContext(cell.frame.size)
                        imageOriginal?.drawInRect(CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
                        var returnImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext();
                        cell.imagePresentation.image = returnImage
                    }
                }
            })
        
    }


    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presentations!.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ListPresentationCollectionViewCell
        let presentation = presentations![indexPath.row]
        
        let nsurl = NSURL(string: presentation.document)
        if let downloadUrl = nsurl {
            switch downloadUrl.pathExtension! {
                case "pdf":
                    getThumbnailPdf(cell, url: downloadUrl, pageNumber: 1)
                    maxFinish++
                    break;
                case "png",
                    "jpg",
                    "gif",
                    "bmp",
                    "tiff":
                    getThumbnailImage(cell, url: downloadUrl)
                    maxFinish++
                    break;
                case "ppt",
                    "pptx":
                    cell.imagePresentation.image = UIImage(named: "Powerpoint-icon")
                    break;
                case "doc",
                    "docx":
                    cell.imagePresentation.image = UIImage(named: "Word-icon")
                    break;
                case "xls",
                    "xlsx":
                    cell.imagePresentation.image = UIImage(named: "Excel-icon")
                    break;
                default:
                    break;
            }
        }
        
        cell.titleLabel.text = presentation.title
        
        return cell
    }
    
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 200, height: 200)
    }
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var selected = self.collectionView?.indexPathsForSelectedItems()[0].row
        let presentation = presentations![selected!]

        (segue.destinationViewController as! PresentationPDFViewController).path = NSURL(string: presentation.document)
        (segue.destinationViewController as! PresentationPDFViewController).title = presentation.title
    }

}
