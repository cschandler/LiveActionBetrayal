//
//  SecondViewController.h
//  MCDemo
//
//  Created by Charles Chandler on 5/24/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *omenTableView;
@property (weak, nonatomic) IBOutlet UIButton *messageAllExplorersButton;
@property (weak, nonatomic) IBOutlet UIButton *selectTraitorButton;
@property (weak, nonatomic) IBOutlet UIButton *selectSingleExplorerButton;
@property (weak, nonatomic) IBOutlet UIButton *sendHauntButton;
@property (weak, nonatomic) IBOutlet UITextField *adHocMessageTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *explorerPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *messagePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *traitorPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *traitorMessagePicker;

-(void)didReceiveDataWithNotification:(NSNotification *)notification;
-(void)rollForHaunt;
-(NSUInteger)rollDie;
-(void)startHaunt;

- (IBAction)messageAllExplorers:(UIButton *)sender;
- (IBAction)selectTraitor:(UIButton *)sender;
- (IBAction)selectSingleExplorer:(UIButton *)sender;
- (IBAction)sendHaunt:(UIButton *)sender;

@end
