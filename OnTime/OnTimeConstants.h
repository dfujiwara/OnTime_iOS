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

// Various JSON keys used to retrieve data from server response
extern NSString * const kSuccessKey;
extern NSString * const kErrorCodeKey;
extern NSString * const kStationDictKey;
extern NSString * const kStationIdKey;
extern NSString * const kStationNameKey;
extern NSString * const kStationAddressKey;
extern NSString * const kStationLocationKey;

// URL templates to get the nearby stations and request for notifications.
extern NSString * const kStationUrlTemplate;
extern NSString * const kNotificationUrl;

// Distance threshold for the updated user location relative to
// the previously recorded user location. If this threshold is exceeded, the
// updated user location is processed. This is expressed in meters.
extern const CLLocationDistance kUserLocationDistanceThreshold;