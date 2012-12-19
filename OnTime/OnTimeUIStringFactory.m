//
//  OnTimeUIStringFactory.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 12/18/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeUIStringFactory.h"

@implementation OnTimeUIStringFactory

+ (NSString *)okButtonLabel {
    return NSLocalizedString(@"OK", @"OK button label");
}

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

+ (NSString *)noNotificationTitle {
    return NSLocalizedString(@"No notification",
                             @"Error message for no notification information");
}

@end