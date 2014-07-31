//
//  FirstExplorerViewController.m
//  LABaHoHH
//
//  Created by Charles Chandler on 5/31/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import "StatsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "StartingScreenViewController.h"
#import "ExplorerConnectionsViewController.h"

@interface StatsViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property UIView *blackoutScreen;
@property NSMutableArray *numberOfDieToRollArray;

-(void)sendData:(NSString *)omenName :(NSString *)room;
-(void)createExplorerStats;
-(NSString *)timestamp;
-(void)messageAlert:(NSString *)messageFromRecievedData;
-(void)lightOn:(AVCaptureDevice *)device;
-(void)lightOff:(AVCaptureDevice *)device;
-(void)createBlackoutScreen;
-(void)setSliderBackgrounds;

@end

@implementation StatsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // For blacking out the screen during the lights off phase
    [self createExplorerStats];
    [self createBlackoutScreen];
    _blackoutScreen.hidden = YES;
    
    // Handles the data recieved over the mutipeer network
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
    // Dismisses the keyboard when entering omen info
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    // Create array for datasource of pickerview
    _numberOfDieToRollArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 20; i++) {
        [_numberOfDieToRollArray addObject:[NSNumber numberWithInt:i + 1]];
    }
    
    // Replace UISlider backgrounds to eliminate lines
    [self setSliderBackgrounds];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction method implementation

// Calls sendData with appropriate info and cleans up omen textfields
- (IBAction)foundOmen:(UIButton *)foundOmenButton {
    NSString *omenName = [NSString stringWithFormat:@"%@", _nameOfOmenTextfield.text];
    NSString *room = [NSString stringWithFormat:@"%@", _roomFoundTextfield.text];
    
    // Ensure the the user has entered all pertinate information
    if ([omenName length] > 0 || [room length] > 0) {
        
        [self sendData:omenName :room];
        
        _nameOfOmenTextfield.backgroundColor = [UIColor whiteColor];
        _roomFoundTextfield.backgroundColor = [UIColor whiteColor];
        
        _nameOfOmenTextfield.text = @"";
        _roomFoundTextfield.text = @"";
        
        [_roomFoundTextfield resignFirstResponder];
        [_nameOfOmenTextfield resignFirstResponder];
        
    // If user has not filled out all textfields, highlights the empty ones in red
    } else {
        if ([omenName length] == 0) {
            _nameOfOmenTextfield.backgroundColor = [UIColor redColor];
            [_nameOfOmenTextfield resignFirstResponder];
        }
        
        if ([room length] == 0) {
            _roomFoundTextfield.backgroundColor = [UIColor redColor];
            [_roomFoundTextfield resignFirstResponder];
        }
    }
}

- (IBAction)rollDie:(UIButton *)sender {
    _numberOfDiePicker.hidden = NO;
}

#pragma mark - Textfield method implemetation

// Dismisses keyboard if the use does not wish to continue to use the omen textfields
-(void)dismissKeyboard {
    [_roomFoundTextfield resignFirstResponder];
    [_nameOfOmenTextfield resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_roomFoundTextfield resignFirstResponder];
    [_nameOfOmenTextfield resignFirstResponder];
    
    return YES;
}

#pragma mark - PickView datasource and delegate method implementation

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_numberOfDieToRollArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *rowString = [NSString stringWithFormat:@"%@", [_numberOfDieToRollArray objectAtIndex:row]];
    return rowString;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _numberOfDiePicker.hidden = YES;

    NSUInteger rollTotal = 0;
    for (NSInteger i = 0; i < row + 1; i++) {
        rollTotal += arc4random_uniform(3);
    }
    
    NSString *rollTotalString = [NSString stringWithFormat:@"%lu", (unsigned long)rollTotal];
    
    _lastRollLabel.text = [NSString stringWithFormat:@"Last roll: %@", rollTotalString];
    
    UIAlertView *displayRollTotal = [[UIAlertView alloc] initWithTitle:@"Die roll total"
                                                               message:rollTotalString
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles: nil];
    [displayRollTotal show];
}

#pragma mark - Public method implementation

// Dicides how the recieved data will be handled
-(void)didReceiveDataWithNotification:(NSNotification *)notification{
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSString *messageFromRecievedData = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];

    if (messageFromRecievedData.length > 3 && messageFromRecievedData.length < 140) {
        [self messageAlert:messageFromRecievedData];
    } else if (receivedData.length == 1) {
        [self lightOn:device];
    } else if (receivedData.length == 2) {
        [self lightOff:device];
    }
}

#pragma mark - Private method implementation

// Formats and sends data to the watcher
-(void)sendData:(NSString *)omenName :(NSString *)room {
    NSString *deviceName = [UIDevice currentDevice].name;
    NSString *timestamp = [self timestamp];
    
    // Create an array containing appropriate information
    NSArray *omen = [NSArray arrayWithObjects:omenName, room, deviceName, timestamp, nil];
    
    // Convert the array into NSData
    NSString *errorDescription = @"An error has occured with NSPropertyListSerialization";
    NSData *dataToSend = [NSPropertyListSerialization dataFromPropertyList:omen format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errorDescription];
    
    // Send to all peers
    NSArray *allPeers = [_appDelegate.mcManager collectAllConnectedPeers];
    NSError *error;
    
    for (MCSession *session in _appDelegate.mcManager.sessions) {
        [session sendData:dataToSend
                  toPeers:allPeers
                 withMode:MCSessionSendDataReliable
                    error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
}

// Create the timestamp for use in the omenInfo array
-(NSString *)timestamp {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm a"];
    
    NSDate *now = [[NSDate alloc] init];
    NSString *time = [dateFormat stringFromDate:now];
    
    return time;
}

// Display the message send by the watcher in a UIAlertView
-(void)messageAlert:(NSString *)messageFromRecievedData {
    // Do this on the main thread, for timely execution
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        UIAlertView *traitorAlert = [[UIAlertView alloc] initWithTitle:@"Attention Explorer"
                                                                  message:messageFromRecievedData
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        [traitorAlert show];
    });
}

// Turns the device's LED on
-(void)lightOn:(AVCaptureDevice *)device {
    // Do this on the main thread, for timely execution
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOn];
            [device unlockForConfiguration];
        }
        
        // Turns off blackout screen
        _blackoutScreen.hidden = YES;
        _appDelegate.blackoutScreen.hidden = YES;
    });
}

// Turns the device's LED off
-(void)lightOff:(AVCaptureDevice *)device {
    // Do this on the main thread, for timely execution
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
        
        // Blacks out the screen for extra spookeyness
        _blackoutScreen.hidden = NO;
        _appDelegate.blackoutScreen.hidden = NO;
    }); 
}

// Creates the blackout screen, to be used when the LED is off
-(void)createBlackoutScreen {
    CGRect blackoutScreenFrame = CGRectMake(0, 0, 320, 568);
    _blackoutScreen = [[UIView alloc] initWithFrame:blackoutScreenFrame];
    _blackoutScreen.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_blackoutScreen];
    
}

// Get rid of the default lines for the UISliders
-(void)setSliderBackgrounds {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0.0);
    UIImage *sliderBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_speedSlider setMinimumTrackImage:sliderBackgroundImage forState:UIControlStateNormal];
    [_mightSlider setMinimumTrackImage:sliderBackgroundImage forState:UIControlStateNormal];
    [_sanitySlider setMinimumTrackImage:sliderBackgroundImage forState:UIControlStateNormal];
    [_knowledgeSlider setMinimumTrackImage:sliderBackgroundImage forState:UIControlStateNormal];
    
    [_speedSlider setMaximumTrackImage:sliderBackgroundImage forState:UIControlStateNormal];
    [_mightSlider setMaximumTrackImage:sliderBackgroundImage forState:UIControlStateNormal];
    [_sanitySlider setMaximumTrackImage:sliderBackgroundImage forState:UIControlStateNormal];
    [_knowledgeSlider setMaximumTrackImage:sliderBackgroundImage forState:UIControlStateNormal];
}

// Implement stats and starting values for selected character
-(void)createExplorerStats {
    if ([_selectedExplorer isEqualToString:@"Ox Bellows"]) {
        
        _speedLabel.text = @"2    2    2    3    4    5    5    6";
        [_speedSlider setValue:5];
        _mightLabel.text = @"4    5    5    6    6    7    8    8";
        [_mightSlider setValue:3];
        _sanityLabel.text = @"2    2    3    4    5    5    6    7";
        [_sanitySlider setValue:3];
        _knowledgeLabel.text = @"2    2    3    3    5    5    6    6";
        [_knowledgeSlider setValue:3];
        
    } else if ([_selectedExplorer isEqualToString:@"Darren 'Flash' Williams"]) {
        
        _speedLabel.text = @"4    4    4    5    6    7    7    8";
        [_speedSlider setValue:5];
        _mightLabel.text = @"2    3    3    4    5    6    6    7";
        [_mightSlider setValue:3];
        _sanityLabel.text = @"1    2    3    4    5    5    5    7";
        [_sanitySlider setValue:3];
        _knowledgeLabel.text = @"2    3    3    4    5    5    5    7";
        [_knowledgeSlider setValue:3];
        
    } else if ([_selectedExplorer isEqualToString:@"Vivian Lopez"]) {
        
        _speedLabel.text = @"3    4    4    4    4    6    7    8";
        [_speedSlider setValue:4];
        _mightLabel.text = @"2    2    2    4    4    5    6    6";
        [_mightSlider setValue:3];
        _sanityLabel.text = @"4    4    4    5    6    7    8    8";
        [_sanitySlider setValue:3];
        _knowledgeLabel.text = @"4    5    5    5    5    6    6    7";
        [_knowledgeSlider setValue:4];
        
    } else if ([_selectedExplorer isEqualToString:@"Madame Zostra"]) {
        
        _speedLabel.text = @"2    3    3    5    5    6    6    7";
        [_speedSlider setValue:3];
        _mightLabel.text = @"2    3    3    4    5    5    5    6";
        [_mightSlider setValue:4];
        _sanityLabel.text = @"4    4    4    5    6    7    8    8";
        [_sanitySlider setValue:3];
        _knowledgeLabel.text = @"1    3    4    4    4    5    6    5";
        [_knowledgeSlider setValue:4];
        
    } else if ([_selectedExplorer isEqualToString:@"Fr. Rhinehardt"]) {
        
        _speedLabel.text = @"2    3    3    4    5    6    7    7";
        [_speedSlider setValue:3];
        _mightLabel.text = @"1    2    2    4    4    5    5    7";
        [_mightSlider setValue:3];
        _sanityLabel.text = @"3    4    5    5    6    7    7    8";
        [_sanitySlider setValue:5];
        _knowledgeLabel.text = @"1    3    3    4    5    6    6    8";
        [_knowledgeSlider setValue:4];
        
    } else if ([_selectedExplorer isEqualToString:@"Prof. Longfellow"]) {
        
        _speedLabel.text = @"2    2    4    4    5    5    6    6";
        [_speedSlider setValue:4];
        _mightLabel.text = @"1    2    3    4    5    5    6    6";
        [_mightSlider setValue:3];
        _sanityLabel.text = @"1    3    3    4    5    5    6    7";
        [_sanitySlider setValue:3];
        _knowledgeLabel.text = @"4    5    5    5    5    6    7    8";
        [_knowledgeSlider setValue:5];
        
    } else if ([_selectedExplorer isEqualToString:@"Jenny LeClerc"]) {
        
        _speedLabel.text = @"2    3    4    4    4    5    6    8";
        [_speedSlider setValue:4];
        _mightLabel.text = @"3    4    4    4    4    5    6    8";
        [_mightSlider setValue:3];
        _sanityLabel.text = @"1    1    2    4    4    4    5    6";
        [_sanitySlider setValue:5];
        _knowledgeLabel.text = @"2    3    3    4    4    5    6    8";
        [_knowledgeSlider setValue:3];
        
    } else if ([_selectedExplorer isEqualToString:@"Heather Granville"]) {
        
        _speedLabel.text = @"3    3    4    5    6    6    7    8";
        [_speedSlider setValue:3];
        _mightLabel.text = @"3    3    3    4    5    6    7    8";
        [_mightSlider setValue:3];
        _sanityLabel.text = @"3    3    3    4    5    6    6    6";
        [_sanitySlider setValue:3];
        _knowledgeLabel.text = @"2    3    3    4    5    6    7    8";
        [_knowledgeSlider setValue:5];
        
    } else if ([_selectedExplorer isEqualToString:@"Missy Dubourde"]) {
        
        _speedLabel.text = @"3    4    5    6    6    6    7    7";
        [_speedSlider setValue:3];
        _mightLabel.text = @"2    3    3    3    4    5    6    7";
        [_mightSlider setValue:4];
        _sanityLabel.text = @"1    2    3    4    5    5    6    7";
        [_sanitySlider setValue:3];
        _knowledgeLabel.text = @"2    3    4    4    5    6    6    6";
        [_knowledgeSlider setValue:4];
        
    } else if ([_selectedExplorer isEqualToString:@"Zoe Ingstrom"]) {
        
        _speedLabel.text = @"4    4    4    4    5    6    8    8";
        [_speedSlider setValue:4];
        _mightLabel.text = @"2    2    3    3    4    4    6    7";
        [_mightSlider setValue:4];
        _sanityLabel.text = @"3    4    5    5    6    6    7    8";
        [_sanitySlider setValue:3];
        _knowledgeLabel.text = @"1    2    3    4    4    5    5    5";
        [_knowledgeSlider setValue:4];
        
    } else if ([_selectedExplorer isEqualToString:@"Peter Akimoto"]) {
        
        _speedLabel.text = @"3    3    3    4    6    6    7    7";
        [_speedSlider setValue:4];
        _mightLabel.text = @"2    3    3    4    5    5    6    8";
        [_mightSlider setValue:3];
        _sanityLabel.text = @"3    4    4    4    5    6    6    7";
        [_sanitySlider setValue:4];
        _knowledgeLabel.text = @"3    4    4    5    6    7    7    8";
        [_knowledgeSlider setValue:3];
        
    } else if ([_selectedExplorer isEqualToString:@"Brandon Jaspers"]) {
        
        _speedLabel.text = @"3    4    4    4    5    6    7    8";
        [_speedSlider setValue:3];
        _mightLabel.text = @"2    3    3    4    5    6    6    7";
        [_mightSlider setValue:4];
        _sanityLabel.text = @"3    3    3    4    5    6    7    8";
        [_sanitySlider setValue:4];
        _knowledgeLabel.text = @"1    3    3    5    5    6    6    7";
        [_knowledgeSlider setValue:3];
    }
}

@end
