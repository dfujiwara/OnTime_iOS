//
//  BartStationStore.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/29/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//
//  A store object that contains relevant bart stations.

#import <Foundation/Foundation.h>
#import "BartStation.h"
#import "OnTimeAbstractStationStore.h"

extern const NSInteger limitedStationNumber;

@interface BartStationStore : OnTimeAbstractStationStore

@property (nonatomic, strong) NSMutableArray *selectedStations;

// Retrieves the single instance of the object that implements this
// protocol
+ (BartStationStore *)sharedStore;

// Makes the station selection of the given group (e.g. source or destination)
- (void)selectStation:(NSInteger)stationIndex inGroup:(NSInteger)groupIndex;

// Gets the selected station of the given group.
- (Station *)getSelectedStation:(NSInteger)groupIndex;

// Resets currently selected stations.
- (void)resetCurrentSelectedStations;

@end
