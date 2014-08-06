//
//  ViewHauntViewController.h
//  LABaHoHH
//
//  Created by Charles Chandler on 6/26/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewHauntViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *hauntTextView;

@property UIView *blackoutScreen;

-(void)didReceiveDataWithNotification:(NSNotification *)notification;

@end
