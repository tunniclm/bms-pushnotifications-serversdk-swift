/*
 *     Copyright 2016 IBM Corp.
 *     Licensed under the Apache License, Version 2.0 (the "License");
 *     you may not use this file except in compliance with the License.
 *     You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 */


import Foundation
import SimpleHttpClient
import SwiftyJSON


/**
    The type of callback to send with PushNotifications requests.
*/
public typealias PushNotificationsCompletionHandler = (_ error: PushNotificationsError?) -> Void


/**
    Used to send Push notifications via a IBM Cloud Push Notifications service.
*/
public struct PushNotifications {
    
    
    /// The IBM Cloud region where the Push Notifications service is hosted.
    public struct Region {
        
        public static let US_SOUTH = "ng.bluemix.net"
        public static let UK = "eu-gb.bluemix.net"
        public static let SYDNEY = "au-syd.bluemix.net"
        public static let FRANKFURT = "eu-de.bluemix.net"
    }
    
    
    internal let headers: [String: String]
    private let httpResource: HttpResource
    
    // used to test in test zone and dev zone
    public static var overrideServerHost = "";
    
    /**
        Initialize PushNotifications by supplying the information needed to connect to the IBM Cloud Push Notifications service.
     
        - parameter pushRegion: The IBM Cloud region where the Push Notifications service is hosted.
        - parameter pushAppGuid: The app GUID for the IBM Cloud application that the Push Notifications service is bound to.
        - parameter pushAppSecret: The appSecret credential required for Push Notifications service authorization.
    */
    public init(pushRegion: String, pushAppGuid: String, pushAppSecret: String) {
        
        headers = ["appSecret": pushAppSecret, "Content-Type": "application/json"]
        
        if(PushNotifications.overrideServerHost.isEmpty){
            let pushHost = "imfpush." + pushRegion
            
            httpResource = HttpResource(schema: "https", host: pushHost, port: "443", path: "/imfpush/v1/apps/\(pushAppGuid)/messages")
            
        }else{
            
            let url = URL(string: PushNotifications.overrideServerHost)
            httpResource = HttpResource(schema: (url?.scheme)!, host: (url?.host)!, path: "/imfpush/v1/apps/\(pushAppGuid)/messages")
        }
    }
    
    
    /**
        Send the Push notification. 
     
        - parameter notificiation: The push notification to send.
        - paramter completionHandler: The callback to be executed when the send request completes.
    */
    public func send(notification: Notification, completionHandler: PushNotificationsCompletionHandler?) {

        guard let requestBody = try? notification.jsonFormat?.rawData() else {
            completionHandler?(PushNotificationsError.InvalidNotification)
            return
        }
        
        HttpClient.post(resource: httpResource, headers: headers, data: requestBody) { (error, status, headers, data) in
            
            completionHandler?(PushNotificationsError.from(httpError: error))
        }
    }
}

