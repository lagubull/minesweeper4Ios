//
//  VersusGameCell.h
//  minesweeper
//
//  Created by admin on 13/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VersusGame;

@interface VersusGameCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblPlayer1;
@property (strong, nonatomic) IBOutlet UILabel *lblPlayer2;
@property (strong, nonatomic) IBOutlet UILabel *lblPlayer1Mines;
@property (strong, nonatomic) IBOutlet UILabel *lblPlayer2Mines;
@property (strong, nonatomic) IBOutlet UILabel *lblRemainingMines;
@property (strong, nonatomic) IBOutlet UILabel *lblMines;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;

-(void) setVersusGames: (VersusGame *) vGame;

@end
