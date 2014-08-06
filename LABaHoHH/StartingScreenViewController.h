//
//  StartingScreenViewController.h
//  LABaHoHH
//
//  Created by Charles Chandler on 5/31/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartingScreenViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property IBOutlet UIButton *watcherSegue;
@property IBOutlet UIButton *explorerSegue;
@property (weak, nonatomic) IBOutlet UIPickerView *explorerPicker;
@property (strong, nonatomic) NSArray *explorers;
@property NSString *selectedExplorer;

-(IBAction)watcherSegue:(id)sender;
-(IBAction)explorerSegue:(id)sender;

@end
