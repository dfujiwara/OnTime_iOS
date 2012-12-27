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

NSString * const kErrorCodeKey = @"errorCode";
NSString * const kStationDictKey = @"stations";
NSString * const kStationIdKey = @"id";
NSString * const kStationNameKey = @"name";
NSString * const kStationAddressKey = @"address";
NSString * const kStationLocationKey = @"location";

NSString * const kStationStopIdKey = @"@stopId";
NSString * const kStationTagKey = @"@tag";
NSString * const kStationTitleKey = @"@title";
NSString * const kStationDirectionKey = @"direction_name";
NSString * const kStationRouteKey = @"route";

NSString * const kStationUrlTemplate = @"http://ontime.jit.su/%@/locate/?lat=%f&long=%f";
NSString * const kNotificationUrl = @"http://ontime.jit.su/%@/notify";

//NSString * const kStationUrlTemplate = @"http://localhost:8000/%@/locate/?lat=%f&long=%f";
//NSString * const kNotificationUrl = @"http://localhost:8000/%@/notify";

NSString * const kPendingNotificationName = @"kPendingNotification";
NSString * const kErrorNotificationName = @"kErrorNotification";

NSString * const kErrorTitleKey = @"kErrorTitleKey";
NSString * const kErrorMessageKey = @"kErrorMessageKey";

const CLLocationDistance kUserLocationDistanceThreshold = 200;

NSString * const kDistanceModeKey = @"mode";
NSString * const kSourceStationKey = @"start";
NSString * const kDestinationStationKey = @"end";
NSString * const kLatitudeKey = @"lat";
NSString * const kLongitudeKey = @"long";

NSString * const kRouteKey = @"route";
NSString * const kTagKey = @"tag";

NSString * const kBufferTimeKey = @"bufferTime";
NSString * const kDurationKey = @"duration";
NSString * const kModeKey = @"mode";
NSString * const kEstimateKey = @"arrivalEstimates";

// Bart specific notification date JSON keys.
NSString * const kStartInfoKey = @"startInfo";
NSString * const kDestinationInfoKey = @"destinationInfo";
NSString * const kArrivalTimeKey = @"arrivalTimeInMinutes";
NSString * const kDestinationKey = @"destination";

// user info dictionary key
NSString * const kStartId = @"startId";
NSString * const kDestinationId = @"destinationId";
NSString * const kSnoozableKey = @"isSnoozable";
NSString * const kTravelModeKey = @"travelMode";
NSString * const kTransitTypeKey = @"transitType";