//
//  VersusGame.h
//  minesweeper
//
//  Created by jlagunas on 09/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "Game.h"

@interface VersusGame : Game

@property (nonatomic) int last_cell_player2;
@property (nonatomic) NSString *player2_username;
@property (nonatomic) int mines_player1;
@property (nonatomic) int mines_player2;
@property (nonatomic) int player;

-(id) initWithNumMines: (int) numMines numColumns:  (int)numColumns  numRows: (int) numRows;
-(NSMutableArray *) getRestorableGames;
-(void) restore;

@end
