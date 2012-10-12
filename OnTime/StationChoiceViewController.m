//
//  StationChoiceViewController.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 9/26/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "StationChoiceViewController.h"
#import "Station.h"

static NSString * const backLabel = @"Back";

@implementation StationChoiceViewController

- (id)initWithStations:(NSArray*)stations
             withTitle:(NSString *)title
        withCompletion:(void (^)(int))block{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self){
        stationsArray = stations;
        selectionMade = block;

        // set up the navigation bar content
        [[self navigationItem] setTitle:title];
        [[[self navigationItem] rightBarButtonItem] setTitle:backLabel];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    // overriding the parent class designated initializer
    return [self initWithStations:nil withTitle:nil withCompletion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [stationsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"UITableViewCell"];
    }
    
    Station *station = [stationsArray objectAtIndex:[indexPath row]];
    NSString *cellText = [station stationName];
    NSString *cellDetailText = [station streetAddress];
    [[cell textLabel] setText:cellText];
    [[cell detailTextLabel] setText:cellDetailText];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected row is %d", [indexPath row]);
    if (selectionMade){
        selectionMade([indexPath row]);
    }
    [[self navigationController] popViewControllerAnimated:YES];
}
@end
