//
//  BartStationStore.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/29/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "BartStationStore.h"
#import "BartStation.h"
#import "OnTimeConstants.h"
#import "OnTimeNotification.h"
#import "OnTimeUIStringFactory.h"

const NSInteger limitedStationNumber = 3;

@interface BartStationStore ()

// Validates the previously selected source station based on the newly
// registered nearby stations.
// This is required since the previously selected station
// is no longer a nearby station if the location has changed drastically from
// the time of selection.
- (void)validatePreviouslySelectedSourceStation;

@end

@implementation BartStationStore

+ (BartStationStore *)sharedStore {
    static BartStationStore *stationStore = nil;
    if (!stationStore){
        // set up the singleton instance
        stationStore = [[BartStationStore alloc] init];
        stationStore.nearbyStations = [NSMutableArray array];
        stationStore.selectedStations = [NSMutableArray
                                         arrayWithObjects:[NSNull null],
                                         [NSNull null], nil];
    }
    return stationStore;
}


#pragma mark - nearby stations related methods


- (void)getNearbyStations:(CLLocation *)currentLocation
           withCompletion: (void (^)(NSError *err))block {

    // Define an outer completion block.
    // This block processes the HTTP response and stores the retrieved nearby
    // stations; it also calls the input parameter block to perform any additional
    // task.
    void (^processNearbyStations)(NSDictionary *stationsData, NSError *err) =
    ^void(NSDictionary *stationData, NSError *err) {
        // First clear out the nearby stations.
        [self.nearbyStations removeAllObjects];

        NSValue *isSuccessful = stationData[kSuccessKey];
        if (!err){
            if (isSuccessful) {
                // Populate the stations from the station data.
                for (NSDictionary *stationDict in stationData[kStationDictKey]) {
                    BartStation *station = [[BartStation alloc] init];
                    station.stationId = stationDict[kStationIdKey];
                    station.stationName = stationDict[kStationNameKey];
                    station.streetAddress = stationDict[kStationAddressKey];
                    NSArray *locationCoords = stationDict[kStationLocationKey];
                    if (locationCoords && [locationCoords count] == 2) {
                         station.location = CLLocationCoordinate2DMake([locationCoords[1] floatValue],
                                                                       [locationCoords[0] floatValue]);
                    }
                    [self.nearbyStations addObject:station];
                }
                [self validatePreviouslySelectedSourceStation];
            } else {
                NSLog(@"success returned false");
                err = [NSError errorWithDomain:@"Server error"
                                          code:OnTimeErrorCodeGeneral
                                      userInfo:nil];
                // Because there are no possible selections, simply clear out
                // the already selected stations.
                [self resetCurrentSelectedStations];
            }
        } else {
            NSLog(@"error was returned for getNearbyStations: %@", err);
            // Because there are no possible selections, simply clear out the
            // already selected stations.
            [self resetCurrentSelectedStations];
        }
        
        if (block) {
            block(err);
        }
    };

    // set up the HTTP GET request to retrieve nearby stations of the given
    // location.
    CLLocationCoordinate2D coords = currentLocation.coordinate;
    NSString *urlString = [NSString stringWithFormat:kStationUrlTemplate,
                           kBartString,
                           coords.latitude, coords.longitude];

    [self issueNearbyStationRequest:urlString
                     withCompletion:processNearbyStations];
}


#pragma mark - notification related methods


- (void)requestNotification:(NSDictionary *)requestData
             withCompletion:(void (^)(NSError *err))block {
    NSString *urlString = [NSString stringWithFormat:kNotificationUrl,
                           kBartString];
    void (^registerNotification)(NSDictionary *notificationData, NSError *err) =
    ^void(NSDictionary *notificationData, NSError *err) {
        if (err){
            NSDictionary *userInfo =
                @{kErrorTitleKey: [OnTimeUIStringFactory notificationErrorTitle],
                  kErrorMessageKey: [OnTimeUIStringFactory genericErrorMessage]};
            [[NSNotificationCenter defaultCenter] postNotificationName:kErrorNotificationName
                                                                object:nil
                                                              userInfo:userInfo];
        } else {
            NSLog(@"response data is %@", notificationData);
            id successValue = notificationData[kSuccessKey];
            if (![successValue boolValue]){
                NSString *errorMessage = nil;
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

                NSDictionary *userInfo =
                    @{kErrorTitleKey: [OnTimeUIStringFactory noNotificationTitle],
                      kErrorMessageKey: errorMessage};
                [[NSNotificationCenter defaultCenter] postNotificationName:kErrorNotificationName
                                                                    object:nil
                                                                  userInfo:userInfo];
            } else {
                // Schedule the first available notification
                OnTimeNotification *notification =
                    [[OnTimeNotification alloc] initWithNotificationData:notificationData];
                [notification scheduleNotification:0];
            }
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

        NSString *startStationId = nil;
        NSArray *nearbyStations = [[BartStationStore sharedStore] nearbyStations:1];
        if ([nearbyStations count] > 0) {
            BartStation *nearbyStation = nearbyStations[0];
            startStationId = nearbyStation.stationId;
        } else {
            startStationId = notificationData[kStartId];
        }
        requestData[kSourceStationKey] = startStationId;
        requestData[kDestinationStationKey] = notificationData[kDestinationId];

        requestData[kDistanceModeKey] = notificationData[kTravelModeKey];

        CLLocationCoordinate2D coords = self.locationManager.location.coordinate;
        NSString *longitude = [NSString stringWithFormat:@"%f", coords.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%f", coords.latitude];
        requestData[kLongitudeKey] = longitude;
        requestData[kLatitudeKey] = latitude;

        [self requestNotification:requestData
                   withCompletion:nil];
    }
}


#pragma mark - station selection related methods 


- (void)selectStation:(NSInteger)stationIndex inGroup:(NSInteger)groupIndex {
    if (groupIndex < [self.selectedStations count]){
        // make sure the group index is within the expected range
        if (stationIndex < [self.nearbyStations count]){
            // also check that the station index is within the number of
            // available nearby stations.
            BartStation *selectedStation = self.nearbyStations[stationIndex];
            [self.selectedStations replaceObjectAtIndex:groupIndex
                                             withObject:selectedStation];
        } else {
            NSLog(@"station index is higher than nearby station count");
        }
    } else {
        NSLog(@"group index is higher than selected station index count");
    }
}

- (Station *)getSelectedStation:(NSInteger)groupIndex {
    id selectedStation = self.selectedStations[groupIndex];
    if (selectedStation == [NSNull null]){
        // if no selection was made for the given group, simply return nil
        return nil;
    }
    return selectedStation;
}

- (void)resetCurrentSelectedStations {
    for (NSInteger i = 0; i < [self.selectedStations count]; ++i){
        [self.selectedStations replaceObjectAtIndex:i
                                         withObject:[NSNull null]];
    }
}

- (void)validatePreviouslySelectedSourceStation {
    static NSUInteger sourceStationIndex = 0;
    BOOL previousStationFound = NO;
    Station *previousSourceStation = [self getSelectedStation:sourceStationIndex];
    if (previousSourceStation) {
        for (Station *station in [self nearbyStations:limitedStationNumber]) {
            if (station.stationId == previousSourceStation.stationId) {
                [self.selectedStations replaceObjectAtIndex:sourceStationIndex
                                                 withObject:station];
                previousStationFound = YES;
                break;
            }
        }
    }
    if (!previousStationFound) {
        // Simply clear out the previously selected source stations if it is
        // no longer a nearby station.
        [self.selectedStations replaceObjectAtIndex:sourceStationIndex
                                         withObject:[NSNull null]];
    }
}

@end
