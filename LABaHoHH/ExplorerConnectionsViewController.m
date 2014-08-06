//
//  ExplorerConnectionsViewController.m
//  LABaHoHH
//
//  Created by Charles Chandler on 5/31/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import "ExplorerConnectionsViewController.h"
#import "AppDelegate.h"

@interface ExplorerConnectionsViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification;

@end

@implementation ExplorerConnectionsViewController

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
    
    // Set up session with default device name
    [[_appDelegate mcManager] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    
    // Handles peers connecting and disconnecting
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

// If the use wants to use a custom device name
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Ensure a valid entry
    if ([_txtName.text length] > 0) {
        
        _appDelegate.mcManager.peerID = nil;
        _appDelegate.mcManager.session = nil;
        
        [_appDelegate.mcManager setupPeerAndSessionWithDisplayName:_txtName.text];
    }
    
    [_txtName resignFirstResponder];
    
    return YES;
}

#pragma mark - Public method implementation

// Advertises the user to any multipeer network browsers
- (IBAction)browseForDevices:(id)sender {
    [_appDelegate.mcManager advertiseSelf];
    _connectingIndicator.hidden = NO;
    [_connectingIndicator startAnimating];
}

// Disconnects the user from the multipeer network
- (IBAction)disconnect:(id)sender {
    [_appDelegate.mcManager.session disconnect];
    
    _txtName.enabled = YES;
}

// Returns to the StartingScreenViewController
- (IBAction)backToStart:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
    
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            
            // On the main thread, displays the connected label
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [_connected setHidden:NO];
                [_notConnected setHidden:YES];
                [_connectingIndicator stopAnimating];
                _connectingIndicator.hidden = YES;
            });
        }
        else if (state == MCSessionStateNotConnected){
            
            // On the main thread, displays the not connected label
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [_connected setHidden:YES];
                [_notConnected setHidden:NO];
            });
        }
        
        // On the main thread, stops the advertiser, so if the user gets disconnected the browser does not see multiple advertisers from the same peer
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [_appDelegate.mcManager.advertiser stop];
            
            // If there are peers in the network, active the disconnect button
            BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
            [_btnDisconnect setEnabled:!peersExist];
            
            // If there are no peers, allow the user to set up a session with a custom name
            [_txtName setEnabled:peersExist];
        });
    }
}

@end
