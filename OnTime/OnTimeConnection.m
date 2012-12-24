//
//  OnTimeConnection.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/28/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeConnection.h"

// This is necessary to keep the OnTimeConnection around after the caller's
// frame goes out of scope.
static NSMutableArray *sharedConnectionList = nil;

@interface OnTimeConnection () {
    NSURLConnection *internalConnection_; // why is this necessary??
    NSURLResponse *response_;
    NSMutableData *container_;
}

@end

@implementation OnTimeConnection

@synthesize request;
@synthesize completionBlock;

- (id)initWithRequest:(NSURLRequest *)req {
    self = [super init];
    if (self) {
        if (!req){
            [NSException raise:@"Request not provided"
                        format:@"Request needs to be provided for the connection"];
            return nil;
        }
        self.request = req;
    }
    return self;
}

- (id)init {
    [NSException raise:@"Default init failed"
                format:@"Reason: init is not supported by %@", [self class]];
    return nil;
}

- (void)start {
    container_ = [[NSMutableData alloc] init];
    internalConnection_ = [[NSURLConnection alloc] initWithRequest:self.request
                                                         delegate:self
                                                 startImmediately:YES];
    if (!sharedConnectionList){
        sharedConnectionList = [NSMutableArray array];
    }
    [sharedConnectionList addObject:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Store the url response for the later use.
    response_ = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [container_ appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // By default we expect JSON response
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:container_
                                                             options:0
                                                               error:nil];
    NSInteger statusCode = ((NSHTTPURLResponse *)response_).statusCode;
    NSError *error = nil;
    if (statusCode != 200) {
        static NSString *errorDomain = @"http error";
        error = [NSError errorWithDomain:errorDomain
                                    code:statusCode
                                userInfo:nil];
    }
    if (self.completionBlock){
        self.completionBlock(jsonData, error);
    }
    [sharedConnectionList removeObject:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.completionBlock){
        self.completionBlock(nil, error);
    }
    [sharedConnectionList removeObject:self];
}

@end