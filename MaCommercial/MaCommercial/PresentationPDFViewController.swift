//
//  PresentationPDFViewController.swift
//  MaCommercial
//
//  Created by Sarah LAFORETS on 03/06/2015.
//  Copyright (c) 2015 Sarah LAFORETS. All rights reserved.
//

import UIKit

class PresentationPDFViewController: UIViewController, UIWebViewDelegate {

    // Web view qui va contenir le document PDF
    @IBOutlet var wvPDF: UIWebView!
    
    // Objet reçu
    var path: NSURL?
    var loader : Loader?
    
    // MARK: - View Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wvPDF.delegate = self
        loader = Loader(view: self.view)
        
        // Charger le document dans la webView
        chargeDocument(path)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Chargement document
    
    /*
        Permet le chargement du document
    */
    
    func chargeDocument(document: NSURL?) {
        
        // Chargement de l'URL du document
        if let url = document {
        
            // Permet de zoom in & out sur le document
            self.wvPDF.scalesPageToFit = true
        
            // Charger le document dans la webView
            self.wvPDF.loadRequest(NSURLRequest(URL: url))
        }
    }
    
    //MARK: - UIWebViewDelegate
    func webViewDidStartLoad(webView: UIWebView) {
        loader!.showLoader()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loader!.hideLoader()
    }
}
