//
//  EGTracker.swift
//  Pods
//
//  Created by Miguel Chaves on 01/04/16.
//
//

import UIKit

// Configurations about the server
struct EGConfigurations {
    static let endPoint: String = "https://egoimmerce.e-goi.com/collect?"
    static let getMethod: String = "GET"
}

public class EGTracker: NSObject {
    
    // MARK:
    // MARK: - Variables
    
    /**
     *   Private
     */
    
    private var timer: NSTimer! // The timer to dispatch events if they are stored in the database
    private var queue: dispatch_queue_t! // The private queue
    private let dateFormatter = NSDateFormatter() // Date Formatter for setting hour, minute, second
    private let calendar = NSCalendar.currentCalendar() // The current calendar
    
    /**
     *
     *   Public - Configurable variables
     *
     *   Check this link for more information:
     *   https://developer.piwik.org/api-reference/tracking-api
     *
     */
    
    // Set if the library shows logs. Default is true
    public var logActive: Bool = true
    
    // User email, usually setted after login
    public var subscriber = ""
    
    // The campaing hash if you have it
    public var campaign = ""
    
    // The client ID in use
    public var clientID: Int = 1
    
    // The ID of the website we're tracking a visit/action for
    public var idsite: Int = 1
    
    // The list ID used
    public var listID: Int = 1
    
    // Required for tracking, must be set to one, eg, &rec=1.
    public var rec: Int = 1 // Present here but disabled in request
    
    //
    public var r: Int = 0
    public var _idn: Int = 0
    public var _ref: String = "0"
    
    // The current hour (local time)
    public var h: Int = 0
    
    // The current minute (local time)
    public var m: Int = 0
    
    // The current second (local time)
    public var s: Int = 0
    
    // The app name formatted has a website
    // Suggestion: http://myapp.ios
    public var url: String = "http://myapp.ios"
    
    // The unique visitor ID, must be a 16 characters hexadecimal string. This is generate by the library
    public var _id: String = "hash"
    
    // The UNIX timestamp of this visitor's first visit. This could be set to the date where the user first started using your software/app, or when he/she created an account. This parameter is used to populate the Goals > Days to Conversion report.
    public var timestamp: String = "0"
    public var _idts: Int = 0
    
    // The current count of visits for this visitor. To set this value correctly, it would be required to store the value for each visitor in your application (using sessions or persisting in a database). Then you would manually increment the counts by one on each new visit or "session", depending on how you choose to define a visit. This value is used to populate the report Visitors > Engagement > Visits by visit number.
    public var _idvc: Int = 0
    
    // Link reference - not used here
    public var _refts: Int = 0
    
    //  If set to 0 (send_image=0) Piwik will respond with a HTTP 204 response code instead of a GIF image. This improves performance and can fix errors if images are not allowed to be obtained directly (eg Chrome Apps). Available since Piwik 2.10.0
    public var send_image: Int = 0
    
    // Plugins used by the visitor can be specified by setting the following parameters to 1:
    public var fla: Int = 0 // Flash
    public var java: Int = 0 // Java
    public var qt: Int = 0 // QuickTime
    public var dir: Int = 0 // Director
    public var realp: Int = 0 // RealPlayer
    public var wma: Int = 0 // Windows Media
    public var pdf: Int = 0 // PDF
    public var gears: Int = 0 // Gears
    public var ag: Int = 0 // Silverlight
    public var cookie: Int = 0 // When set to 1, the visitor's client is known to support cookies
    
    // The resolution of the device the visitor is using, eg 1280x1024. The library fill's this automatically
    public var res: String = "1280x1024"
    
    // The amount of time it took the server to generate this action, in milliseconds. This value is used to process the Page speed report
    public var gt_ms: Int = 0
    
    // MARK: -
    // MARK: - Singleton
    
    public class var sharedInstance: EGTracker {
        struct Singleton {
            static let instance = EGTracker()
        }
        
        return Singleton.instance
    }
    
    // MARK: -
    // MARK: - Init engine
    
    public func initEngine() {
        
        log("Initing engine...")
        
        // Queue to handle the sending of the stored events
        self.queue = dispatch_queue_create("com.egoi.tinygoi.queue", DISPATCH_QUEUE_SERIAL)
        
        // Init the timer to check regulary if there is events to send
        self.timer = NSTimer.scheduledTimerWithTimeInterval(60.0,
                                                            target: self,
                                                            selector: #selector(EGTracker.checkStoredEvents),
                                                            userInfo: nil,
                                                            repeats: true)
        
        // Init variables
        self.timestamp = String(format: "%.0f", NSDate().timeIntervalSince1970 * 1000)
        self._id = generateRandomHashString()
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        self.res = String(format: "%.0fx%.0f", screenSize.width, screenSize.height)
        self.dateFormatter.dateFormat = "dd-MM-yyyy hh:MM:ss"
        
        log("Engine inited!")
        
        checkStoredEvents()
    }
    
    // MARK: -
    // MARK: - Check for stored events
    
    func checkStoredEvents() {
        
        log("Searching for events in the database...")
        
        // get the stored events and start sending it to the
        let eventsArray = EGTrackerDBManager.sharedInstance.allEntriesOfType(EGTrackerRequest.entityName()) as! [EGTrackerRequest]
        
        for element in eventsArray {
            // if the action was sent, delete the event
            if (element.sent == true) {
                EGTrackerDBManager.sharedInstance.deleteObject(element)
            } else {
                sendStoredRequests(element)
            }
        }
        
        EGTrackerDBManager.sharedInstance.saveContext()
    }
    
    // MARK: -
    // MARK: - Tracking Actions
    
    public func trackEvent(event: String) {
        log("Tracking event: \(event)")
        
        sendOrSaveRequest(configureRequestWithAction(event))
    }
    
    // MARK: -
    // MARK: - Send requests
    
    func sendOrSaveRequest(urlString: String) {
        // Check for connection
        if (egTrackerCheckConnection()) {
            
            // Send the request to the E-goi platform
            let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
            request.HTTPMethod = EGConfigurations.getMethod
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
                // Check if data has values
                if (data != nil) {
                    self.log ("Event sent to the server!")
                } else {
                    let event = EGTrackerDBManager.sharedInstance.managedObjectOfType(EGTrackerRequest.entityName()) as! EGTrackerRequest
                    event.url = urlString
                    event.date = NSDate()
                    event.sent = false
                    EGTrackerDBManager.sharedInstance.saveContext()
                    
                    self.log("Event saved!")
                }
            }
            
            task.resume()
            
        } else {
            // if there is no connection this will sent later
            let event = EGTrackerDBManager.sharedInstance.managedObjectOfType(EGTrackerRequest.entityName()) as! EGTrackerRequest
            event.url = urlString
            event.date = NSDate()
            event.sent = false
            EGTrackerDBManager.sharedInstance.saveContext()
            
            log("Event saved!")
        }
    }
    
    func sendStoredRequests(event: EGTrackerRequest?) {
        
        if (event != nil) {
            // Try sending the request to the server
            dispatch_async(self.queue) { () -> Void in
                let request = NSMutableURLRequest(URL: NSURL(string: event!.url!)!)
                request.HTTPMethod = EGConfigurations.getMethod
                
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
                    // Check if data has values
                    if (data != nil) {
                        event?.sent = true
                        
                        self.log("Event send!")
                    }
                }
                
                task.resume()
            }
        }
    }
    
    // MARK:
    // MARK: - Configure the request with the action
    
    func configureRequestWithAction(action: String) -> String {
        return String(format: "%@action_name=%@%@", EGConfigurations.endPoint, action, getCompletionRequest())
    }
    
    // MARK: -
    // MARK: - Check for Internet Connection
    
    func egTrackerCheckConnection() -> Bool {
        
        do {
            let reachability = try Reachability.reachabilityForInternetConnection()
            return reachability.isReachable()
        } catch {
            return false
        }
    }
    
    // MARK:
    // MARK: - Auxiliar functions
    
    func getCompletionRequest() -> String {
        
        // Update the time to set in the request
        setTime()
        
        var string = "&clientid=\(self.clientID)"
        string = string + "&listid=\(self.listID)"
        string = string + "&subscriber=\(self.subscriber)"
        string = string + "&campaign=\(self.campaign)"
        string = string + "&rec=1"
        string = string + "&r=\(self.r)"
        string = string + "&h=\(self.h)"
        string = string + "&m=\(self.m)"
        string = string + "&s=\(self.s)"
        string = string + "&url=\(self.url)"
        string = string + "&_id=\(self._id)"
        string = string + "&_idts=\(self._idts)"
        string = string + "&_idvc=\(self._idvc)"
        string = string + "&_idn=\(self._idn)"
        string = string + "&_refts=\(self._refts)"
        string = string + "&_viewts=\(self.timestamp)"
        string = string + "&_ref=\(self._ref)"
        string = string + "&send_image=\(self.send_image)"
        string = string + "&pdf=\(self.pdf)"
        string = string + "&qt=\(self.qt)"
        string = string + "&realp=\(self.realp)"
        string = string + "&wma=\(self.wma)"
        string = string + "&dir=\(self.dir)"
        string = string + "&fla=\(self.fla)"
        string = string + "&java=\(self.java)"
        string = string + "&gears=\(self.gears)"
        string = string + "&ag=\(self.ag)"
        string = string + "&cookie=\(self.cookie)"
        string = string + "&res=\(self.res)"
        string = string + "&gt_ms=\(self.gt_ms)"
        string = string + "&idsite=\(self.idsite)"
        
        return string
    }
    
    func setTime() {
        let comp = self.calendar.components([.Hour, .Minute, .Second], fromDate: NSDate())
        self.h = Int(comp.hour)
        self.m = Int(comp.minute)
        self.s = Int(comp.second)
    }
    
    func generateRandomHashString() -> String {
        
        let sourceArray: NSArray = ["1", "a", "2", "b", "3", "8", "c", "4", "d", "5", "e", "6", "f", "7", "9"]
        var returnString: String = ""
        
        for _ in 0...15 {
            let random = sourceArray[Int(arc4random_uniform(UInt32(sourceArray.count - 1)))] as! String
            returnString = "\(returnString)\(random)"
        }
        
        log("Generated new hash: \(returnString)")
        
        return returnString
    }
    
    func log(message: String) {
        if (self.logActive == true) {
            print("EGTracker: \(message)")
        }
    }
}