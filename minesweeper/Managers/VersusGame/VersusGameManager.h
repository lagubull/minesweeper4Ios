//
//  VersusGameManager.h
//  minesweeper
//
//  Created by jlagunas on 12/04/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

@class VersusViewController;
@class VersusGame;

/**
 Identifies a player
 */
typedef NS_ENUM(NSUInteger, JMSPlayer)
{
    JMSPlayer1 = 0, //player 1
    JMSPlayer2 = 1  // player 2
};

/**
 Handles the versus game
 */
@interface VersusGameManager : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) VersusGame *versusGame;

@property (nonatomic, strong) VersusViewController *versusViewController;

-(void)cellSelected:(NSInteger)cellID;

-(void)setupGame;

@end
