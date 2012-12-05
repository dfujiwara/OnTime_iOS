//
//  OnTimeAppDelegate.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/23/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeAppDelegate.h"
#import "OnTimeViewController.h"
#import "OnTimeNotification.h"

// Notification name for the local notification for the departure time.
static NSString * const kPendingNotificationName = @"kPendingNotification";

// Dictionary key used to store local notification in the NSNotification's
// user info object.
static NSString * const kLocalNotificationKey = @"localNotificationKey";

@interface OnTimeAppDelegate () {
    OnTimeViewController *onTimeViewController_;
    // TODO: is this safe to keep only one instance of object?
    NSDictionary *receivedNotificationData_;
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
    onTimeViewController_ = [[OnTimeViewController alloc] initWithNibName:@"OnTimeViewController"
                                                                   bundle:nil];

    UINavigationController *navController =
        [[UINavigationController alloc] initWithRootViewController:onTimeViewController_];
    
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

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - private methods


- (void)registerNotifications {
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
}

- (void)displayLocalNotification:(UILocalNotification *)localNotification {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:kNotificationTitle
                                                 message:[localNotification alertBody]
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    if ([localNotification.userInfo[kSnoozableKey] boolValue]) {
        // store the user info of the given notification
        receivedNotificationData_ = localNotification.userInfo;
        [av addButtonWithTitle:kSnoozeLabel];
    }
    [av show];
}


#pragma mark - alert view delegate


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle compare:kSnoozeLabel] == NSOrderedSame) {
        // Let the view controller handle the notification.
        [onTimeViewController_ processPendingNotification:receivedNotificationData_];
        
        // reset the notification info
        receivedNotificationData_ = nil;
    }
}

@end
