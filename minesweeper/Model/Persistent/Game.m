//
//  Game.m
//
//  Created by jlagunas on 09/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "Game.h"
#import "Tools.h"

@implementation Game

@synthesize num_rows;
@synthesize num_columns;
@synthesize num_mines;
@synthesize board;
@synthesize visible;
@synthesize mines;
@synthesize player1_username;
@synthesize last_cell_player1;
@synthesize victory;
@synthesize manager;
@synthesize remainingMines;

-(id) init
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL first_time = [defaults boolForKey:@"first_time"];

    self.manager = [[DBManager alloc] init];
    if (!first_time)
        [self.manager upgrade:0 newVersion:1];
    self.game_internal_id = -1;
    return self;
}

-(id) initWithNumMines: (int) numMines numColumns:  (int)numColumns  numRows: (int) numRows
{
    self = [self  init];
    self.num_columns = numColumns;
    self.num_rows = numRows;
    self.num_mines = numMines;
    self.last_cell_player1 = -1;
    self.player1_username = @"Player 1";
    self.victory = 0;
    self.remainingMines = self.num_mines;
    self.date_last_played = [Tools date2String: [NSDate date] ];
    
    self.board = (int **)calloc(num_rows,sizeof(int*));
    self.visible = (int **)calloc(num_rows,sizeof(int*));
    self.mines = (int *)calloc(num_mines,sizeof(int*));
    self.board[0] = (int *)calloc(num_rows * num_columns,sizeof(int*));
    self.visible[0] = (int *)calloc(num_rows * num_columns,sizeof(int*));
    
    return self;
}


-(NSString *) serializeVisible
{
    NSString *visibleString = @"";
    for (int i = 0; i < num_rows ; i++)
    {
        for (int j = 0; j < num_columns ; j++)
        {
            visibleString = [visibleString  stringByAppendingString: [NSString stringWithFormat: @"%d;",visible[i][j]]];
        }
      
    }
    return visibleString;
}

-(void) deSerializeVisible: (NSString *) visibleString
{
    NSArray* _visible = [visibleString  componentsSeparatedByString:@";"];
    int cont = 0;
        
    for (int i = 0; i < num_rows ; i++)
    {
        self.visible[i] = visible[0] + i * num_columns;
        for (int j = 0; j < num_columns ; j++)
        {
            self.visible[i][j] = [_visible[cont++] integerValue];
        }
        
    }    
}

-(NSString *) serializeMines
{
    NSString *minesString = @"";
    for (int i = 0; i < num_mines ; i++)
    {
        minesString = [minesString  stringByAppendingString: [NSString stringWithFormat: @"%d;",mines[i]]];
    }
    return minesString;
}

-(void) deSerializeMines: (NSString *) minesString
{
    NSArray* _mines = [minesString  componentsSeparatedByString:@";"];
    int cont = 0;
    
    for (int i = 0; i < num_mines ; i++)
    {
        self.mines[i] = [_mines[cont++] integerValue];
    }
}

-(void) initBoard
{
    for (int f=0;f < num_rows;f++)
    {
        self.board[f] = board[0] + f * num_columns;
        for (int c=0;c < num_columns;c++)
        {
            self.board[f][c] = 0;
        }
    }
}

-(void) initGame
{
    [self initBoard];
    for (int f=0;f < num_rows;f++)
    {
      
        self.visible[f] = visible[0] + f * num_columns;
        for (int c=0;c < num_columns;c++)
        {
            self.visible[f][c] = 0;
        }
    }

    //Sets the mines on the board
    for (int mine=0;mine < num_mines;mine++){
        //finds a random postion where there is not a mine
        int r,c;
        do{
            r=(int)(arc4random() % num_rows);
            c=(int)(arc4random() % num_columns);
        }while(self.board[r][c] == 9);
        //sets the mine
        self.board[r][c]=9;
        self.mines[mine] = r*CONSTANT_ROW + c + CONSTANT_ROW;
 
        [self calculateMineDistances: r : c ];
    }
}

-(void) calculateMineDistances: (int) row : (int) column
{
    //goes around the mine and increases the counters
    for (int r2=MAX(0, row-1);r2 < MIN(num_rows,row+2);r2++)
    {
        for (int c2=MAX(0,column-1);c2 < MIN(num_columns,column+2);c2++)
        {
            if (board[r2][c2]!=9)
            {   //if not a mine
                self.board[r2][c2]++; //increases the counter
            }
        }
    }
}

-(void) restoreBoard
{
    int *r;
    int *c;
    r = malloc(4);
    c = malloc(4);
    [self initBoard];
    for (int i =0; i < num_mines; i++ )
    {
    
        [self findCoordinates: mines[i] row: r column: c];
        board[*r][*c] = 9;
        [self calculateMineDistances :*r :*c];
        if (visible [*r][*c] > 0)
        {
            remainingMines--;
        }
    }
}

-(void) findCoordinates: (int) position row : (int *) row column: (int  *)  column
{
    position = position - CONSTANT_ROW;
    *column = position % CONSTANT_ROW;
    *row =  (position - *column) / CONSTANT_ROW;
}

@end
