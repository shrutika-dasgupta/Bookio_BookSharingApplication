//
//  BookioApi.h
//  Bookio
//
//  Created by Bookio Team on 4/24/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

// The BookioApi which does the NSURLConnection on behalf of the app
@interface BookioApi : NSObject<NSURLConnectionDelegate>
{
    // will store the response retured by the api call
    NSMutableData *responseData;
    // will maintain the NSURLConnection
    NSURLConnection *conn;
    // alertview
    UIAlertView *loading;
}

// This method returns the json response given the request URL
// The result is stored in the completion block
-(void)urlOfQuery:url queryCompletion:(void (^)(NSMutableDictionary *results))completionHandler;

// This method returns a NSMutableDictionry which is the result of the synchronous request url.
-(NSMutableDictionary *)asyncurlOfQuery:url;

@end
