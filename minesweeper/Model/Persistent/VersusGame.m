//
//  VersusGame.m
//  minesweeper
//
//  Created by jlagunas on 09/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "VersusGame.h"

#import "DBManager.h"

@implementation VersusGame

#pragma mark - Init

-(instancetype)initWithNumMines:(NSInteger)numMines
                     numColumns:(NSInteger)numColumns
                        numRows:(NSInteger)numRows
{
    self = [super initWithNumMines:numMines numColumns:numColumns numRows:numRows];
    
    if (self)
    {
        self.lastCellPlayer2 = -1;
        self.player = 1;
        self.player2Username = @"Player 2";
        self.minesPlayer1 = 0;
        self.minesPlayer2 = 0;
    }
    
    return self;
}

#pragma mark - Getters

- (NSMutableArray *)getRestorableGames
{
    return  [self.manager getRestorableVersusGame];
}

#pragma mark - Restore

- (void)restore
{
    [self restoreBoard];
    
    NSInteger *row;
    NSInteger *column;
    row = malloc(4);
    column = malloc(4);
    
    for (NSInteger i = 0; i < self.minesNumber; i++)
    {
        [self findCoordinatesWithPosition:self.mines[i]
                                       row:row
                                   column:column];
        
        if (self.visible [*row][*column] == 1)
        {
            self.minesPlayer1++;
        }
        else if (self.visible [*row][*column] == 2)
        {
            self.minesPlayer2++;
        }
    }
}

#pragma mark - Persist

- (void)persist
{
    [self.manager createVersusGame:self];
    self.gameInternalId = [self.manager getLatestVersusGame];
}

#pragma mark - Update

- (void)update
{
    [self.manager updateVersusGame: self];
}

@end
