//
//  OnTimeUIStringFactory.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 12/18/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//
//  This class holds OnTime related UI strings.

#import <Foundation/Foundation.h>

@interface OnTimeUIStringFactory : NSObject

// Navbar related strings
+ (NSString *)OnTimeLabel;
+ (NSString *)bartLabel;
+ (NSString *)muniLabel;

// Generic button labels.
+ (NSString *)okButtonLabel;

// Notification related labels.
+ (NSString *)notificationMessageTemplate;
+ (NSString *)reminderMessageTemplate;
+ (NSString *)notificationTitle;
+ (NSString *)snoozeLabel;

// Trasportation labels used to identify how to get to the starting location.
// The default label is "going"
+ (NSString *)modeString:(NSUInteger)mode;

// Prefix strings added to the station choice.
+ (NSString *)fromHeaderString;
+ (NSString *)toHeaderString;
+ (NSString *)stationHeaderString;

// Prefix added to the station selected.
// e.g. "From: Powell St" or "To: 16th Street"
// The given parameter section determines the prefix.
// The section currently represents source or destination stations.
+ (NSString *)prefixStationPrefix:(NSUInteger)section;

// User input error messages
+ (NSString *)invalidTripTitle;
+ (NSString *)missingStationErrorMessage;
+ (NSString *)identificalStationErrorMessage;

// server error messages
+ (NSString *)nearbyStationErrorTitle;
+ (NSString *)notificationErrorTitle;

+ (NSString *)noNotificationTitle;
+ (NSString *)missingParameterErrorMessage;
+ (NSString *)failedToCreateNotificationErrorMessage;
+ (NSString *)noTimeAvailableErrorMessage;

+ (NSString *)genericErrorMessage;

@end