//
//  SecondViewController.m
//  MCDemo
//
//  Created by Charles Chandler on 5/24/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import "MessagesViewController.h"
#import "AppDelegate.h"
#import "HauntSelectionViewController.h"

@interface MessagesViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

@property NSMutableArray *omenList;
@property NSMutableArray *explorersArray;
@property NSArray *messageArray;
@property NSArray *traitorMessageArray;

@property NSString *pickedExplorer;
@property NSString *traitor;

@property int setMessageRecipient;

@property BOOL usePresetTraitorMessage;
@property BOOL traitorIsSet;
@property BOOL hauntNotSent;

-(void)sendDataAllExplorers:(NSString *)messageToSend;
-(void)sendDataToSinglePeer:(NSString *)messageToSend;
-(void)prepAdHocMessageTextField;
-(void)removeTraitorFromExplorers;
-(void)resizeButtonFont:(UIButton *)button;
-(void)hideAllPickerViews;

@end

@implementation MessagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
    // Deals with received data
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    
    // Initialize omenList
    _omenList = [[NSMutableArray alloc] init];
    
    // Array of pre-loaded messages to send to explorers / traitor
    _messageArray = [[NSArray alloc] initWithObjects:@"The haunt has begun!  You're haunt guide is now unlocked", @"Return to the foyer", @"Disregard last message", @"Ad hoc message", nil];
    _traitorMessageArray = [[NSArray alloc] initWithObjects:@"You are the traitor!  You're haunt guide is now unlocked", @"Ad hoc message", nil];
    
    // Boolean to track if haunt has been sent
    _hauntNotSent = true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Enables the haunt to be sent to explorers if the watcher has choosen a haunt, and you have not sent a haunt yet
-(void)viewDidAppear:(BOOL)animated {
    if (_appDelegate.explorerGuide && _appDelegate.traitorGuide && _hauntNotSent) {
        [_sendHauntButton setEnabled:YES];
        _hauntNotSent = false;
    }
}

#pragma mark - Public method implementation

// Deals with recieved data
-(void)didReceiveDataWithNotification:(NSNotification *)notification {
    
    // Translate data into an array of strings
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSError *error;
    NSArray *omen = [NSPropertyListSerialization propertyListWithData:receivedData options:0 format:NULL error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    // Combine the array into a single string
    NSString *omenInfo = [omen componentsJoinedByString:@", "];
    
    // Add the combined string to an array
    [_omenList addObject:omenInfo];
    
    // On the main thread, reload the table to display the new contents
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [_omenTableView reloadData];
    });
    
    // Roll to see if the haunt starts each time an explorer finds an omen
    [self rollForHaunt];
}

// Determine if the haunt will start
-(void)rollForHaunt {
    
    // Roll 8 die
    NSUInteger hauntRollTotal = 0;
    for (int i = 0; i < 8; i++) { // double check that 8 is the number of die rolled for haunt check
        hauntRollTotal += [self rollDie];
    }
    
    // Haunt only starts if the die total is greater than the total number of omens
    if (hauntRollTotal < [_omenList count]) {
        [self startHaunt];
    }
}

// Generates a random number based on a d3
-(NSUInteger)rollDie {
    NSUInteger roll = arc4random_uniform(3); // switch to d6?
    return roll;
}

// On the main thread, alert the watcher that the haunt has begun with a UIAlertView
-(void)startHaunt {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSString *hauntMessage = [NSString stringWithFormat:@"The haunt begins with omen:\n%@", [_omenList lastObject]];
        
        UIAlertView *startHauntAlert = [[UIAlertView alloc] initWithTitle:@"Attention Watcher"
                                                                  message:hauntMessage
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
        [startHauntAlert show];
    });
}

#pragma mark - Private method implementation

// Sends data to explorers, if traitor has been chosen, message will not be sent to them
-(void)sendDataAllExplorers:(NSString *)messageToSend {
    
    NSArray *allPeers;
    
    // Excludes the traitor if it has been set
    if (_traitorIsSet) {
        allPeers = [NSArray arrayWithArray:_explorersArray];
    } else {
        allPeers = [_appDelegate.mcManager collectAllConnectedPeers];
    }

    // Encode and send data
    NSData *dataToSend = [messageToSend dataUsingEncoding:NSUTF8StringEncoding];
    
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

-(void)sendDataToSinglePeer:(NSString *)messageToSend {
    
    // Encode message
    NSData *dataToSend = [messageToSend dataUsingEncoding:NSUTF8StringEncoding];
    
    // Match peer to a session
    NSArray *singlePeer;
    for (MCSession *session in _appDelegate.mcManager.sessions) {
        
        // Find peer
        for (MCPeerID *peer in session.connectedPeers) {
            
            // Create array with the single MCPeer
            if (_setMessageRecipient == 1) {
                if ([peer.displayName isEqual:_traitor]) {
                    singlePeer = [NSArray arrayWithObject:peer];
                }
            } else if (_setMessageRecipient == 2) {
                if ([peer.displayName isEqual:_pickedExplorer]) {
                    singlePeer = [NSArray arrayWithObject:peer];
                }
            } else {
                singlePeer = [NSArray new];
            }
        }
    
        NSError *error;
        
        // Send data
        [_appDelegate.mcManager.session sendData:dataToSend
                                         toPeers:singlePeer
                                        withMode:MCSessionSendDataReliable
                                           error:&error];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

// Cleans up textfield and sets it as first responder
-(void)prepAdHocMessageTextField {
    [_adHocMessageTextField setEnabled:YES];
    [_adHocMessageTextField becomeFirstResponder];
    _adHocMessageTextField.backgroundColor = [UIColor whiteColor];
    _adHocMessageTextField.text = @"";
}

// Creates an array of explorers that are not the traitor
-(void)removeTraitorFromExplorers {
    _explorersArray = [[NSMutableArray alloc] init];
    
    for (MCSession *session in _appDelegate.mcManager.sessions) {
        
        for (MCPeerID *peer in session.connectedPeers) {
            if ([peer.displayName isEqualToString:_traitor]) {
                // Do nothing
            } else {
                [_explorersArray addObject:peer];
            }
        }
    }
}

-(void)resizeButtonFont:(UIButton *)button {
    button.titleLabel.numberOfLines = 1;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.lineBreakMode = NSLineBreakByClipping;
}

-(void)hideAllPickerViews {
    _messagePicker.hidden = YES;
    _explorerPicker.hidden = YES;
    _traitorPicker.hidden = YES;
    _traitorMessagePicker.hidden = YES;
}

#pragma mark - IBAction method implementation

- (IBAction)messageAllExplorers:(UIButton *)sender {
    [self hideAllPickerViews];
    _messagePicker.hidden = NO;
}

// Selects the traitor, or if the traitor has been selected, messegaes them
- (IBAction)selectTraitor:(UIButton *)sender {
    if (!_traitorIsSet) {
        
        // Ensures that the array exists to prevent fatal error
        if ([_appDelegate.mcManager.arrConnectedDevices count] > 0) {
            [_traitorPicker reloadAllComponents];
            [self hideAllPickerViews];
            _traitorPicker.hidden = NO;
        }
    } else {
        [self hideAllPickerViews];
        _traitorMessagePicker.hidden = NO;
    }
}

// Selects a single explorer
- (IBAction)selectSingleExplorer:(UIButton *)sender {
    
    // Ensures that the array exists to prevent fatal error
    if ([_appDelegate.mcManager.arrConnectedDevices count] > 0) {
        [_explorerPicker reloadAllComponents];
        [self hideAllPickerViews];
        _explorerPicker.hidden = NO;
    }
}

// Sends the haunt guides to explorers and traitor respectivley
- (IBAction)sendHaunt:(UIButton *)sender {
    [self sendDataAllExplorers:_appDelegate.explorerGuide];
    [self sendDataToSinglePeer:_appDelegate.traitorGuide];
}


#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_omenList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_omenList objectAtIndex:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

#pragma mark - UIPickerView Delegate and Datasource method implementation

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// Set number of components based on picker tag
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 2) {
        return [_messageArray count];
    } else if (pickerView.tag == 3) {
        return [_traitorMessageArray count];
    } else {
        return [_appDelegate.mcManager.arrConnectedDevices count];
    }
}

// Set titles for picker based on picker tag
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == 2) {
        return [_messageArray objectAtIndex:row];
    } else if (pickerView.tag == 3) {
        return [_traitorMessageArray objectAtIndex:row];
    } else {
        return [_appDelegate.mcManager.arrConnectedDevices objectAtIndex:row];
    }
}

// Takes action based on which picker tag
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    // For the traitorPicker
    if (pickerView.tag == 0) {
        
        // Choose a peer to become the traitor
        _traitor = _appDelegate.mcManager.arrConnectedDevices[row];
        _traitorPicker.hidden = YES;
        NSString *traitorTitleForButton = [NSString stringWithFormat:@"Traitor: %@", _traitor];
        [_selectTraitorButton setTitle:traitorTitleForButton forState:UIControlStateNormal];
        [self resizeButtonFont:_selectTraitorButton];
        
        // Set boolean to true
        _traitorIsSet = true;
        
        // Call up the traitorMessegePicker
        _traitorMessagePicker.hidden = NO;
        
        // Create explorer array without traitor in it
        [self removeTraitorFromExplorers];
    
    // For the explorerPicker
    } else if (pickerView.tag == 1) {
        
        // Only ad-hoc messages for single explorers
        [self prepAdHocMessageTextField];
        
        // Choose the single peer to message
        _pickedExplorer = _appDelegate.mcManager.arrConnectedDevices[row];
        _explorerPicker.hidden = YES;
        NSString *pickedExplorerTitleForButton = [NSString stringWithFormat:@"Picked Explorer: %@", _pickedExplorer];
        [_selectSingleExplorerButton setTitle:pickedExplorerTitleForButton forState:UIControlStateNormal];
        [self resizeButtonFont:_selectSingleExplorerButton];
        
        // For directing where to send the message in dataToSinglePeer & textFieldShouldReturn methods
        _setMessageRecipient = 2;
        
    // For the messagePicker
    } else if (pickerView.tag == 2) {
        
        // If the watcher wants to create a custom message
        if ([_messageArray[row] isEqualToString:@"Ad hoc message"]) {
            _messagePicker.hidden = YES;
            [self prepAdHocMessageTextField];
            
            // For directing where to send the message in dataToSinglePeer & textFieldShouldReturn methods
            _setMessageRecipient = 3;
            
        // Use a pre-loaded message
        } else {
            NSString *messageToSend = _messageArray[row];
            _messagePicker.hidden = YES;
            [self sendDataAllExplorers:messageToSend];
        }
    
    // For the traitorMessagePicker
    } else if (pickerView.tag == 3) {
        
        // For directing where to send the message in dataToSinglePeer & textFieldShouldReturn methods
        _setMessageRecipient = 1;
        
        // For using a custom message
        if ([_traitorMessageArray[row] isEqualToString:@"Ad hoc message"]) {
            _traitorMessagePicker.hidden = YES;
            _usePresetTraitorMessage = false;
            [self prepAdHocMessageTextField];
        
        // For using a pre-loaded message
        } else {
            _traitorMessagePicker.hidden = YES;
            _usePresetTraitorMessage = true;
            [self sendDataToSinglePeer:_traitorMessageArray[row]];
            _usePresetTraitorMessage = false;
        }
    }
}

#pragma mark - UITextField method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_adHocMessageTextField resignFirstResponder];
    
    // Ensures the custom message is of the proper length
    if (_adHocMessageTextField.text.length > 3 && _adHocMessageTextField.text.length < 140) {
        if (_setMessageRecipient == 3) {
            [self sendDataAllExplorers:_adHocMessageTextField.text];
        } else {
            [self sendDataToSinglePeer:_adHocMessageTextField.text];
        }
    } else {
        _adHocMessageTextField.backgroundColor = [UIColor redColor];
        _adHocMessageTextField.text = _adHocMessageTextField.placeholder;
    }
    
    // Disable text field again
    [_adHocMessageTextField setEnabled:NO];
    
    return YES;
}

@end
