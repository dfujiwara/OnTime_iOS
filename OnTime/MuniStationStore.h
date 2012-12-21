//
//  MuniStationStore.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 12/18/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//
//  A store object that contains relevant muni stations.

#import <Foundation/Foundation.h>
#import "MuniStation.h"
#import "OnTimeAbstractStationStore.h"

@interface MuniStationStore : OnTimeAbstractStationStore

@property (nonatomic, strong) MuniStation *selectedStation;

// Retrieves the single instance of the object that implements this
// protocol
+ (MuniStationStore *)sharedStore;

// Makes the station selection.
- (void)selectStation:(NSInteger)stationIndex;

@end
