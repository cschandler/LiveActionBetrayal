//
//  ExplorerConnectionsViewController.h
//  LABaHoHH
//
//  Created by Charles Chandler on 5/31/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ExplorerConnectionsViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnDisconnect;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UILabel *connected;
@property (weak, nonatomic) IBOutlet UILabel *notConnected;
@property (weak, nonatomic) IBOutlet UIButton *backToStartButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *connectingIndicator;

- (IBAction)browseForDevices:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)backToStart:(UIButton *)sender;

@end
