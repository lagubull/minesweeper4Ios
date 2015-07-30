//
//  Game.h
//  minesweeper
//
//  Created by jlagunas on 09/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "DBManager.h"

#define CONSTANT_ROW 1000

@interface Game : NSObject

@property (atomic, strong) NSNumber *gameInternalId;
@property (atomic) int num_rows;
@property (atomic) int num_columns;
@property (atomic) int num_mines;
@property (atomic) int remainingMines;
@property (atomic) int **visible;
@property (atomic) int **board;
@property (atomic) int *mines;
@property (nonatomic) int last_cell_player1;
@property (nonatomic,strong) NSString *player1_username;
@property (nonatomic) int victory;
@property (nonatomic,strong) DBManager *manager;
@property (nonatomic,strong) NSString *date_last_played;

-(id) initWithNumMines: (int) numMines numColumns:  (int)numColumns  numRows: (int) numRows;

-(void) setupGame;
-(void) restoreBoard;
-(void) findCoordinates: (int) position row : (int *) row column: (int  *)  column;
-(NSString *) serializeVisible;
-(void) deSerializeVisible: (NSString *) visibleString;
-(NSString *) serializeMines;
-(void) deSerializeMines: (NSString *) minesString;
-(void) persist;
-(void) update;

@end
