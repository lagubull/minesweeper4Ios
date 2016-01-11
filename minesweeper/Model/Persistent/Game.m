//
//  Game.m
//
//  Created by jlagunas on 09/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "Game.h"

#import "Tools.h"
#import "DBManager.h"

/**
 Constant to add to the cells tag
 */
const NSInteger kJMSRow = 1000;

@implementation Game

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL first_time = [defaults boolForKey:@"first_time"];
        
        self.manager = [[DBManager alloc] init];
        
        if (!first_time)
        {
            [self.manager upgrade:[[NSNumber alloc] initWithInteger:0]
                       newVersion:[[NSNumber alloc] initWithInteger:1]];
        }
        
        self.gameInternalId = -1;
    }
    
    return self;
}

- (instancetype)initWithNumMines:(NSInteger)numMines
                     numColumns:(NSInteger)numColumns
                        numRows:(NSInteger)numRows
{
    self = [self  init];
    
    if (self)
    {
        self.columnsNumber = numColumns;
        self.rowsNumber = numRows;
        self.minesNumber = numMines;
        self.lastCellPlayer1 = -1;
        self.player1Username = @"Player 1";
        self.victory = 0;
        self.remainingMines = self.minesNumber;
        self.dateLastPlayed = [Tools date2String:[NSDate date]];
        
        self.board = (NSInteger **)calloc(self.rowsNumber,
                                    sizeof(NSInteger *));
        
        self.visible = (NSInteger **)calloc(self.rowsNumber,
                                      sizeof(NSInteger *));
        
        self.mines = (NSInteger *)calloc(self.minesNumber,
                                   sizeof(NSInteger *));
        
        self.board[0] = (NSInteger *)calloc((self.rowsNumber * self.columnsNumber),
                                      sizeof(NSInteger *));
        
        self.visible[0] = (NSInteger *)calloc((self.rowsNumber * self.columnsNumber),
                                        sizeof(NSInteger *));
    }
    
    return self;
}


#pragma mark - Setup

- (void)setupBoard
{
    for (int row = 0; row < self.rowsNumber; row++)
    {
        self.board[row] = self.board[0] + row * self.columnsNumber;
        
        for (int column = 0; column < self.columnsNumber; column++)
        {
            self.board[row][column] = 0;
        }
    }
}

- (void)setupGame
{
    [self setupBoard];
    
    for (int row = 0; row < self.rowsNumber; row++)
    {
        self.visible[row] = self.visible[0] + row * self.columnsNumber;
        
        for (int column = 0; column < self.columnsNumber; column++)
        {
            self.visible[row][column] = 0;
        }
    }
    
    //Sets the mines on the board
    for (NSInteger mine = 0; mine < self.minesNumber; mine++)
    {
        //finds a random postion where there is not a mine
        NSInteger row, column;
        
        do
        {
            row = (int)(arc4random() % self.rowsNumber);
            column = (int)(arc4random() % self.columnsNumber);
        }
        while(self.board[row][column] == 9);
        
        //sets the mine
        self.board[row][column] = 9;
        self.mines[mine] = (int)(row  * kJMSRow + column + kJMSRow);
        
        [self calculateMineDistances:row
                              column:column];
    }
}

#pragma mark - CalculateMineDistances

- (void)calculateMineDistances:(NSInteger)row
                        column:(NSInteger)column
{
    //goes around the mine and increases the counters
    for (NSInteger row2 = MAX (0, (row - 1)); row2 < MIN (self.rowsNumber, (row + 2)); row2++)
    {
        for (NSInteger column2 = MAX (0, (column - 1)); column2 < MIN (self.columnsNumber, (column + 2)); column2++)
        {
            if (self.board[row2][column2] != 9)
            {
                //if not a mine
                self.board[row2][column2]++; //increases the counter
            }
        }
    }
}

#pragma mark - RestoreBoard

- (void)restoreBoard
{
    NSInteger *row;
    NSInteger *column;
    row = malloc(4);
    column = malloc(4);
    
    [self setupBoard];
    
    for (NSInteger i = 0; i < self.minesNumber; i++ )
    {
        [self findCoordinatesWithPosition:self.mines[i]
                          row:row
                       column:column];
        
        self.board[*row][*column] = 9;
        
        [self calculateMineDistances:*row
                              column:*column];
        
        if (self.visible [*row][*column] > 0)
        {
            self.remainingMines = self.remainingMines - 1;
        }
    }
}

#pragma mark - Serialization

- (NSString *)serializeMines
{
    NSString *minesString = @"";
    
    for (int i = 0; i < self.minesNumber; i++)
    {
        minesString = [minesString  stringByAppendingString:[NSString stringWithFormat:@"%@;",@(self.mines[i])]];
    }
    
    return minesString;
}

- (NSString *)serializeVisible
{
    NSString *visibleString = @"";
    
    for (NSInteger i = 0; i < self.rowsNumber; i++)
    {
        for (NSInteger j = 0; j < self.columnsNumber; j++)
        {
            visibleString = [visibleString  stringByAppendingString:[NSString stringWithFormat:@"%@;", @(self.visible[i][j])]];
        }
        
    }
    
    return visibleString;
}

- (void)deSerializeVisible:(NSString *)visibleString
{
    NSArray* visible = [visibleString  componentsSeparatedByString:@";"];
    
    int cont = 0;
    
    for (int i = 0; i < self.rowsNumber; i++)
    {
        self.visible[i] = self.visible[0] + i * self.columnsNumber;
        
        for (int j = 0; j < self.columnsNumber; j++)
        {
            self.visible[i][j] = [visible[cont++] intValue];
        }
    }
}

- (void)deSerializeMines:(NSString *)minesString
{
    NSArray* mines = [minesString componentsSeparatedByString:@";"];
    int cont = 0;
    
    for (int i = 0; i < self.minesNumber ; i++)
    {
        self.mines[i] = [mines[cont++] intValue];
    }
}

#pragma mark - FindCoordinatesWithPosition

- (void)findCoordinatesWithPosition:(NSInteger)position
                    row:(NSInteger *)row
                 column:(NSInteger *)column
{
    position = position - kJMSRow;
    *column = position % kJMSRow;
    *row =  (position - *column) / kJMSRow;
}

#pragma mark - Update

- (void)update
{
    //asbtract
}

#pragma mark - persist

- (void)persist
{
    //abstract
}

@end
