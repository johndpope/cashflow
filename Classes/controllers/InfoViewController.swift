//
// InfoViewController.swift
//

import UIKit

class InfoViewController : UIViewController {
    @IBOutlet var _nameLabel : UILabel!
    @IBOutlet var _versionLabel: UILabel!
    
    @IBOutlet var _purchaseButton: UIButton!
    @IBOutlet var _helpButton: UIButton!
    @IBOutlet var _facebookButton: UIButton!
    @IBOutlet var _sendMailButton: UIButton!
    
    class func instantiate() -> InfoViewController {
        return UIStoryboard(name: "InfoView", bundle:nil).instantiateInitialViewController() as InfoViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Info", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:.Done, target:self, action:"doneAction:")
#if FREE_VERSION
        _nameLabel.text = "CashFlow Free"
#else
        _purchaseButton.hidden = true
#endif
        
        var version: String = AppDelegate.appVersion()
        _versionLabel.text = "Version \(version)"
        
        _setButtonTitle(_purchaseButton, _L("Purchase Standard Version"))
        _setButtonTitle(_helpButton, _L("Show help page"))
        _setButtonTitle(_facebookButton, _L("Open facebook page"))
        _setButtonTitle(_sendMailButton, _L("Send support mail"))
    }
    
    func _setButtonTitle(button: UIButton, title: String) {
        button.setTitle(title: title, forState: .Normal)
        button.setTitle(title: title, forState: .Highlighted)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func doneAction(sender) {
        self.navigationController?.dismissViewControllerAnimated(flag: true, completion: nil)
    }
    
    @IBAction func webButtonTapped() {
        AppDelegate.trackEvent("help", action:"push", label:"help", value:nil)
        var url = NSURL(NSLocalizedString("HelpURL", comment:""))
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func facebookButtonTapped() {
        AppDelegate.trackEvent("help", action:"push", label:"facebook", value:nil)
        var url = NSURL("http://facebook.com/CashFlowApp")
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func purchaseStandardVerion() {
        AppDelegate.trackEvent("help", action:"push", label:"purchase", value:nil)
        var url = NSURL("http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=290776107&mt=8")
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func sendSupportMail() {
        AppDelegate.trackEvent("help", action:"push", label:"sendmail", value:nil)
        
        var m = SupportMail.getInstance()
        if (!m.sendMail(self)) {
            var v = UIAlertView(title: "Error", message: "Can't send mail", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: nil)
            v.show()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        if (isIpad()) {
            return true
        }
        return interfaceOrientation == UIInterfaceOrientation.Portrait
    }
    
}
