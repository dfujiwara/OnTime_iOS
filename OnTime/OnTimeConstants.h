//
//  OnTimeConstants.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 12/19/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//
//  This class holds non user facing constants used through out the app.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

extern NSString * const kBartString;
extern NSString * const kMuniString;

// Various JSON keys used to retrieve station data from server response
extern NSString * const kErrorCodeKey;
extern NSString * const kStationDictKey;
extern NSString * const kStationIdKey;
extern NSString * const kStationNameKey;
extern NSString * const kStationAddressKey;
extern NSString * const kStationLocationKey;

// Muni specific JSON keys
extern NSString * const kStationStopIdKey;
extern NSString * const kStationTagKey;
extern NSString * const kStationTitleKey;
extern NSString * const kStationDirectionKey;
extern NSString * const kStationRouteKey;

// URL templates to get the nearby stations and request for notifications.
extern NSString * const kStationUrlTemplate;
extern NSString * const kNotificationUrl;

// Notification name for the local notification for the departure time.
extern NSString * const kPendingNotificationName;

// Notification name for user visible error.
extern NSString * const kErrorNotificationName;

// Dictionary keys used in the user info of an error notification.
extern NSString * const kErrorTitleKey;
extern NSString * const kErrorMessageKey;

// Distance threshold for the updated user location relative to
// the previously recorded user location. If this threshold is exceeded, the
// updated user location is processed. This is expressed in meters.
extern const CLLocationDistance kUserLocationDistanceThreshold;

// NSError error code
typedef enum {
    OnTimeErrorCodeGeneral = 0,
    OnTimeErrorMissingParameter = 1,
    OnTimeErrorNotificationCreationFailure = 2,
    OnTimeErrorNoAvailableTime = 3
} OnTimeErrorCode;

// Transit types
typedef enum {
    OnTimeTransitTypeBart = 0,
    OnTimeTransitTypeMuni = 1
} OnTimeTransitType;

// Keys used for notification POST request
extern NSString * const kDistanceModeKey;
extern NSString * const kSourceStationKey;
extern NSString * const kDestinationStationKey;
extern NSString * const kLatitudeKey;
extern NSString * const kLongitudeKey;

extern NSString * const kRouteKey;
extern NSString * const kTagKey;

// Various JSON keys used to retrieve notification data from server response
// notification data dictionary keys.
extern NSString * const kBufferTimeKey;
extern NSString * const kDurationKey;
extern NSString * const kModeKey;
extern NSString * const kEstimateKey;

// Bart specific notification data JSON keys.
extern NSString * const kStartInfoKey;
extern NSString * const kDestinationInfoKey;
extern NSString * const kArrivalTimeKey;
extern NSString * const kDestinationKey;

// Notification reminder user info keys
extern NSString * const kStartId;
extern NSString * const kDestinationId;
extern NSString * const kSnoozableKey;
extern NSString * const kTravelModeKey;
extern NSString * const kTransitTypeKey;


