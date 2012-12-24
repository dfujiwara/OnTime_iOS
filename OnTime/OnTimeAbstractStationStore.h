//
//  OnTimeAbstractStationStore.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 12/19/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//
//  An abstract class for different types of station stores.

#import <Foundation/Foundation.h>
#import "OnTimeManagerProtocol.h"

@interface OnTimeAbstractStationStore : NSObject <OnTimeManagerProtocol>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *nearbyStations;

// Issues the near by station request at the given url
// Note that the completion handler expects the station dictionary data as
// a parameter since the station data is specific to the transit line, and
// the concrete subclass of the station store needs to handle them
// appropriately.
- (void)issueNearbyStationRequest:(NSString *)urlString
                   withCompletion:(void (^)(NSDictionary *stationsData,
                                            NSError *err))block;

// Issues the notification request at the given url with the given request data.
- (void)issueNotificationRequest:(NSString *)urlString
                        withData:(NSDictionary *)requestData
                  withCompletion:(void (^)(NSDictionary *notificationData,
                                           NSError *err))block;

// 
- (NSDateFormatter *)dateFormatter;

//
- (void)displayTransitNotification:(NSString *)notificationMessage;

//
- (void)scheduleTransitReminderNotification:(NSString *)notificationMessage
                                     atTime:(NSDate *)time
                                   withInfo:(NSDictionary *)userInfo;

@end
