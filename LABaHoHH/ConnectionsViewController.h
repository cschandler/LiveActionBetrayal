//
//  ConnectionsViewController.h
//  MCDemo
//
//  Created by Charles Chandler on 5/24/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ConnectionsViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITableView *tblConnectedDevices;
@property (weak, nonatomic) IBOutlet UIButton *btnDisconnect;
@property (weak, nonatomic) IBOutlet UIButton *backToStartButton;
@property (weak, nonatomic) IBOutlet UIButton *browseForDevicesButton;

- (IBAction)browseForDevices:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)backToStart:(UIButton *)sender;

@end

