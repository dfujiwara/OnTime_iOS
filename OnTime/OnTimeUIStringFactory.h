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

// Header strings used by the drill station choice view controller.
+ (NSString *)fromHeaderString;
+ (NSString *)toHeaderString;

// Prefix added to the station selected.
// e.g. "From: Powell St" or "To: 16th Street"
// The given parameter section determines the prefix.
// The section currently represents source or destination stations.
+ (NSString *)prefixStationPrefix:(NSUInteger)section;


// Error messages
+ (NSString *)noNotificationTitle;

@end