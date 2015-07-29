//
//  DBManager.m
//  DBTest
//
//  Created by admin on 24/04/13.
//  Copyright (c) 2013 Jlaguna. All rights reserved.
//

#import "DBManager.h"
#import "sqlite3.h"
#import "AppDelegate.h"
#import "VersusGame.h"

@implementation DBManager

sqlite3 *dataBase;

int DATABASE_VERSION = 1;

/** DATABASE_TABLE_VERSUS  **/
NSString *DATABASE_TABLE_VERSUS = @"VERSUS_GAME";

/** DATABASE_TABLE_VERSUS  **/
NSString *DATABASE_CREATE_VERSUS;


/** TAG NSString to distinguish database */
NSString *TAG = @"bm2_Database";

/** TABLE GENERAL FIELDS **/
NSString *ID = @"ID";
NSString *NAME_P1 = @"NAME_P1";
NSString *VISIBLE = @"VISIBLE";
NSString *MINES = @"MINES";
NSString *NUM_ROWS = @"NUM_ROWS";
NSString *NUM_COLUMNS = @"NUM_COLUMNS";
NSString *NUM_MINES = @"NUM_MINES";
NSString *LAST_PLAYED_CELL_P1 = @"LAST_PLAYED_CELL_P1";
NSString *VICTORY = @"VICTORY";
NSString *PLAYER = @"PLAYER";
NSString *DATE = @"DATE";


/** TABLE VERSUS_GAME FIELDS **/
NSString *NAME_P2 = @"NAME_P2";
NSString *LAST_PLAYED_CELL_P2 = @"LAST_PLAYED_CELL_P2";


-(id) init
{
    
        
    DATABASE_CREATE_VERSUS = [[[[[[[[[[[[[[NSString stringWithFormat: @"CREATE TABLE %@ ( ",DATABASE_TABLE_VERSUS ]
    stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER PRIMARY KEY,",ID] ]
    stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER,",NUM_MINES] ]
    stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER,",NUM_ROWS] ]
    stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER,",NUM_COLUMNS] ]
    stringByAppendingString: [NSString stringWithFormat: @"%@ TEXT NOT NULL,",VISIBLE] ]    
    stringByAppendingString: [NSString stringWithFormat: @"%@ TEXT NOT NULL,",MINES] ]
    stringByAppendingString: [NSString stringWithFormat: @"%@ TEXT NOT NULL,",NAME_P1] ]
    stringByAppendingString: [NSString stringWithFormat: @"%@ TEXT NOT NULL,",NAME_P2] ]
    stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER,",LAST_PLAYED_CELL_P1] ]
    stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER,",LAST_PLAYED_CELL_P2] ]
    stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER,",PLAYER] ]
    stringByAppendingString: [NSString stringWithFormat: @"%@ TEXT,",DATE] ]
    stringByAppendingString: [NSString stringWithFormat: @"%@ INTEGER)",VICTORY] ];

    return self;
}

-(BOOL) open
{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    @try
    {
        if (sqlite3_open([appDelegate.dataBasePath UTF8String], &dataBase) == SQLITE_OK)
            return YES;
        else
        {
            return NO;
            NSLog(@"DB Could not open");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR opening DB: %@",exception);
    }
}

-(void) close
{
    @try
    {
        sqlite3_close(dataBase);
    }
    @catch (NSException *exception) {
        NSLog(@"ERROR closing DB: %@",exception);
    }
}

-(void) createsDB
{
    
    @try {
        if ([self open])
        {
            NSLog(@"%@",DATABASE_CREATE_VERSUS);
            [self executeSimpleSentence:DATABASE_CREATE_VERSUS];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"first_time"];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        [self close];
    }
}

/* Prepares a SQL statement */
-(sqlite3_stmt *) prepareSentence: (NSString *) SQLSentence
{
    sqlite3_stmt * sentence;
    int result = sqlite3_prepare_v2(dataBase, [SQLSentence UTF8String], -1,&sentence, NULL);
    if (result != SQLITE_OK && result != SQLITE_ROW)
    {
        @try
        {
            NSAssert1(0, @"Error executing query: '%s'", sqlite3_errmsg(dataBase));
            NSLog(@"%@",SQLSentence);
        }
        @catch (NSException *exception)
        {
            NSLog(@"%@",exception);
            NSLog(@"Error executing query, code: %i",sqlite3_errcode(dataBase));
        }
    }
    return sentence;
}

/* Executes a prepared statement */
-(void) executeSentence: (sqlite3_stmt *) sentence
{
    if (sqlite3_step(sentence) != SQLITE_DONE)
    {
        @try
        {
            NSAssert1(0, @"Error executing query: '%s'", sqlite3_errmsg(dataBase));
        }
        @catch (NSException *exception)
        {
          NSLog(@"%@",exception);
          NSLog(@"Error executing query, code: %i",sqlite3_errcode(dataBase));
        }

    }
    sqlite3_finalize(sentence);
    
}

/* Executes ands prepares a SQL statement */
-(void)  executeSimpleSentence: (NSString *) SQLSentence
{
    sqlite3_stmt * sentence = [self prepareSentence:SQLSentence];
    [self executeSentence:sentence];
}


-(void) upgrade: (int) oldVersion newVersion:(int) newVersion
{
   NSLog(@"Upgrading database from version %d to %d, which will destroy all old data",oldVersion,newVersion);
    @try
    {
        
        [self open];
        // drop sentence
        [self executeSimpleSentence: [@"DROP TABLE IF EXISTS " stringByAppendingString: DATABASE_TABLE_VERSUS]];
    
        [self createsDB];
    }
    @catch (NSException *exception) {
        NSLog(@"Error upgrading the DB");
    }
    @finally {
        [self close];
    }

}

/**
 * ------------------------------------------------------------------------
 * ------------ TABLE VERSUS_GAME
 * ------------------------------------------------
 * -------------------------------------
 */

/**
 * Inserts new Versus_game.
 * @param VersusGame
 */

-(void) createVersusGame:(VersusGame *) versusGame
{
    NSString * sentence =  [[@"INSERT INTO " stringByAppendingString:DATABASE_TABLE_VERSUS]
                stringByAppendingString: @" (%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)"];
    @try
    {
        
        [self open];
        sentence = [NSString stringWithFormat: sentence,NUM_MINES,NUM_ROWS,NUM_COLUMNS
                    ,VISIBLE,MINES,NAME_P1,NAME_P2,LAST_PLAYED_CELL_P1,LAST_PLAYED_CELL_P2,PLAYER,DATE,VICTORY];
        sqlite3_stmt * sql = [self prepareSentence:sentence];
    
        int i = 1;
        sqlite3_bind_int(sql, i++, versusGame.num_mines);
        sqlite3_bind_int(sql, i++, versusGame.num_rows);
        sqlite3_bind_int(sql, i++, versusGame.num_columns);
        sqlite3_bind_text(sql, i++, [[versusGame serializeVisible] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(sql, i++, [[versusGame serializeMines] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(sql, i++, [versusGame.player1_username UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(sql, i++, [versusGame.player2_username UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(sql, i++, versusGame.last_cell_player1);
        sqlite3_bind_int(sql, i++, versusGame.last_cell_player2);
        sqlite3_bind_int(sql, i++, versusGame.player);
        sqlite3_bind_text(sql, i++, [versusGame.date_last_played UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(sql, i++, versusGame.victory);
    
        [self executeSentence:sql];
    }
    @catch (NSException *exception) {
        NSLog(@"Error creating Versus Game");
    }
    @finally {
        [self close];
    }

}

/**
 * Get Restorable Versus Games
 *@return NSMutableArray 
*/

-(NSMutableArray *)  getRestorableVersusGame
{
    NSMutableArray *games = [[NSMutableArray alloc] init];
    int count = 1;
    NSString *selectGame = [NSString stringWithFormat:
    @"SELECT * FROM %@ WHERE %@ = 0 ORDER BY %@ DESC",DATABASE_TABLE_VERSUS, VICTORY,ID ];
    @try
    {
        if ([self open])
        {
            sqlite3_stmt * sentence = [self prepareSentence: selectGame];
            
            while ( sqlite3_step(sentence) == SQLITE_ROW )//|| sqlite3_step(sentence) == SQLITE_DONE )
            {
                if (count > RESTORABLE_GAMES)
                    break;
                
                VersusGame * game = [[VersusGame alloc] init];
                int i = 0;
                int gid = sqlite3_column_int(sentence, i++);
                [game setNum_mines:sqlite3_column_int(sentence, i++)];
                [game setNum_rows:sqlite3_column_int(sentence, i++)];
                [game setNum_columns:sqlite3_column_int(sentence, i++)];
                game = [game initWithNumMines:[game num_mines] numColumns:[game num_columns] numRows:[game num_rows]];
                [game setGame_internal_id:gid];
                [game deSerializeVisible:[NSString stringWithUTF8String:(char*) sqlite3_column_text(sentence, i++)]];
                [game deSerializeMines:[NSString stringWithUTF8String:(char*) sqlite3_column_text(sentence, i++)]];
                [game setPlayer1_username:[NSString stringWithUTF8String:(char*) sqlite3_column_text(sentence, i++)]];
                [game setPlayer2_username:[NSString stringWithUTF8String:(char*) sqlite3_column_text(sentence, i++)]];
                [game setLast_cell_player1:sqlite3_column_int(sentence, i++)];
                [game setLast_cell_player2:sqlite3_column_int(sentence, i++)];
                [game setPlayer:sqlite3_column_int(sentence, i++)];
                [game setDate_last_played:[NSString stringWithUTF8String:(char*) sqlite3_column_text(sentence, i++)]];
                [game setVictory:sqlite3_column_int(sentence, i++)];
                
                [games addObject:game];
                count++;
            }
            int result = sqlite3_errcode(dataBase);
            sqlite3_finalize(sentence);
            
            if (result == SQLITE_ROW)
            {
                [self close];
                [self cleanRestorableVersusGames];
            }
            else
                if (result != SQLITE_DONE)
                    NSLog(@"Result code: %i",sqlite3_errcode(dataBase));
       }
    }
    @catch (NSException *exception) {
        NSLog(@"Error getting restorable Versus Game from DB");
    }
    @finally {
        [self close];
    }
    return games;
}

/**
 * Get Latest Versus Game
 *@return int
 */

-(int)  getLatestVersusGame
{
    int gid = -1;
    NSString *selectGame = [NSString stringWithFormat: @"SELECT MAX(%@) FROM %@ WHERE %@ IS 0",ID,DATABASE_TABLE_VERSUS, VICTORY ];
    @try
    {
        if ([self open])
        {
            sqlite3_stmt * sentence = [self prepareSentence: selectGame];
            if ( sqlite3_step(sentence) == SQLITE_ROW )
            {
                gid = sqlite3_column_int(sentence, 0);
            }
            else
                if(sqlite3_errcode(dataBase) != SQLITE_DONE)
                    NSLog(@"Result code: %i",sqlite3_errcode(dataBase));
            sqlite3_finalize(sentence);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error getting restorable Versus Game from DB");
    }
    @finally {
        [self close];
    }
    return gid;
}


/**
 * Update Versus Game. If updated returns true.
 *
 * @param rowId
 * @param name
 * @param pay
 * @return
 */

- (void) updateVersusGame: (VersusGame *) game
{
    NSString * sentence =  [[[[[[[@"UPDATE " stringByAppendingString:DATABASE_TABLE_VERSUS]
                            stringByAppendingString: @" SET %@ = ?," ]
                            stringByAppendingString: @" %@ = ?," ]
                            stringByAppendingString: @" %@ = ?," ]
                            stringByAppendingString: @" %@ = ?," ]
                            stringByAppendingString: @" %@ = ?," ]
                            stringByAppendingString: @" %@ = ? WHERE %@ = %d" ];
    
    @try
    {
        [self open];
        sentence = [NSString stringWithFormat: sentence,VISIBLE,LAST_PLAYED_CELL_P1,
                    LAST_PLAYED_CELL_P2,PLAYER,DATE,VICTORY,ID,game.game_internal_id ];
        sqlite3_stmt * sql = [self prepareSentence:sentence];
    
        int i = 1;
        sqlite3_bind_text(sql, i++, [[game serializeVisible] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(sql, i++, game.last_cell_player1);
        sqlite3_bind_int(sql, i++, game.last_cell_player2);
        sqlite3_bind_int(sql, i++, game.player);
        sqlite3_bind_text(sql, i++, [game.date_last_played  UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(sql, i++, game.victory);
        [self executeSentence:sql];
    }
    @catch (NSException *exception) {
        NSLog(@"Error Updating Versus Game");
    }
    @finally {
        [self close];
    }
}

-(NSMutableArray *) getCleaneableRestorableVersusGames
{
    NSMutableArray *deletingGames = [[NSMutableArray alloc]init];
    NSString *selectGame = [NSString stringWithFormat:
          @"SELECT %@ FROM %@ WHERE %@ = 0 ORDER BY %@ DESC",ID,DATABASE_TABLE_VERSUS, VICTORY,DATE ];
    int count = 0;
    @try
    {
        if ([self open])
        {
            sqlite3_stmt * sentence = [self prepareSentence: selectGame];
            while ( sqlite3_step(sentence) == SQLITE_ROW )
            {
                int gid = sqlite3_column_int(sentence, 0);
                count++;
                if (count > RESTORABLE_GAMES)
                    [deletingGames addObject: [[NSNumber alloc] initWithInt: gid]];
            }
            int result = sqlite3_errcode(dataBase);
            sqlite3_finalize(sentence);
            
            if (result != SQLITE_DONE)
                NSLog(@"Result code: %i",sqlite3_errcode(dataBase));
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error getting cleanable restorable Versus Game from DB");
    }
    @finally {
        [self close];
    }
    return deletingGames;
}

-(void) cleanRestorableVersusGames
{
    NSMutableArray *deletingGames = [[NSMutableArray alloc]init];
    @try
    {
        deletingGames = [self getCleaneableRestorableVersusGames];
        for (int i = 0; i< [deletingGames count];i++)
        {
            [self deleteVersusGame: [deletingGames[i] intValue] ];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error cleaning restorable Versus Game from DB");
    }

}

-(void) deleteVersusGame: (int) gameId
{
    NSString *selectGame = [NSString stringWithFormat:
                            @"DELETE FROM %@ WHERE %@ = 0 AND %@ = %d",DATABASE_TABLE_VERSUS,VICTORY,ID,gameId ];
    @try {
        if ([self open])
        {
            sqlite3_stmt * sql = [self prepareSentence:selectGame];
            [self executeSentence:sql];
        }
    }
    @catch (NSException *exception) {
       NSLog(@"Error deleting restorable Versus Game from DB");
    }
    @finally {
        [self close];

    }
    
}

@end
