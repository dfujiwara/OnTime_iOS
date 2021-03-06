//
//  MuniStation.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 12/18/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//
//  An object that represents a muni station.

#import "Station.h"

@interface MuniStation : Station

// Represents the route that this station object is responsible for.
@property (nonatomic, strong) NSString *stationRoute;

@end
