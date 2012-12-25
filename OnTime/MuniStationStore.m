//
//  MuniStationStore.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 12/18/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "MuniStationStore.h"
#import "OnTimeConnection.h"
#import "OnTimeConstants.h"
#import "OnTimeUIStringFactory.h"

@implementation MuniStationStore

@synthesize selectedStation = selectedStation_;

+ (MuniStationStore *)sharedStore {
    static MuniStationStore *stationStore = nil;
    if (!stationStore){
        // set up the singleton instance
        stationStore = [[MuniStationStore alloc] init];
        stationStore.nearbyStations = [NSMutableArray array];
    }
    return stationStore;
}

- (void)getNearbyStations:(CLLocation *)currentLocation
           withCompletion: (void (^)(NSError *err))block {

    // define an outer completion block.
    // this block processes the HTTP response and stores the retrieved nearby
    // stations; it also calls the input parameter block to perform any additional
    // task.
    void (^processNearbyStations)(NSDictionary *stationsData, NSError *err) =
    ^void(NSDictionary *stationData, NSError *err){
        // First clear out the nearby stations.
        [self.nearbyStations removeAllObjects];

        if (!err){
            // Only register the closest station for each route for each
            // direction. The stations are sorted by distance from the current
            // location.
            NSMutableSet *routeSet = [NSMutableSet set];

            // process stations
            for (NSDictionary *stationDict in stationData[kStationDictKey]) {
                MuniStation *station = [[MuniStation alloc] init];
                station.stationId = stationDict[kStationTagKey];
                station.stationRoute = stationDict[kStationRouteKey];
                station.stationName = [NSString stringWithFormat:@"%@ (%@)",
                                       stationDict[kStationRouteKey],
                                       stationDict[kStationDirectionKey]];
                station.streetAddress = stationDict[kStationTitleKey];
                NSArray *locationCoords = stationDict[kStationLocationKey];
                if (locationCoords && [locationCoords count] == 2) {
                    station.location = CLLocationCoordinate2DMake([locationCoords[1] floatValue],
                                                                  [locationCoords[0] floatValue]);
                }

                if (![routeSet containsObject:station.stationName]) {
                    [self.nearbyStations addObject:station];
                    [routeSet addObject:station.stationName];
                }
            }
            // Sort the nearby stations in alphabetical order now.
            NSComparator comparator = ^NSComparisonResult(id first, id second) {
                return [((MuniStation *)first).stationName
                        compare:((MuniStation *)second).stationName];
            };
            self.nearbyStations = [[self.nearbyStations
                                    sortedArrayUsingComparator:comparator] mutableCopy];
        } else {
            NSLog(@"error was returned for getNearbyStations: %@", err);
            NSDictionary *userInfo =
                @{kErrorTitleKey: [OnTimeUIStringFactory nearbyStationErrorTitle],
                  kErrorMessageKey: [OnTimeUIStringFactory genericErrorMessage]};
            [[NSNotificationCenter defaultCenter] postNotificationName:kErrorNotificationName
                                                                object:nil
                                                              userInfo:userInfo];
        }
        if (block){
            block(err);
        }
    };

    // set up the HTTP GET request to retrieve nearby stations of the given
    // location.
    CLLocationCoordinate2D coords = currentLocation.coordinate;
    NSString *urlString = [NSString stringWithFormat:kStationUrlTemplate,
                           kMuniString,
                           coords.latitude, coords.longitude];
    [self issueNearbyStationRequest:urlString
                     withCompletion:processNearbyStations];
}

- (void)requestNotification:(NSDictionary *)requestData
             withCompletion:(void (^)(NSError *err))block {
    NSString *urlString = [NSString stringWithFormat:kNotificationUrl,
                           kMuniString];

    void (^registerNotification)(NSDictionary *notificationData, NSError *err) =
    ^void(NSDictionary *notificationData, NSError *err) {
        NSLog(@"response data is %@", notificationData);
        if (err){
            NSString *errorMessage = [OnTimeUIStringFactory genericErrorMessage];
            if (notificationData[kErrorCodeKey]) {
                int errorCode = [notificationData[kErrorCodeKey] intValue];
                switch (errorCode) {
                    case OnTimeErrorMissingParameter:
                        errorMessage = [OnTimeUIStringFactory missingParameterErrorMessage];
                        break;
                    case OnTimeErrorNotificationCreationFailure:
                        errorMessage = [OnTimeUIStringFactory failedToCreateNotificationErrorMessage];
                        break;
                    case OnTimeErrorNoAvailableTime:
                        errorMessage = [OnTimeUIStringFactory noTimeAvailableErrorMessage];
                        break;
                    default:
                        errorMessage = [OnTimeUIStringFactory genericErrorMessage];
                        break;
                }
            }
            NSDictionary *userInfo =
                @{kErrorTitleKey: [OnTimeUIStringFactory notificationErrorTitle],
                  kErrorMessageKey: errorMessage};
            [[NSNotificationCenter defaultCenter] postNotificationName:kErrorNotificationName
                                                                object:nil
                                                              userInfo:userInfo];
        } else {
            // Schedule the first available notification
            NSNumber *bufferTime = notificationData[kBufferTimeKey];
            NSNumber *durationTime = notificationData[kDurationKey];
            NSArray *notificationEstimates = notificationData[kEstimateKey];
            NSNumber *travelMode = notificationData[kModeKey];

            NSString *route = notificationData[kRouteKey];
            NSString *stationName = notificationData[kStationNameKey];
            // Setting up date formatter
            NSDateFormatter *formatter = [self dateFormatter];

            NSNumber *notificationEstimate = notificationEstimates[0];
            NSString *travelModeString = [OnTimeUIStringFactory modeString:[travelMode integerValue]];

            // Convert the arrival time into a string.
            NSInteger arrivalTimeInSeconds = [notificationEstimate intValue] * 60;
            NSDate *arrivalTime = [NSDate dateWithTimeIntervalSinceNow:arrivalTimeInSeconds];
            NSString *arrivalTimeString = [formatter stringFromDate:arrivalTime];

            // Convert the scheduled time for departure to the station into a string.
            NSInteger scheduledTimeInSeconds = arrivalTimeInSeconds - [durationTime intValue] -
                [bufferTime intValue];
            NSDate *scheduledTime = [NSDate dateWithTimeIntervalSinceNow:scheduledTimeInSeconds];
            NSString *scheduledTimeString = [formatter stringFromDate:scheduledTime];

            [self displayTransitNotification:[NSString stringWithFormat:[OnTimeUIStringFactory notificationMessageTemplate],
                                              scheduledTimeString,
                                              route,
                                              stationName,
                                              arrivalTimeString,
                                              travelModeString,
                                              [durationTime intValue] / 60]];

            // Create local notification to notify at the appropriate time.
            // First create user info dictionary
            NSDictionary *userInfo = @{kRouteKey: route,
                                       kTagKey: notificationData[kTagKey],
                                       kSnoozableKey: @YES,
                                       kTravelModeKey: travelMode,
                                       kTransitTypeKey: @(OnTimeTransitTypeMuni)};
            [self scheduleTransitReminderNotification:[NSString stringWithFormat:[OnTimeUIStringFactory reminderMessageTemplate],
                                                       route,
                                                       stationName,
                                                       arrivalTimeString,
                                                       travelModeString,
                                                       [durationTime intValue] / 60]
                                               atTime:scheduledTime
                                             withInfo:userInfo];
        }

        if (block) {
            block(err);
        }
    };
    [self issueNotificationRequest:urlString
                          withData:requestData
                    withCompletion:registerNotification];
}

- (void)processPendingNotification:(NSDictionary *)notificationData {
    if (notificationData) {
        NSLog(@"processing pending notification");
        NSMutableDictionary *requestData = [NSMutableDictionary dictionary];
        requestData[kTagKey] = notificationData[kTagKey];
        requestData[kRouteKey] = notificationData[kRouteKey];
        requestData[kDistanceModeKey] = notificationData[kTravelModeKey];

        // add user location entries to the request data
        [requestData addEntriesFromDictionary:[self currentUserLocation]];
        [self requestNotification:requestData
                   withCompletion:nil];
    }
}


#pragma mark - station selection related methods 


- (void)selectStation:(NSInteger)stationIndex {
    if (stationIndex < [self.nearbyStations count]){
        // Check that the station index is within the number of
        // available nearby stations.
        selectedStation_ = self.nearbyStations[stationIndex];
    } else {
        NSLog(@"station index is higher than nearby station count");
    }
}

@end
