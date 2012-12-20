//
//  OnTimeUIStringFactory.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 12/18/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeUIStringFactory.h"

@implementation OnTimeUIStringFactory

+ (NSString *)bartLabel {
    return NSLocalizedString(@"Bart", @"Bart label");
}

+ (NSString *)okButtonLabel {
    return NSLocalizedString(@"OK", @"OK button label");
}


#pragma mark - table related strings


+ (NSString *)fromHeaderString {
    return NSLocalizedString(@"From",
                             @"'From' label");
}

+ (NSString *)toHeaderString {
    return NSLocalizedString(@"To",
                             @"'To' label");
}

+ (NSString *)prefixStationPrefix:(NSUInteger)section {
    NSString *prefix;
    NSString *prefixDelimiter = @": ";
    switch (section) {
        case 1:
            prefix =
                [[OnTimeUIStringFactory toHeaderString] stringByAppendingString:prefixDelimiter];
            break;
        default:
            prefix =
                [[OnTimeUIStringFactory fromHeaderString] stringByAppendingString:prefixDelimiter];
    }
    return prefix;
}


#pragma mark - notification related strings


+ (NSString *)notificationMessageTemplate {
    return NSLocalizedString(@"Leave at %@ to catch %@ at %@ arriving at %@; "
                             @"%@ there will take %d minute(s).",
                             @"Initial notification string template");
}

+ (NSString *)reminderMessageTemplate {
    return NSLocalizedString(@"Leave now to catch %@ at %@ arriving at %@; "
                             @"%@ there will take %d minute(s).",
                             @"Reminder notification string template");
}

+ (NSString *)notificationTitle {
    return NSLocalizedString(@"OnTime!",
                             @"Notification title");
}

+ (NSString *)snoozeLabel {
    return NSLocalizedString(@"Snooze",
                             @"Snooze button label");
}

+ (NSString *)modeString:(NSUInteger)mode {
    NSString *modeString = nil;
    switch (mode) {
        case 0:
            modeString = NSLocalizedString(@"walking",
                                           @"Walking mode");
            break;
        case 1:
            modeString = NSLocalizedString(@"biking",
                                           @"Biking mode");
            break;
        case 2:
            modeString = NSLocalizedString(@"driving",
                                           @"Driving mode");
            break;
        default:
            NSLog(@"Unexpected mode was returned by server: %u", mode);
            modeString = NSLocalizedString(@"going",
                                           @"Unrecognized mode");
    }
    return modeString;
}


#pragma mark - user input error messages


+ (NSString *)noNotificationTitle {
    return NSLocalizedString(@"No notification",
                             @"Message title for no notification information");
}

+ (NSString *)invalidTripTitle {
    return NSLocalizedString(@"Not a valid trip",
                             @"Message title for an invalid trip input");
}

+ (NSString *)missingStationErrorMessage {
    return NSLocalizedString(@"Please select both stations.",
                             @"Error message for missing station selection");
}

+ (NSString *)identificalStationErrorMessage {
    return NSLocalizedString(@"Please pick two different stations.",
                             @"Error message for not selecting different stations");
}


#pragma mark - server error messages


+ (NSString *)nearbyStationErrorTitle {
    return NSLocalizedString(@"Could not get nearby stations",
                             @"Nearby station error title");
}

+ (NSString *)notificationErrorTitle {
    return NSLocalizedString(@"Could not submit notification request",
                             @"Notification error title");
}

+ (NSString *)missingParameterErrorMessage {
    return NSLocalizedString(@"Not all parameters were provided.",
                             @"Error message for missing parameter");
}

+ (NSString *)failedToCreateNotificationErrorMessage {
    return NSLocalizedString(@"Failed to create notification.",
                             @"Error message for failing to create notification");
}

+ (NSString *)noTimeAvailableErrorMessage {
    return NSLocalizedString(@"No time is available currently.",
                             @"Error message for no available time for notification");
}

+ (NSString *)genericErrorMessage {
    return NSLocalizedString(@"An error occurred. Please try again later.",
                             @"Generic error message");
}

@end