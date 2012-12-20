//
//  OnTimeTopViewController.h
//  OnTime
//
//  Created by Daisuke Fujiwara on 12/19/12.
//  Copyright (c) 2012 HDProject. All rights reserved.
//
//  A view controller that represents the top level view controller.
//  This is the initial screen that the user sees when the app is loaded.

#import <UIKit/UIKit.h>

@interface OnTimeTopViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *bartButton;
@property (weak, nonatomic) IBOutlet UIButton *muniButton;

- (IBAction)transportationButtonPressed:(id)sender;

@end
