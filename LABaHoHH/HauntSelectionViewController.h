//
//  HauntSelectionViewController.h
//  LABaHoHH
//
//  Created by Charles Chandler on 6/26/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HauntSelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *selectHauntButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UITableView *hauntsTableView;
@property (weak, nonatomic) IBOutlet UITextView *hauntTextView;

- (IBAction)selectHaunt:(UIButton *)sender;
- (IBAction)undo:(UIButton *)sender;

@end
