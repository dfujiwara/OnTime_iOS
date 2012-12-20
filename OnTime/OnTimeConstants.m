//
//  OnTimeConstants.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 12/19/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeConstants.h"

NSString * const kBartString = @"bart";
NSString * const kMuniString = @"muni";

NSString * const kSuccessKey = @"success";
NSString * const kErrorCodeKey = @"errorCode";
NSString * const kStationDictKey = @"stations";
NSString * const kStationIdKey = @"id";
NSString * const kStationNameKey = @"name";
NSString * const kStationAddressKey = @"address";
NSString * const kStationLocationKey = @"location";

NSString * const kStationUrlTemplate = @"http://ontime.jit.su/%@/locate/?lat=%f&long=%f";
NSString * const kNotificationUrl = @"http://ontime.jit.su/%@/notify";

NSString * const kPendingNotificationName = @"kPendingNotification";
NSString * const kErrorNotificationName = @"kErrorNotification";

NSString * const kErrorTitleKey = @"kErrorTitleKey";
NSString * const kErrorMessageKey = @"kErrorMessageKey";

const CLLocationDistance kUserLocationDistanceThreshold = 200;