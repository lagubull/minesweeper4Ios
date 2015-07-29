//
//  VersusGameTableViewController.h
//  minesweeper
//
//  Created by jlagunas on 13/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VersusGameCell;

@interface VersusGameTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *bannerViewFrame;
@property (nonatomic, weak) IBOutlet VersusGameCell *gameCell;

@end
