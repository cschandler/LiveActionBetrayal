//
//  HauntSelectionViewController.m
//  LABaHoHH
//
//  Created by Charles Chandler on 6/26/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import "HauntSelectionViewController.h"
#import "AppDelegate.h"

@interface HauntSelectionViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property NSMutableArray *hauntContentArray;
@property NSMutableArray *hauntNamesArray;
@property NSString *explorerGuide;
@property NSString *traitorGuide;
@property long indexOfSelectedHaunt;
@property Boolean hauntHasBeenSelected;

@end

@implementation HauntSelectionViewController

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
    
    // Initialize arrays
    _hauntContentArray = [[NSMutableArray alloc] init];
    _hauntNamesArray = [[NSMutableArray alloc] init];
    
    // Get txt files in the Documents directory of the app
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    
    // Store each txt file name and content in seperate arrays
    for (NSString *hauntName in directoryContent) {
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:hauntName];
        NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
        [_hauntNamesArray addObject:hauntName];
        [_hauntContentArray addObject:content];
    }

    // Display the txt file names in the tableview
    [_hauntsTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction button implmentation

// Selects the haunt guides to be sent to the explorers and traitor
- (IBAction)selectHaunt:(UIButton *)sender {
    
    // Only if a haunt had been selected
    if (_hauntHasBeenSelected) {
        
        // Split the txt file into seperate guides
        NSArray *splitExplorerAndTraitorGuides = [_hauntContentArray[_indexOfSelectedHaunt] componentsSeparatedByString:@"***"];
        _explorerGuide = [NSString stringWithString:splitExplorerAndTraitorGuides[0]];
        _traitorGuide = [NSString stringWithString:splitExplorerAndTraitorGuides[1]];
        
        // Replaces the tableview with a textview so the watcher can preview the haunt
        _hauntsTableView.hidden = YES;
        _hauntTextView.hidden = NO;
        _hauntTextView.text = _hauntContentArray[_indexOfSelectedHaunt];
        
        // Set up undo button in case the watcher doesnt want the haunt they chose
        [_undoButton setEnabled:YES];
        [_selectHauntButton setEnabled:NO];
        
        // Give the haunt guides to the app delegate in order to access them from another tab
        _appDelegate.explorerGuide = _explorerGuide;
        _appDelegate.traitorGuide = _traitorGuide;
    }
}

// Undoes the chosen haunt, allowing the watcher to chose another
- (IBAction)undo:(UIButton *)sender {
    _hauntTextView.hidden = YES;
    _hauntsTableView.hidden = NO;
    [_hauntsTableView reloadData];
    
    [_undoButton setEnabled:NO];
    [_selectHauntButton setEnabled:YES];
}

#pragma mark - UITableView delegate and datasource implementation

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_hauntNamesArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_hauntNamesArray objectAtIndex:indexPath.row];
    cell.textLabel.tag = indexPath.row;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _indexOfSelectedHaunt = indexPath.row;
    _hauntHasBeenSelected = TRUE;
}

@end
