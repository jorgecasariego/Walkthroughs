//
//  CoursesTableViewController.swift
//  Developers Academy
//
//  Created by Duc Tran on 11/27/15.
//  Copyright © 2015 Developers Academy. All rights reserved.
//

import UIKit
import SafariServices
import LocalAuthentication

class CoursesTableViewController: UITableViewController
{
    var programs: [Program] = [Program.TotalIOSBlueprint(), Program.SocializeYourApps()]
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make the row height dynamic
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    
        // the first screen of the app
        // if walkthroughs haven't been shown, let's show the walkthroughs
        displayWalkthroughs()
    }
    
    func displayWalkthroughs()
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let displayedWalkrough = userDefaults.boolForKey("DisplayedWalthrough")
        
        if !displayedWalkrough {
            // Instanciamos el ViewController a presentar
            if let pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") {
                
                // Presentamos el ViewController
                self.presentViewController(pageViewController, animated: true, completion: nil)
            }
        }
    
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return programs.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return programs[section].courses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Course Cell", forIndexPath: indexPath) as! CourseTableViewCell
        
        let program = programs[indexPath.section]
        let courses = program.courses
        cell.course = courses[indexPath.row]
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let program = programs[indexPath.section]
        let url = program.url
        
        showWebsite(url)
    }
    
    // MARK: - Show Webpage with SFSafariViewController
    
    func showWebsite(url: String)
    {
        let webVC = SFSafariViewController(URL: NSURL(string: url)!)
        webVC.delegate = self
        
        self.presentViewController(webVC, animated: true, completion: nil)
    }
    
    // MARK: - Target / Action
    
    @IBAction func signupClicked(sender: AnyObject)
    {
        self.tabBarController?.selectedIndex = 2
    }
    
    @IBAction func loginClicked(sender: AnyObject)
    {
        authenticateUsingTouchID()
    }
    
    // MARK: - Touch ID authentication
    
    func authenticateUsingTouchID()
    {
        let authContext = LAContext()
        let authReason = "Please use Touch ID to sign in Developers Academy"
        var authError: NSError?
        
        if authContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &authError) {
            authContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: authReason, reply: { (success, error) -> Void in
                if success {
                    print("successfully authenticated")
                    // this is on a private queue off the main queue (asynchronously), if we want to do UI code, we must get back to the main queue
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tabBarController?.selectedIndex = 2    // go to the programs tab or sign in in your app
                    })
                } else {
                    if let error = error {
                        // again, this is off the main queue. need to back to the main queue to do ui code
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.reportTouchIDError(error)
                            // it's best to show other method to login (enter user name and password)
                        })
                    }
                }
            })
        } else {
            // device doesn't support touch id 
            print(authError?.localizedDescription)
            
            // show other methods to login
        }
    }
    
    func reportTouchIDError(error: NSError)
    {
        switch error.code {
        case LAError.AuthenticationFailed.rawValue:
            print("Authentication failed")
        case LAError.PasscodeNotSet.rawValue:
            print("passcode not set")
        case LAError.SystemCancel.rawValue:
            print("authentication was canceled by the system")
        case LAError.UserCancel.rawValue:
            print("user cancel auth")
        case LAError.TouchIDNotEnrolled.rawValue:
            print("user hasn't enrolled any finger with touch id")
        case LAError.TouchIDNotAvailable.rawValue:
            print("touch id is not available")
        case LAError.UserFallback.rawValue:
            print("user tapped enter password")
        default:
            print(error.localizedDescription)
        }
    }
}

extension CoursesTableViewController : SFSafariViewControllerDelegate
{
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}












