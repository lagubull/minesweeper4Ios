//
//  VersusViewController.h
//  minesweeper
//
//  Created by admin on 30/04/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VersusGame;

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
@property (nonatomic) VersusGame *vGame;

/**
 previous zoom scale
 */
@property (nonatomic) CGFloat previousScale;

-(void) paintMine: (int) tag player: (int) player animation: (BOOL) animation;
-(void) paintCell: (int) tag title :(NSString *) title;
-(void) loadBoard;
-(void) updateMinesCounters;
-(void) passTurn: (int) player;
-(IBAction) showOptions: (id) sender;


@end
