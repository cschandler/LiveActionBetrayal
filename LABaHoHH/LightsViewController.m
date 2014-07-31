//
//  FirstViewController.m
//  MCDemo
//
//  Created by Charles Chandler on 5/24/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import "LightsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "StatsViewController.h"

@interface LightsViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic)  NSTimer *flashlightTimer;
@property NSUInteger time;
@property NSUInteger userEnteredTime;
@property NSUInteger on;
@property NSUInteger off;
@property BOOL turnLightOn;

-(void)sendData:(NSUInteger *)length :(NSArray *)peers;
-(void)decrimentTimer;
-(void)dismissKeyboard;

@end

@implementation LightsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Initialize vaiables for the timer
    _time = 120;
    _userEnteredTime = 120;
    
    // Initialize variables for the flashlight functions
    _on = 1;
    _off = 2;
    
    // Set up tap to dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    // Add DONE button for the keyboard, which dismisses it
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(dismissKeyboard)];
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    _enterTime.inputAccessoryView = keyboardDoneButtonView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction method implementation

// Gets all peers, and calls flashlight ON function for them all
- (IBAction)flashON:(UIButton *)flashlight {
     NSArray *allPeers = [_appDelegate.mcManager collectAllConnectedPeers];
    [self sendData:&(_on) :allPeers];
}

// Gets all peers, and call flashlight OFF function for them all
- (IBAction)flashOFF:(UIButton *)flashlightOFF {
    NSArray *allPeers = [_appDelegate.mcManager collectAllConnectedPeers];
    [self sendData:&(_off) :allPeers];
}

// Starts timer
- (IBAction)startTimer:(UIButton *)timerStartButton {
    _flashlightTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(decrimentTimer)
                                                      userInfo:nil
                                                       repeats:YES];
    
}

// Stops timer
- (IBAction)stopTimer:(UIButton *)timerStopButton {
    [_flashlightTimer invalidate];
}

// Set the time to count down
- (IBAction)setTimer:(UIButton *)timerSetButton {
    _enterTime.hidden = NO;
    [_enterTime becomeFirstResponder];
}

// Reset timer to what it was previously set to
- (IBAction)resetTimer:(UIButton *)timerResetButton {
    _timerLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_userEnteredTime];
    _time = _userEnteredTime;
    [_flashlightTimer invalidate];
}

// Turn an invidual peer's flashlight ON
- (IBAction)individualLightsON:(UIButton *)individualLightONButton {
    [_connectedPeerPicker reloadAllComponents];
    _turnLightOn = true;
    _connectedPeerPicker.hidden = NO;
}

// Turn an individual peer's flashlight OFF
- (IBAction)individualLightsOFF:(UIButton *)individualLightOFFButton {
    [_connectedPeerPicker reloadAllComponents];
    _turnLightOn = false;
    _connectedPeerPicker.hidden = NO;
}

#pragma mark - Private method implementation

// Send data to peers
-(void)sendData:(NSUInteger *)length :(NSArray *)peers {
    void *bytes = malloc(2);
    NSData *dataToSend = [NSData dataWithBytes:bytes length:*length];
    NSError *error;
    
    for (MCSession *session in _appDelegate.mcManager.sessions) {
        
        [session sendData:dataToSend
                  toPeers:peers
                 withMode:MCSessionSendDataUnreliable
                    error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
}

// Dismiss keyboard
-(void)dismissKeyboard {
    [_enterTime resignFirstResponder];
}

// Decriment timer, update label, and call light ON or OFF function depending on switch status
-(void)decrimentTimer {
    
    _time = _time - 1;
    
    _timerLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long) _time];
    
    if (_time == 0) {
        [_flashlightTimer invalidate];
        
        // Get all peers if multiple sessions exist
        NSArray *allPeers = [_appDelegate.mcManager collectAllConnectedPeers];
        
        if ([_lightSwitch isOn]) {
            [self sendData:&(_on) :allPeers];
        } else {
            [self sendData:&(_off) :allPeers];
        }
    }
}

// Stores the time the user entered (or reseting) and updates the timer label
-(void)textFieldDidEndEditing:(UITextField *)enterTime {
    _userEnteredTime = [enterTime.text integerValue];
    _time = [enterTime.text integerValue];
    _timerLabel.text = [NSString stringWithFormat:@"%@", enterTime.text];
    enterTime.hidden = YES;
    enterTime.text = @"";
}



#pragma mark - UIPickerView Delegate and Datasource method implementation

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_appDelegate.mcManager.arrConnectedDevices count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_appDelegate.mcManager.arrConnectedDevices objectAtIndex:row];
}

// Calls the sendData function for the peer in the chosen row
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    for (MCSession *session in _appDelegate.mcManager.sessions) {
        
        for (MCPeerID *peer in session.connectedPeers) {
            
            if ([peer.displayName isEqualToString:_appDelegate.mcManager.arrConnectedDevices[row]]) {
                NSArray *singlePeer = [[NSArray alloc] initWithObjects:peer, nil];
                if (_turnLightOn) {
                    [self sendData:&(_on) :singlePeer];
                } else {
                    [self sendData:&(_off) :singlePeer];
                }
            }
        }
    }
    
    _connectedPeerPicker.hidden = YES;
}

@end
