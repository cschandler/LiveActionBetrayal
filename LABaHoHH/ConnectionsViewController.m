//
//  ConnectionsViewController.m
//  MCDemo
//
//  Created by Charles Chandler on 5/24/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import "ConnectionsViewController.h"
#import "AppDelegate.h"

@interface ConnectionsViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification;
-(void)createPeerAlertView:(MCPeerID *)peer :(BOOL)connected;

@end

@implementation ConnectionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Set up session with the default device name
    [[_appDelegate mcManager] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    
    // Handles peers connecting / disconnecting
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // Ensures custom name isnt blank
    if ([_txtName.text length] > 0) {
        
        _appDelegate.mcManager.peerID = nil;
        _appDelegate.mcManager.session = nil;
        
        // Set up session with custom name
        [_appDelegate.mcManager setupPeerAndSessionWithDisplayName:_txtName.text];
    }
    
    [_txtName resignFirstResponder];
    
    return YES;
}

#pragma mark - Public method implementation

// Set up browser for automatic connection
- (IBAction)browseForDevices:(id)sender {
    [_appDelegate.mcManager setupMCNearbyServiceBrowser];
    [_browseForDevicesButton setTitle:@"Browsing..." forState:UIControlStateNormal];
}

// Tear down session, and clean up
- (IBAction)disconnect:(id)sender {
    [_appDelegate.mcManager.session disconnect];
    [_appDelegate.mcManager.nearbyBrowser stopBrowsingForPeers];
    _txtName.enabled = YES;
    [_appDelegate.mcManager.arrConnectedDevices removeAllObjects];
    [_browseForDevicesButton setTitle:@"Browse for Devices" forState:UIControlStateNormal];
}

// Reset to title screen
- (IBAction)backToStart:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private method implementation

/*
 peerDidChangeStateWithNotification functions differently in the explorer side of the app than the
 watcher side.  In the explorer side, the only time a peer is detected being connected / disconnected
 is when the explorer connects to a session with the watcher, since the watcher is hosting all of
 the sessions.  On the watcher side, they handle all connections and disconnections for the session,
 and as such, can handle effects on every peer connection / disconnection.
 
 TL;DR:  Explorer handles only the connection with itself and the host.
 Watcher, since it is the host, handles all connections.
 */
-(void)peerDidChangeStateWithNotification:(NSNotification *)notification {
    
    // peer information
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    // Performs actions based on connecting status
    if (state != MCSessionStateConnecting) {
        
        // if connected after state change
        if (state == MCSessionStateConnected) {
            
            // Add this device to connected devices array
            [_appDelegate.mcManager.arrConnectedDevices addObject:peerDisplayName];
            
            // Alert watcher a peer has connected
            [self createPeerAlertView:peerID :true];
            
            // Allow the watcher to disconnect from the session
            [_btnDisconnect setEnabled:YES];
        }
        
        // if peer is not connected after state change
        else if (state == MCSessionStateNotConnected){
            
            // If there are still other peers connected
            if ([_appDelegate.mcManager.arrConnectedDevices count] > 0) {
                
                // remove the peer that is no longer connected from the connected devices array
                NSUInteger indexOfPeer = [_appDelegate.mcManager.arrConnectedDevices indexOfObject:peerDisplayName];
                [_appDelegate.mcManager.arrConnectedDevices removeObjectAtIndex:indexOfPeer];
            
            // if no peers are connected
            } else {
                
                // clean up
                [_btnDisconnect setEnabled:NO];
                [_txtName setEnabled:YES];
            }
            
            // Alert the watcher that the peer is disconnected
            [self createPeerAlertView:peerID :false];
        }
        
        // On the main thread,
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            // Display current devices connected in the table
            [_tblConnectedDevices reloadData];
        });
    }
}

// Create UIAlterView when peers connect / disconnect
-(void)createPeerAlertView:(MCPeerID *)peer :(BOOL)connected {
    NSString *titleMessage;
    if (connected) {
        titleMessage = @"Peer Connected";
    } else {
        titleMessage = @"Peer Disconnected";
    }
    
    NSString *alertMessage = [NSString stringWithFormat:@"%@", peer.displayName];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        UIAlertView *peerDisconnectAlertView = [[UIAlertView alloc] initWithTitle:titleMessage
                                                                          message:alertMessage
                                                                         delegate:self
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
        [peerDisconnectAlertView show];
    });
}

#pragma mark - UITableView Delegate and Datasource method implementation

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_appDelegate.mcManager.arrConnectedDevices count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    cell.textLabel.text = [_appDelegate.mcManager.arrConnectedDevices objectAtIndex:indexPath.row];
    
    return cell;
}

@end
