//
//  VersusGameTableViewController.h
//  minesweeper
//
//  Created by jlagunas on 13/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

@class VersusGameCell;


/**
 View controller to show the list of restorable games
 */
@interface VersusGameTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UIView *bannerViewFrame;

@property (nonatomic, weak) IBOutlet VersusGameCell *gameCell;

@end
