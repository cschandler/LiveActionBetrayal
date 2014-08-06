//
//  AppDelegate.h
//  MCDemo
//
//  Created by Charles Chandler on 5/24/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

// Multipeer Connectivity components
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MCManager *mcManager;

// For creating blackout screens across tabs
@property NSString *explorerGuide;
@property NSString *traitorGuide;

@property UIView *blackoutScreen;

-(void)createBlackoutScreen:(UIView *)view;

@end
