//
//  VersusGame.h
//  minesweeper
//
//  Created by jlagunas on 09/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "Game.h"

/**
 Defines a game with two players that play one against the other
 */
@interface VersusGame : Game

@property (nonatomic) NSInteger lastCellPlayer2;

@property (nonatomic) NSString *player2Username;

@property (nonatomic) NSInteger minesPlayer1;

@property (nonatomic) NSInteger minesPlayer2;

@property (nonatomic) NSInteger player;

- (NSMutableArray *)getRestorableGames;

- (void)restore;

@end
