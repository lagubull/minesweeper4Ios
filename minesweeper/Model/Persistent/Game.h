//
//  Game.h
//  minesweeper
//
//  Created by jlagunas on 09/05/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

@class DBManager;

extern const NSInteger kJMSRow;

@interface Game : NSObject

@property (nonatomic) NSInteger gameInternalId;

@property (nonatomic) NSInteger rowsNumber;

@property (nonatomic) NSInteger columnsNumber;

@property (nonatomic) NSInteger minesNumber;

@property (nonatomic) NSInteger remainingMines;

@property (nonatomic) NSInteger **visible;

@property (nonatomic) NSInteger **board;

@property (nonatomic) NSInteger *mines;

@property (nonatomic) NSInteger lastCellPlayer1;

@property (nonatomic, strong) NSString *player1Username;

@property (nonatomic) NSInteger victory;

@property (nonatomic, strong) DBManager *manager;

@property (nonatomic, strong) NSString *dateLastPlayed;

-(instancetype)initWithNumMines:(NSInteger)numMines
                     numColumns:(NSInteger)numColumns
                        numRows:(NSInteger)numRows;

- (void)setupGame;

- (void)restoreBoard;

- (void)findCoordinatesWithPosition:(NSInteger)position
                                row:(NSInteger *)row
                             column:(NSInteger *)column;

- (NSString *)serializeVisible;

- (NSString *)serializeMines;

- (void)deSerializeVisible:(NSString *) visibleString;

- (void) deSerializeMines: (NSString *) minesString;

- (void) persist;

- (void) update;

@end
