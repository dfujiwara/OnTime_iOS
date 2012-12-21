//
//  MuniViewController.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 12/20/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//
//  A view controller which represents the bart notification user interface.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MuniViewController : UIViewController <MKMapViewDelegate,
UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *userMapView;
@property (weak, nonatomic) IBOutlet UIButton *requestNotificationButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

// Action for when the notification button is pressed.
- (IBAction)requestNotification:(id)sender;

@end
