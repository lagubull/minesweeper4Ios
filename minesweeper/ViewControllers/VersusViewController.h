//
//  VersusViewController.h
//  minesweeper
//
//  Created by jlagunas on 30/04/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

@class VersusGame;

/**
 Shows the board for two people to engage in a versus game
 */
@interface VersusViewController : UIViewController <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblPlayer1;

@property (strong, nonatomic) IBOutlet UILabel *lblPlayer2;

@property (strong, nonatomic) IBOutlet UILabel *lblPlayer1Mines;

@property (strong, nonatomic) IBOutlet UILabel *lblPlayer2Mines;

@property (strong, nonatomic) IBOutlet UILabel *lblRemainingMines;

@property (strong, nonatomic) IBOutlet UILabel *lblMines;

@property (strong, nonatomic) IBOutlet UIScrollView *boardScroll;

@property (strong, nonatomic) IBOutlet UIView *infoView;

@property (strong, nonatomic) IBOutlet UIView *bannerContainer;

@property (nonatomic) VersusGame *versusGame;

/**
 previous zoom scale
 */
@property (nonatomic) CGFloat previousScale;

- (void) paintMine:(NSInteger)tag
            player:(NSInteger)player
         animation:(BOOL)animation;

- (void)paintCell:(NSInteger)tag
            title:(NSString *)title;

- (void)loadBoard;

- (void)updateMinesCounters;

- (void)passTurn:(NSInteger)player;

- (IBAction)showOptions:(id)sender;

@end
