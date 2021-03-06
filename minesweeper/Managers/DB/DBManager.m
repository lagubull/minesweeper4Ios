//
//  DBManager.m
//  minesweeper
//
//  Created by jlagunas on 24/04/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "DBManager.h"
#import "sqlite3.h"
#import "AppDelegate.h"
#import "VersusGame.h"


/**
 Maximum number of unfinised games that can be restarted
 */
const NSInteger kJMSRestorableGames = 10;

/**
 TAG NSString to distinguish database
 */
static NSString * const kJMSTag = @"bm2_Database";


static NSString * const kJMSDatabaseTableVersus = @"VERSUS_GAME";

#pragma mark - TABLE GENERAL FIELDS

static NSString * const kJMSID = @"ID";
static NSString * const kJMSNameP1 = @"NAME_P1";
static NSString * const kJMSVisible = @"VISIBLE";
static NSString * const kJMSMines = @"MINES";
static NSString * const kJMSRowsNumber = @"NUM_ROWS";
static NSString * const kJMSColumnsNumber = @"NUM_COLUMNS";
static NSString * const kJMSMineNumber = @"NUM_MINES";
static NSString * const kJMSLastPlayedCellPlayer1 = @"LAST_PLAYED_CELL_P1";
static NSString * const kJMSVictory = @"VICTORY";
static NSString * const kJMSPlayer = @"PLAYER";
static NSString * const kJMSDate = @"DATE";

#pragma mark - TABLE VERSUS_GAME FIELDS

static NSString *kJMSPlayer2Name = @"NAME_P2";
static NSString *kJMSLastPlayedCellPlayer2 = @"LAST_PLAYED_CELL_P2";

@interface DBManager ()

@property (nonatomic,strong) NSString *databaseCreateVersus;

/**
 Opens the DB
 */
- (BOOL)open;

/**
 Closes the DB
 */
- (void)close;

/**
 Prepares a SQL statement
 
 @param string with the sentece to be prepared
 */
- (sqlite3_stmt *)prepareSentence:(NSString *)SQLSentence;

/**
 Executes a prepared statement
 
 @param sentece to be excuted
 */
- (void)executeSentence:(sqlite3_stmt *)sentence;

/**
 Executes ands prepares a SQL statement
 
 @param: SQL sentece to be executed
 */
- (void)executeSimpleSentence:(NSString *)SQLSentence;

/**
 fetches the games that are not finshed yet and are old enough to be deleted
 
 @return unfinihsed games that can be deleted
 */
- (NSMutableArray *)getCleaneableRestorableVersusGames;

/**
 Deletes old unfinished games
 */
- (void)cleanRestorableVersusGames;

/**
 Deletes one versusGame
 
 @param id of the game to be deleted
 */
- (void)deleteVersusGame:(NSInteger)gameId;

@end

@implementation DBManager

static sqlite3 *dataBase;

#pragma mark - Getters

- (NSString *)databaseCreateVersus
{
    if (!_databaseCreateVersus)
    {
        _databaseCreateVersus = [[[[[[[[[[[[[[NSString stringWithFormat: @"CREATE TABLE %@ ( ",kJMSDatabaseTableVersus ]
                                             stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER PRIMARY KEY,",kJMSID] ]
                                            stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER,",kJMSMineNumber] ]
                                           stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER,",kJMSRowsNumber] ]
                                          stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER,",kJMSColumnsNumber] ]
                                         stringByAppendingString: [NSString stringWithFormat: @"%@ TEXT NOT NULL,",kJMSVisible] ]
                                        stringByAppendingString: [NSString stringWithFormat: @"%@ TEXT NOT NULL,",kJMSMines] ]
                                       stringByAppendingString: [NSString stringWithFormat: @"%@ TEXT NOT NULL,",kJMSNameP1] ]
                                      stringByAppendingString: [NSString stringWithFormat: @"%@ TEXT NOT NULL,",kJMSPlayer2Name] ]
                                     stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER,",kJMSLastPlayedCellPlayer1] ]
                                    stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER,",kJMSLastPlayedCellPlayer2] ]
                                   stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER,",kJMSPlayer] ]
                                  stringByAppendingString: [NSString stringWithFormat: @"%@ TEXT,",kJMSDate] ]
                                 stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER)",kJMSVictory] ];
    }
    
    return _databaseCreateVersus;
}

#pragma mark - Open

- (BOOL)open
{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    BOOL couldOpenDB = YES;
    
    @try
    {
        if (!sqlite3_open([appDelegate.dataBasePath UTF8String], &dataBase) == SQLITE_OK)
        {
            couldOpenDB = NO;
            DLog(@"DB Could not open");
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"ERROR opening DB: %@", exception);
    }
    @finally
    {
        return couldOpenDB;
    }
}

#pragma mark - Close

- (void)close
{
    @try
    {
        sqlite3_close(dataBase);
    }
    @catch (NSException *exception)
    {
        NSLog(@"ERROR closing DB: %@", exception);
    }
}

#pragma mark - CreatesDB

- (void)createDB
{
    @try
    {
        if ([self open])
        {
            DLog(@"%@",self.databaseCreateVersus);
            [self executeSimpleSentence:self.databaseCreateVersus];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            [userDefaults setBool:YES
                           forKey:@"first_time"];
            
            [userDefaults synchronize];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@", exception);
    }
    @finally
    {
        [self close];
    }
}

#pragma mark - PrepareSentence

- (sqlite3_stmt *)prepareSentence:(NSString *)SQLSentence
{
    sqlite3_stmt * sentence;
    int result = sqlite3_prepare_v2(dataBase,
                                    [SQLSentence UTF8String],
                                    -1,
                                    &sentence,
                                    NULL);
    
    if (result != SQLITE_OK &&
        result != SQLITE_ROW)
    {
        @try
        {
            NSAssert1(0, @"Error executing query: '%s'", sqlite3_errmsg(dataBase));
            DLog(@"%@", SQLSentence);
        }
        @catch (NSException *exception)
        {
            NSLog(@"%@", exception);
            DLog(@"Error executing query, code: %i", sqlite3_errcode(dataBase));
        }
    }
    
    return sentence;
}

#pragma mark - ExecuteSentence

- (void)executeSentence:(sqlite3_stmt *)sentence
{
    if (sqlite3_step(sentence) != SQLITE_DONE)
    {
        @try
        {
            NSAssert1(0, @"Error executing query: '%s'", sqlite3_errmsg(dataBase));
        }
        @catch (NSException *exception)
        {
            NSLog(@"%@", exception);
            DLog(@"Error executing query, code: %i", sqlite3_errcode(dataBase));
        }
    }
    
    sqlite3_finalize(sentence);
}

- (void)executeSimpleSentence:(NSString *)SQLSentence
{
    sqlite3_stmt * sentence = [self prepareSentence:SQLSentence];
    [self executeSentence:sentence];
}

- (void)upgrade:(NSNumber *)oldVersion
     newVersion:(NSNumber *)newVersion
{
    DLog(@"Upgrading database from version %@ to %@, which will destroy all old data" , oldVersion, newVersion);
    
    @try
    {
        [self open];
        // drop sentence
        [self executeSimpleSentence:[@"DROP TABLE IF EXISTS " stringByAppendingString:kJMSDatabaseTableVersus]];
        
        [self createDB];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error upgrading the DB");
    }
    @finally
    {
        [self close];
    }
}

#pragma mark - VersusGame

- (void)createVersusGame:(VersusGame *)versusGame
{
    NSString * sentence =  [[@"INSERT INTO " stringByAppendingString:kJMSDatabaseTableVersus]
                            stringByAppendingString: @" (%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)"];
    @try
    {
        [self open];
        
        sentence = [NSString stringWithFormat:sentence, kJMSMineNumber, kJMSRowsNumber, kJMSColumnsNumber
                    , kJMSVisible, kJMSMines, kJMSNameP1, kJMSPlayer2Name, kJMSLastPlayedCellPlayer1, kJMSLastPlayedCellPlayer2, kJMSPlayer, kJMSDate, kJMSVictory];
        
        sqlite3_stmt * sql = [self prepareSentence:sentence];
        
        int i = 1;
        
        sqlite3_bind_int(sql, i++, (int)versusGame.minesNumber);
        sqlite3_bind_int(sql, i++, (int)versusGame.rowsNumber);
        sqlite3_bind_int(sql, i++, (int)versusGame.columnsNumber);
        sqlite3_bind_text(sql, i++, [[versusGame serializeVisible] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(sql, i++, [[versusGame serializeMines] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(sql, i++, [versusGame.player1Username UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(sql, i++, [versusGame.player2Username UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(sql, i++, (int)versusGame.lastCellPlayer1);
        sqlite3_bind_int(sql, i++, (int)versusGame.lastCellPlayer2);
        sqlite3_bind_int(sql, i++, (int)versusGame.player);
        sqlite3_bind_text(sql, i++, [versusGame.dateLastPlayed UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(sql, i++, (int)versusGame.victory);
        
        [self executeSentence:sql];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error creating Versus Game");
    }
    @finally
    {
        [self close];
    }
}

- (NSMutableArray *)getRestorableVersusGame
{
    NSMutableArray *games = [[NSMutableArray alloc] init];
    NSInteger count = 1;
    NSString *selectGame = [NSString stringWithFormat:
                            @"SELECT * FROM %@ WHERE %@ = 0 ORDER BY %@ DESC", kJMSDatabaseTableVersus, kJMSVictory, kJMSID];
    
    @try
    {
        if ([self open])
        {
            sqlite3_stmt * sentence = [self prepareSentence:selectGame];
            
            while (sqlite3_step(sentence) == SQLITE_ROW)
            {
                if (count > kJMSRestorableGames)
                {
                    break;
                }
                
                VersusGame * game = [[VersusGame alloc] init];
                int i = 0;
                NSInteger gameId = sqlite3_column_int(sentence, i++);
                
                NSInteger numMines = sqlite3_column_int(sentence, i++);
                NSInteger numRows = sqlite3_column_int(sentence, i++);
                NSInteger numColumns = sqlite3_column_int(sentence, i++);
                
                game = [game initWithNumMines:numMines
                                   numColumns:numColumns
                                      numRows:numRows];
                
                game.gameInternalId = gameId;
                [game deSerializeVisible:[NSString stringWithUTF8String:(char*) sqlite3_column_text(sentence, i++)]];
                [game deSerializeMines:[NSString stringWithUTF8String:(char*) sqlite3_column_text(sentence, i++)]];
                [game setPlayer1Username:[NSString stringWithUTF8String:(char*) sqlite3_column_text(sentence, i++)]];
                [game setPlayer2Username:[NSString stringWithUTF8String:(char*) sqlite3_column_text(sentence, i++)]];
                [game setLastCellPlayer1:sqlite3_column_int(sentence, i++)];
                [game setLastCellPlayer2:sqlite3_column_int(sentence, i++)];
                [game setPlayer:sqlite3_column_int(sentence, i++)];
                [game setDateLastPlayed:[NSString stringWithUTF8String:(char*) sqlite3_column_text(sentence, i++)]];
                [game setVictory:sqlite3_column_int(sentence, i++)];
                
                [games addObject:game];
                
                count++;
            }
            
            NSInteger result = sqlite3_errcode(dataBase);
            sqlite3_finalize(sentence);
            
            if (result == SQLITE_ROW)
            {
                [self close];
                [self cleanRestorableVersusGames];
            }
            else if (result != SQLITE_DONE)
            {
                DLog(@"Result code: %i", sqlite3_errcode(dataBase));
            }
            
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error getting restorable Versus Game from DB");
    }
    @finally
    {
        [self close];
    }
    
    return games;
}

- (NSInteger)getLatestVersusGame
{
    NSInteger latestVersusGameId = -1;
    NSString *selectGame = [NSString stringWithFormat: @"SELECT MAX(%@) FROM %@ WHERE %@ IS 0", kJMSID,kJMSDatabaseTableVersus, kJMSVictory];
    
    @try
    {
        if ([self open])
        {
            sqlite3_stmt * sentence = [self prepareSentence:selectGame];
            
            if (sqlite3_step(sentence) == SQLITE_ROW)
            {
                latestVersusGameId = sqlite3_column_int(sentence, 0);
            }
            else if(sqlite3_errcode(dataBase) != SQLITE_DONE)
            {
                DLog(@"Result code: %i", sqlite3_errcode(dataBase));
            }
            
            sqlite3_finalize(sentence);
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error getting restorable Versus Game from DB");
    }
    @finally
    {
        [self close];
    }
    
    return latestVersusGameId;
}

- (void)updateVersusGame:(VersusGame *)game
{
    NSString * sentence =  [[[[[[[@"UPDATE " stringByAppendingString:kJMSDatabaseTableVersus]
                                 stringByAppendingString: @" SET %@ = ?," ]
                                stringByAppendingString: @" %@ = ?," ]
                               stringByAppendingString: @" %@ = ?," ]
                              stringByAppendingString: @" %@ = ?," ]
                             stringByAppendingString: @" %@ = ?," ]
                            stringByAppendingString: @" %@ = ? WHERE %@ = %d" ];
    
    @try
    {
        [self open];
        
        sentence = [NSString stringWithFormat:sentence, kJMSVisible, kJMSLastPlayedCellPlayer1,
                    kJMSLastPlayedCellPlayer2, kJMSPlayer, kJMSDate, kJMSVictory, kJMSID, game.gameInternalId];
        
        sqlite3_stmt * sql = [self prepareSentence:sentence];
        
        int i = 1;
        
        sqlite3_bind_text(sql, i++, [[game serializeVisible] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(sql, i++, (int)game.lastCellPlayer1);
        sqlite3_bind_int(sql, i++, (int)game.lastCellPlayer2);
        sqlite3_bind_int(sql, i++, (int)game.player);
        sqlite3_bind_text(sql, i++, [game.dateLastPlayed  UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(sql, i++, (int)game.victory);
        
        [self executeSentence:sql];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error Updating Versus Game");
    }
    @finally
    {
        [self close];
    }
}

- (NSMutableArray *)getCleaneableRestorableVersusGames
{
    NSMutableArray *deletingGames = [[NSMutableArray alloc] init];
    
    NSString *selectGame = [NSString stringWithFormat:
                            @"SELECT %@ FROM %@ WHERE %@ = 0 ORDER BY %@ DESC", kJMSID, kJMSDatabaseTableVersus, kJMSVictory, kJMSDate];
    int count = 0;
    
    @try
    {
        if ([self open])
        {
            sqlite3_stmt * sentence = [self prepareSentence:selectGame];
            
            while (sqlite3_step(sentence) == SQLITE_ROW)
            {
                int gid = sqlite3_column_int(sentence, 0);
                count++;
                
                if (count > kJMSRestorableGames)
                {
                    [deletingGames addObject:[[NSNumber alloc] initWithInt:gid]];
                }
            }
            
            int result = sqlite3_errcode(dataBase);
            sqlite3_finalize(sentence);
            
            if (result != SQLITE_DONE)
            {
                DLog(@"Result code: %i", sqlite3_errcode(dataBase));
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error getting cleanable restorable Versus Game from DB");
    }
    @finally
    {
        [self close];
    }
    
    return deletingGames;
}

- (void)cleanRestorableVersusGames
{
    NSMutableArray *deletingGames = [[NSMutableArray alloc] init];
    
    @try
    {
        deletingGames = [self getCleaneableRestorableVersusGames];
        
        for (int i = 0; i < [deletingGames count]; i++)
        {
            [self deleteVersusGame:[deletingGames[i] intValue]];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error cleaning restorable Versus Game from DB");
    }
}

- (void)deleteVersusGame:(NSInteger)gameId
{
    NSString *selectGame = [NSString stringWithFormat:
                            @"DELETE FROM %@ WHERE %@ = 0 AND %@ = %@", kJMSDatabaseTableVersus, kJMSVictory, kJMSID, @(gameId)];
    
    @try
    {
        if ([self open])
        {
            sqlite3_stmt * sql = [self prepareSentence:selectGame];
            [self executeSentence:sql];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Error deleting restorable Versus Game from DB");
    }
    @finally
    {
        [self close];
        
    }
}

@end
