//
//  OnTimeViewController.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/23/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface BartViewController : UIViewController <MKMapViewDelegate,
    UITableViewDataSource, UITableViewDelegate> {
    __weak IBOutlet MKMapView *userMapView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet UIButton *requestNotificationButton;
    __weak IBOutlet UISegmentedControl *methodToGetToStation;
    __weak IBOutlet UITableView *tableView;
    __weak IBOutlet UILabel *distanceLabel;
}

// Action for when the notification button is pressed.
- (IBAction)requestNotification:(id)sender;

// Processes a pending notification
- (void)processPendingNotification:(NSDictionary *)notificationData;

@end
