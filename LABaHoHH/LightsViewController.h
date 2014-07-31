//
//  FirstViewController.h
//  MCDemo
//
//  Created by Charles Chandler on 5/24/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LightsViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

// For main flashlight buttons
@property (weak, nonatomic) IBOutlet UIButton *flashlightON;
@property (weak, nonatomic) IBOutlet UIButton *flashlightOFF;

// For timer buttons
@property (weak, nonatomic) IBOutlet UIButton *timerStartButton;
@property (weak, nonatomic) IBOutlet UIButton *timerStopButton;
@property (weak, nonatomic) IBOutlet UIButton *timerSetButton;
@property (weak, nonatomic) IBOutlet UIButton *timerResetButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UITextField *enterTime;
@property (weak, nonatomic) IBOutlet UISwitch *lightSwitch;

// For individual flashlight buttons
@property (weak, nonatomic) IBOutlet UIButton *individualLightONButton;
@property (weak, nonatomic) IBOutlet UIButton *individualLightOFFbutton;
@property (weak, nonatomic) IBOutlet UIPickerView *connectedPeerPicker;

// Main flashlight button methods
-(IBAction)flashON:(UIButton *)flashlightON;
-(IBAction)flashOFF:(UIButton *)flashlightOFF;

// Timer button methods
-(IBAction)startTimer:(UIButton *)timerStartButton;
-(IBAction)stopTimer:(UIButton *)timerStopButton;
-(IBAction)setTimer:(UIButton *)timerSetButton;
-(IBAction)resetTimer:(UIButton *)timerResetButton;

// Individual flashlight buttun methods
-(IBAction)individualLightsON:(UIButton *)individualLightONButton;
-(IBAction)individualLightsOFF:(UIButton *)individualLightOFFButton;

@end
