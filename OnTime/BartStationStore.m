//
//  BartStationStore.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/29/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "BartStationStore.h"
#import "OnTimeConnection.h"
#import "BartStation.h"
#import "OnTimeConstants.h"

const NSInteger limitedStationNumber = 3;

// keys for notification request
NSString * const distanceModeKey = @"mode";
NSString * const sourceStationKey = @"start";
NSString * const destinationStationKey = @"end";
NSString * const latitudeKey = @"lat";
NSString * const longitudeKey = @"long"; 

@implementation BartStationStore

+ (BartStationStore *)sharedStore {
    static BartStationStore *stationStore = nil;
    if (!stationStore){
        // set up the singleton instance
        stationStore = [[BartStationStore alloc] init];
        stationStore.nearbyStations = [NSMutableArray array];
        stationStore.selectedStationIndices = [NSMutableArray
                                               arrayWithObjects:[NSNumber numberWithInt:-1],
                                               [NSNumber numberWithInt:-1], nil];
    }
    return stationStore;
}

- (void)getNearbyStations:(CLLocation *)currentLocation
           withCompletion: (void (^)(NSArray *stations, NSError *err))block {

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
            } else {
                NSLog(@"success returned false");
                err = [NSError errorWithDomain:@"Server error" code:1 userInfo:nil];
            }
        } else {
            NSLog(@"error was returned for getNearbyStations: %@", err);
        }
        if (block){
            block(self.nearbyStations, err);
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

- (void)requestNotification:(NSDictionary *)requestData
             withCompletion:(void (^)(NSDictionary *notificationData, NSError *err))block {
    NSString *urlString = [NSString stringWithFormat:kNotificationUrl,
                           kBartString];
    [self issueNotificationRequest:urlString
                          withData:requestData
                    withCompletion:block];
}

- (void)selectStation:(NSInteger)stationIndex inGroup:(NSInteger)groupIndex {
    if (groupIndex < [self.selectedStationIndices count]){
        // make sure the group index is within the expected range
        if (stationIndex < [self.nearbyStations count]){
            // also check that the station index is within the number of
            // available nearby stations.
            NSNumber *selectedStationIndex = [NSNumber numberWithInt:stationIndex];
            [self.selectedStationIndices replaceObjectAtIndex:groupIndex
                                                   withObject:selectedStationIndex];
        } else {
            NSLog(@"station index is higher than nearby station count");
        }
    } else {
        NSLog(@"group index is higher than selected station index count");
    }
}

-(Station *)getSelectedStation:(NSInteger)groupIndex {
    NSNumber *selectedStationIndex = self.selectedStationIndices[groupIndex];
    NSInteger index = [selectedStationIndex integerValue];
    if (index < 0){
        // if no selection was made for the given group, simply return nil
        return nil;
    }
    return self.nearbyStations[[selectedStationIndex integerValue]];
}

- (void)resetCurrentSelectedStations {
    for (NSInteger i = 0; i < [self.selectedStationIndices count]; ++i){
        NSNumber *unselectedStationIndex = [NSNumber numberWithInt:-1];
        [self.selectedStationIndices replaceObjectAtIndex:i
                                               withObject:unselectedStationIndex];
    }
}

@end
