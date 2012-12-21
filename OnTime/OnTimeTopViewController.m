//
//  OnTimeTopViewController.m
//  OnTime
//
//  Created by Daisuke Fujiwara on 12/19/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//

#import "OnTimeTopViewController.h"
#import "BartViewController.h"
#import "MuniViewController.h"

@implementation OnTimeTopViewController

@synthesize bartButton = bartButton_;
@synthesize muniButton = muniButton_;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)transportationButtonPressed:(id)sender {
    if (sender == bartButton_) {
        BartViewController *bartViewController =
            [[BartViewController alloc] initWithNibName:nil
                                                 bundle:nil];
        [self.navigationController pushViewController:bartViewController
                                             animated:YES];
    } else if (sender == muniButton_) {
        MuniViewController *muniViewController =
            [[MuniViewController alloc] initWithNibName:nil
                                                 bundle:nil];
        [self.navigationController pushViewController:muniViewController
                                             animated:YES];
    } else {
        NSLog(@"Not registered sender button");
    }
}

@end
