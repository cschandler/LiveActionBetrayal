//
//  ViewHauntViewController.m
//  LABaHoHH
//
//  Created by Charles Chandler on 6/26/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import "ViewHauntViewController.h"
#import "AppDelegate.h"

@interface ViewHauntViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property NSString *traitor;

-(void)updateTextView:(NSString *)messageFromRecievedData;

@end

@implementation ViewHauntViewController

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
    
    // Set up the blackout screen
    [_appDelegate createBlackoutScreen:[self view]];
    _appDelegate.blackoutScreen.hidden = YES;
    
    // Handles the data recieved over the mutipeer network
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public method implementation

// Recieves data from the watcher device
-(void)didReceiveDataWithNotification:(NSNotification *)notification {
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *messageFromRecievedData = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    [self updateTextView:messageFromRecievedData];
}

// If the recieved data is of appropriate length, add it to the textview
-(void)updateTextView:(NSString *)messageFromRecievedData {
    if (messageFromRecievedData.length > 140) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            _hauntTextView.text = messageFromRecievedData;
        });
    }
}



@end
