//
//  OnTimeManagerProtocol.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/29/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//
//  A protocol which defines methods that deals with core functionality of
//  station stores.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class Station;

@protocol OnTimeManagerProtocol <NSObject>

@property (nonatomic, strong) NSArray *nearbyStations;

// Given the current location, retrieves nearby stations.
// Provide the completion block to perform action after the stations are
// retrieved.
- (void)getNearbyStations:(CLLocation *)currentLocation
           withCompletion:(void (^)(NSError *err))block;

// Submits the notification request to the server.
// Provide the completion block to perform action after the notification is
// submitted, received a response, and scheduled to notify the user.
- (void)requestNotification:(NSDictionary *)requestData
             withCompletion:(void (^)(NSError *err))block;

// Retrieves specified number of nearby stations.
// Note that if numStations is greater than the number of possible nearby
// stations, it will return as many nearby station there are.
- (NSArray *)nearbyStations:(NSInteger)numStations;

// Processes a pending notification
- (void)processPendingNotification:(NSDictionary *)notificationData;

@end
