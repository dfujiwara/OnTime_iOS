//
//  MuniViewController.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 12/20/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "MuniViewController.h"
#import "OnTimeStationMapAnnotation.h"
#import "OnTimeUIStringFactory.h"
#import "MuniStationStore.h"
#import "StationChoiceViewController.h"
#import "OnTimeConstants.h"

@interface MuniViewController () {
    OnTimeStationMapAnnotation *sourceStationAnnotation_;
    CLLocation *lastRecordedLocation_;
    UIView *distanceLabelBackgroundView_;
    BOOL updateTableRow_;
}

// Configures the UI given the current state of the view controlloer.
- (void)configureUI;

// Calculates the distance between the given two locations and
// updates the distance label on the map to indicate how far the user is
// from the selected starting station.
- (void)updateDistanceToStationFrom:(CLLocation *)fromLocation
                                 to:(CLLocation *)stationLocation;

@end

@implementation MuniViewController

@synthesize userMapView = userMapView_;
@synthesize tableView = tableView_;
@synthesize distanceLabel = distanceLabel_;
@synthesize requestNotificationButton = requestNotificationButton_;
@synthesize methodToGetToStation = methodToGetToStation_;

# pragma mark - inits


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Set navigation bar title.
        self.navigationItem.title = [OnTimeUIStringFactory muniLabel];

        sourceStationAnnotation_ = [[OnTimeStationMapAnnotation alloc] init];
        updateTableRow_ = NO;
    }
    return self;
}


#pragma mark - view cycle methods


- (void)viewDidLoad {
    [super viewDidLoad];

    [userMapView_ setShowsUserLocation:YES];

    distanceLabelBackgroundView_ = [[UIView alloc] initWithFrame:distanceLabel_.frame];
    distanceLabelBackgroundView_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleTopMargin;
    distanceLabelBackgroundView_.backgroundColor = [UIColor colorWithWhite:0.58
                                                                     alpha:.75];
    [userMapView_ addSubview:distanceLabelBackgroundView_];

    // UI needs to be configured approriately when the view is loaded (e.g.
    // enable or disable based on the previous state).
    [self configureUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Update the table row if needed.
    if (updateTableRow_) {

        // Animate the map region change since when the table rows update is
        // required, then it also means that the map annotation location
        // has changed.
        MKMapPoint currentPoint = MKMapPointForCoordinate(userMapView_.userLocation.coordinate);
        MKMapPoint stationPoint = MKMapPointForCoordinate(sourceStationAnnotation_.coordinate);

        // Generate map rect from those two map points.
        MKMapRect mapRect = MKMapRectMake (fmin(currentPoint.x, stationPoint.x),
                                           fmin(currentPoint.y, stationPoint.y),
                                           fabs(currentPoint.x - stationPoint.x),
                                           fabs(currentPoint.y - stationPoint.y));

        // Determine the mid point in the map rect.
        MKMapPoint middlePoint;
        middlePoint.x = MKMapRectGetMidX(mapRect);
        middlePoint.y = MKMapRectGetMidY(mapRect);
        CLLocationCoordinate2D centerCoordinate = MKCoordinateForMapPoint(middlePoint);


        // Calculate the distance between those two points.
        CLLocation *stationLocation =
        [[CLLocation alloc] initWithCoordinate:sourceStationAnnotation_.coordinate
                                      altitude:0
                            horizontalAccuracy:0
                              verticalAccuracy:-1
                                     timestamp:[NSDate date]];
        CLLocationDistance distance = [userMapView_.userLocation.location
                                       distanceFromLocation:stationLocation];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerCoordinate,
                                                                       distance,
                                                                       distance);
        [userMapView_ setRegion:region animated:YES];

        // Also update the distance label to the source station.
        [self updateDistanceToStationFrom:userMapView_.userLocation.location
                                       to:stationLocation];


        // Animate the row update
        NSIndexPath *sourceStationIndexPath = [NSIndexPath indexPathForRow:0
                                                                 inSection:0];
        [tableView_ reloadRowsAtIndexPaths:@[sourceStationIndexPath]
                         withRowAnimation:UITableViewRowAnimationRight];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - map view delegate methods


- (void)mapView:(MKMapView *)view didUpdateUserLocation:(MKUserLocation *)userLocation {
    // Check if the updated location is farther than the thredhold distance
    // from the previously recorded location. If not, then simply do nothing.
    if (lastRecordedLocation_) {
        CLLocationDistance distance =
            [lastRecordedLocation_ distanceFromLocation:userLocation.location];
        if (distance <= kUserLocationDistanceThreshold) {
            NSLog(@"Not processing the user location because the distance is %f <= %f",
                  distance, kUserLocationDistanceThreshold);
            return;
        }
    }

    //[activityIndicator startAnimating];
    lastRecordedLocation_ = [userLocation location];

    CLLocationCoordinate2D coords = lastRecordedLocation_.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coords, 500, 500);
    [userMapView_ setRegion:region animated:YES];

    // callback method
    void (^displayNearbyStations)(NSError *err) =
    ^void(NSError *err){
        //[activityIndicator stopAnimating];
        if (!err) {
            // Also update the distance label to the source station if the
            // selection has been made.
            Station *sourceStation = [MuniStationStore sharedStore].selectedStation;
            if (sourceStation) {
                CLLocation *stationLocation =
                [[CLLocation alloc] initWithCoordinate:sourceStation.location
                                              altitude:0
                                    horizontalAccuracy:0
                                      verticalAccuracy:-1
                                             timestamp:[NSDate date]];
                [self updateDistanceToStationFrom:userMapView_.userLocation.location
                                               to:stationLocation];
            }
        }
        // It's possible that previously station selections are no longer valid
        // with the new set of nearby stations, so reload the data to reflect
        // the current state of things.
        [tableView_ reloadData];
    };
    [[MuniStationStore sharedStore] getNearbyStations:lastRecordedLocation_
                                       withCompletion:displayNearbyStations];
}


#pragma mark - table view data source overrides


// table view data source overrides
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    // currently only holds one row in each section
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    // currently there are two sections: source and destination
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tv
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"UITableViewCell"];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    }

    NSString *cellText = [OnTimeUIStringFactory prefixStationPrefix:2];

    // if station is selected show the station name as the cell text
    Station *station = [MuniStationStore sharedStore].selectedStation;
    if (station){
        cellText = [cellText stringByAppendingString:station.stationName];
    }
    cell.textLabel.text = cellText;
    return cell;
}


#pragma mark - table view delegate overrides


- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *stations = [[MuniStationStore sharedStore] nearbyStations];
    NSString *titleString = [OnTimeUIStringFactory stationHeaderString];
    Station *selectedStation = [MuniStationStore sharedStore].selectedStation;

    // block code to execute when the selection is made
    void (^stationSelectionMade)() = ^void(NSInteger stationIndex) {
        [[MuniStationStore sharedStore] selectStation:stationIndex];
        // Record that the table row needs to be updated.
        updateTableRow_ = YES;

        // Create a map annotation that points to the selected station
        // destination.
        Station *selectedStation = [MuniStationStore sharedStore].selectedStation;

        OnTimeStationMapAnnotation *stationAnnotation = sourceStationAnnotation_;

        // Simply update the annotation coordinate which will get relfected
        // in the map view.
        stationAnnotation.coordinate = selectedStation.location;
        stationAnnotation.title = selectedStation.stationName;
        stationAnnotation.subtitle = selectedStation.streetAddress;

        // If the callout view showing the station address is displayed,
        // deselecting the annotation closes it. This is done so that
        // the call out view is not going to be consistently shown even when we
        // change the annotation title dynamically.
        if ([userMapView_.annotations containsObject:stationAnnotation]) {
            [userMapView_ deselectAnnotation:stationAnnotation
                                   animated:YES];
        } else {
            [userMapView_ addAnnotation:stationAnnotation];
        }

        // Since the station selection has been made, the UI needs to be
        // configured (e.g. enabled appropriately).
        [self configureUI];
    };
    StationChoiceViewController *scvc = [[StationChoiceViewController alloc]
                                         initWithStations:stations
                                         withTitle:titleString
                                         withSelection:selectedStation
                                         withCompletion:stationSelectionMade];
    [self.navigationController pushViewController:scvc animated:YES];

    // Deselect the row to avoid having the row highlighted
    [tableView_ deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - action methods


- (IBAction)requestNotification:(id)sender {
    NSMutableDictionary *requestData = [NSMutableDictionary dictionary];

    // Method to get to the station is shared constants between the client
    // and the server.
    requestData[kDistanceModeKey] = @(methodToGetToStation_.selectedSegmentIndex);

    MuniStation *sourceStation = (MuniStation *)([MuniStationStore sharedStore].selectedStation);

    // error checking
    if (!sourceStation){
        NSDictionary *userInfo =
            @{kErrorTitleKey: [OnTimeUIStringFactory invalidTripTitle],
              kErrorMessageKey: [OnTimeUIStringFactory missingStationErrorMessage]};
        [[NSNotificationCenter defaultCenter] postNotificationName:kErrorNotificationName
                                                            object:nil
                                                          userInfo:userInfo];
        return;
    }
    requestData[kTagKey] = sourceStation.stationId;
    requestData[kRouteKey] = sourceStation.stationRoute;

    // add user location entries to the request data
    [requestData addEntriesFromDictionary:[[MuniStationStore sharedStore] currentUserLocation]];

    void (^completionBlock)(NSError *err) = ^(NSError *err) {
        // Reset current selection since the notification was successful
        [MuniStationStore sharedStore].selectedStation = nil;
        [tableView_ reloadData];

        // Reset the segment control.
        methodToGetToStation_.selectedSegmentIndex = 0;

        // Also remove the map annotations since the station selections are now
        // resetted.
        [userMapView_ removeAnnotations:@[sourceStationAnnotation_]];

        // Since the station selection has been reset, the UI needs to be
        // configured to be disabled.
        [self configureUI];
    };
    [[MuniStationStore sharedStore] requestNotification:requestData
                                         withCompletion:completionBlock];
}


#pragma mark - private helper methods


- (void)configureUI {
    Station *sourceStation = [MuniStationStore sharedStore].selectedStation;
    if (!sourceStation){
        requestNotificationButton_.enabled = NO;
        distanceLabel_.hidden = YES;
        distanceLabelBackgroundView_.hidden = YES;
    } else {
        requestNotificationButton_.enabled = YES;
    }
}

- (void)updateDistanceToStationFrom:(CLLocation *)fromLocation
                                 to:(CLLocation *)stationLocation {
    static CGFloat conversionRateFromMetersToMiles = 0.000621371;
    CLLocationDistance distance = [fromLocation
                                   distanceFromLocation:stationLocation];
    CGFloat distanceInMiles = distance * conversionRateFromMetersToMiles;
    NSLog(@"distance is %f", distanceInMiles);
    NSString *distanceStringTemplate = @"%.1f mi";
    distanceLabel_.text = [NSString stringWithFormat:distanceStringTemplate,
                          distanceInMiles];
    distanceLabel_.hidden = NO;
    distanceLabelBackgroundView_.hidden = NO;
}

@end
