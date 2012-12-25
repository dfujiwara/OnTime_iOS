//
//  OnTimeAppDelegate.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/23/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeAppDelegate.h"
#import "OnTimeUIStringFactory.h"
#import "OnTimeTopViewController.h"
#import "BartStationStore.h"
#import "MuniStationStore.h"
#import "OnTimeConstants.h"

// Dictionary key used to store local notification in the NSNotification's
// user info object.
static NSString * const kLocalNotificationKey = @"localNotificationKey";

@interface OnTimeAppDelegate () {
    // A dictionary which contains the received notification data.
    NSMutableDictionary *receivedNotificationData_;

    // Queue that is used to submit notification request to.
    NSOperationQueue *notificationHandlingQueue_;
}

// Displays the given local notification content in the alert view.
- (void)displayLocalNotification:(UILocalNotification *)notification;

// Registers notification handlers.
// (e.g. handling local notification for departure time)
- (void)registerNotifications;

@end

@implementation OnTimeAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self registerNotifications];

    OnTimeTopViewController *topViewController =
        [[OnTimeTopViewController alloc] initWithNibName:nil bundle:nil];

    UINavigationController *navController =
        [[UINavigationController alloc] initWithRootViewController:topViewController];
    
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];

    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        NSLog(@"Launched with local notification: %@", notification);
        [[NSNotificationCenter defaultCenter] postNotificationName:kPendingNotificationName
                                                            object:nil
                                                          userInfo:@{kLocalNotificationKey:notification}];
    }
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (!notification) {
        // It's possible that the notification is nil; in that case
        // do nothing.
        NSLog(@"Received no notification");
        return;
    }
    NSLog(@"Received local notification: %@", notification);
    [[NSNotificationCenter defaultCenter] postNotificationName:kPendingNotificationName
                                                        object:nil
                                                      userInfo:@{kLocalNotificationKey:notification}];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - private methods


- (void)registerNotifications {
    // Register transit notification related notification
    if (!notificationHandlingQueue_) {
        notificationHandlingQueue_ = [[NSOperationQueue alloc] init];
    }

    [[NSNotificationCenter defaultCenter]
     addObserverForName:kPendingNotificationName
     object:nil
     queue:notificationHandlingQueue_
     usingBlock:^(NSNotification *notification) {
         if (!notification.userInfo) {
             NSLog(@"No user info provided with the notification: %@", notification);
             return;
         }
         UILocalNotification *localNotification = notification.userInfo[kLocalNotificationKey];
         if (!localNotification) {
             NSLog(@"No local notification provided with the user info %@", notification.userInfo);
             return;
         }
         [self displayLocalNotification:localNotification];
     }];

    // Register error handling notification
    [[NSNotificationCenter defaultCenter]
     addObserverForName:kErrorNotificationName
     object:nil
     queue:[NSOperationQueue currentQueue]
     usingBlock:^(NSNotification *notification) {
         NSDictionary *userInfo = notification.userInfo;
         UIAlertView *errorAlert = [[UIAlertView alloc]
                                    initWithTitle:userInfo[kErrorTitleKey]
                                    message:userInfo[kErrorMessageKey]
                                    delegate:nil
                                    cancelButtonTitle:[OnTimeUIStringFactory okButtonLabel]
                                    otherButtonTitles:nil];
         [errorAlert show];
     }];
}

- (void)displayLocalNotification:(UILocalNotification *)localNotification {
    // Make sure that UI related operations are done on the main queue.
    // Note that it's run asychronously to avoid any dead lock on the main
    // queue since the notification is dispatched on the main queue.
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:[OnTimeUIStringFactory notificationTitle]
                                                     message:[localNotification alertBody]
                                                    delegate:self
                                           cancelButtonTitle:[OnTimeUIStringFactory okButtonLabel]
                                           otherButtonTitles:nil];

        if ([localNotification.userInfo[kSnoozableKey] boolValue]) {
            if (!receivedNotificationData_) {
                receivedNotificationData_ = [NSMutableDictionary dictionary];
            }

            // store the user info of the given notification
            static NSUInteger tagId = 0;
            av.tag = tagId++;

            receivedNotificationData_[@(av.tag)] = localNotification.userInfo;
            [av addButtonWithTitle:[OnTimeUIStringFactory snoozeLabel]];
        }
        [av show];
    });
}


#pragma mark - alert view delegate


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle compare:[OnTimeUIStringFactory snoozeLabel]] == NSOrderedSame) {
        NSDictionary *notificationData = receivedNotificationData_[@(alertView.tag)];

        OnTimeAbstractStationStore *stationStore = nil;
        if ([notificationData[kTransitTypeKey] integerValue] == OnTimeTransitTypeBart) {
            stationStore = [BartStationStore sharedStore];
        } else if ([notificationData[kTransitTypeKey] integerValue] == OnTimeTransitTypeMuni) {
            stationStore = [MuniStationStore sharedStore];
        }

        // Let the station store handle the notification.
        [stationStore processPendingNotification:notificationData];
        
        // Remove the notification info that was just processed.
        [receivedNotificationData_ removeObjectForKey:@(alertView.tag)];
    }
}

@end
