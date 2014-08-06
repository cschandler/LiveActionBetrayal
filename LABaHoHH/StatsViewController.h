//
//  FirstExplorerViewController.h
//  LABaHoHH
//
//  Created by Charles Chandler on 5/31/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatsViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

// For sending omens to the watcher
@property (weak, nonatomic) IBOutlet UIButton *foundOmenButton;
@property (weak, nonatomic) IBOutlet UITextField *nameOfOmenTextfield;
@property (weak, nonatomic) IBOutlet UITextField *roomFoundTextfield;

// For displaying the stats of the selected character
@property NSString *selectedExplorer;
@property NSArray *explorers;
@property NSArray *explorerStats;

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;
@property (weak, nonatomic) IBOutlet UILabel *mightLabel;
@property (weak, nonatomic) IBOutlet UISlider *mightSlider;
@property (weak, nonatomic) IBOutlet UILabel *sanityLabel;
@property (weak, nonatomic) IBOutlet UISlider *sanitySlider;
@property (weak, nonatomic) IBOutlet UILabel *knowledgeLabel;
@property (weak, nonatomic) IBOutlet UISlider *knowledgeSlider;

// For rollong die
@property (weak, nonatomic) IBOutlet UIButton *rollDieButton;
@property (weak, nonatomic) IBOutlet UIPickerView *numberOfDiePicker;
@property (weak, nonatomic) IBOutlet UILabel *lastRollLabel;

// Button for sending omen information
- (IBAction)foundOmen:(UIButton *)foundOmenButton;

// For rolling die
- (IBAction)rollDie:(UIButton *)sender;

// For dealing with recieved data
-(void)didReceiveDataWithNotification:(NSNotification *)notification;

@end
