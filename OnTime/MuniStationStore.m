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
#import "OnTimeNotification.h"

@implementation MuniStationStore

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

        NSValue *isSuccessful = stationData[kSuccessKey];
        if (!err){
            if (isSuccessful){
                // process stations
                for (NSDictionary *stationDict in stationData[kStationDictKey]) {
                    MuniStation *station = [[MuniStation alloc] init];
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
            } else {
                NSLog(@"success returned false");
                err = [NSError errorWithDomain:@"Server error"
                                          code:OnTimeErrorCodeGeneral
                                      userInfo:nil];
            }
        } else {
            NSLog(@"error was returned for getNearbyStations: %@", err);
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
    
}

@end
