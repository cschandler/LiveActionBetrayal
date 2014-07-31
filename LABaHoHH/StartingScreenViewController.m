//
//  StartingScreenViewController.m
//  LABaHoHH
//
//  Created by Charles Chandler on 5/31/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import "StartingScreenViewController.h"
#import "StatsViewController.h"

@interface StartingScreenViewController ()

@end

@implementation StartingScreenViewController

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
    
    // Prevent app idle, in order to avoid multipeer mesh network disconnect when app goes into background
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    // Names of the characters that explorers can choose from
    _explorers = [[NSArray alloc] initWithObjects:@"Ox Bellows", @"Darren 'Flash' Williams", @"Vivian Lopez", @"Madame Zostra", @"Fr. Rhinehardt", @"Prof. Longfellow", @"Jenny LeClerc", @"Heather Granville", @"Missy Dubourde", @"Zoe Ingstrom", @"Peter Akimoto", @"Brandon Jaspers", nil];
    
    // Hide the button to segue to the explorer section, until the use chooses a character
    [_explorerSegue setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction method implementation

// Segue to the watcher tab controller
- (IBAction)watcherSegue:(id)sender {
    [self performSegueWithIdentifier:@"watcherCollectionSegue" sender:sender];
}

// Segue to the explorer tab controller
- (IBAction)explorerSegue:(id)sender {
    [self performSegueWithIdentifier:@"explorerCollectionSegue" sender:sender];
}

#pragma mark - UIPickerView delegate and datasource method implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_explorers count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _explorers[row];
}

// Store the character that the use chose, and activate the button
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectedExplorer = _explorers[row];
    [_explorerSegue setEnabled:YES];
}

#pragma mark - Navigation

// Pass the chosen character to the explorer section for stats display
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"explorerCollectionSegue"]) {
        UITabBarController *tab = segue.destinationViewController;
        StatsViewController *controller = [tab.viewControllers objectAtIndex:0];
        controller.selectedExplorer = _selectedExplorer;
        controller.explorers = _explorers; // Maybe dont need to pass the array, clean up if not needed
    }
}

@end
