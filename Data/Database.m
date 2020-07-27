//
//  Database.m
//  Billing
//
//  Created by William Woody on 7/19/20.
//  Copyright © 2020 Glenview Software. All rights reserved.
//

#import "Database.h"
#import "ProjectData.h"
#import "Constants.h"
#import "TimeDataRecord.h"
#import "BillData.h"
#import <sqlite3.h>

@interface Database ()
{
	sqlite3 *sql;
	int version;
	BOOL isInitialized;
	
	NSMutableArray<ProjectData *> *projectData;
	
	NSInteger projectIndexID;		// Project ID that is loaded
	NSMutableArray<TimeDataRecord *> *projectTime;
	
	NSMutableArray<BillData *> *billData;
}

- (int)startCallback:(int)colCount data:(char **)data name:(char **)name;
- (int)versionCallback:(int)colCount data:(char **)data name:(char **)name;
@end

/****************************************************************************/
/*																			*/
/*	Callbacks																*/
/*																			*/
/****************************************************************************/

static int ExecCallback(void *db, int colCount, char **data, char **name)
{
	return [(__bridge Database *)db startCallback:colCount data:data name:name];
}

static int VersionCallback(void *db, int colCount, char **data, char **name)
{
	return [(__bridge Database *)db versionCallback:colCount data:data name:name];
}

/****************************************************************************/
/*																			*/
/*	Class Startup															*/
/*																			*/
/****************************************************************************/

@implementation Database

+ (Database *)shared
{
	static Database *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[Database alloc] init];
	});
	return instance;
}

- (instancetype)init
{
	if (nil != (self = [super init])) {
		sql = NULL;
		
		isInitialized = NO;
		version = 0;
		
		projectData = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	if (sql) sqlite3_close(sql);
}

- (int)startCallback:(int)colCount data:(char **)data name:(char **)name
{
	isInitialized = YES;
	return 0;
}

- (int)versionCallback:(int)colCount data:(char **)data name:(char **)name
{
	version = atoi(data[0]);
	return 0;
}



/*
 *	Attempt to start up the database. This returns NO if startup failed.
 */

- (BOOL)startup
{
	/*
	 *	Initialize or open the SQLite database
	 */
	 
	NSArray<NSString *> *list = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *path = [list[0] stringByAppendingPathComponent:@"com.chaosinmotion.Billing"];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL success = [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
	if (!success) return NO;

	/*
	 *	Create or open the file
	 */
	path = [path stringByAppendingPathComponent:@"billing.sqlite"];
	const char *fileName = [path UTF8String];
	
	int result = sqlite3_open(fileName, &sql);
	if (result != SQLITE_OK) return NO;
	
	/*
	 *	Determine if we have a database installed. If not, create the appropriate
	 *	tables and entries
	 */
	
	result = sqlite3_exec(sql,"SELECT name FROM sqlite_master WHERE type='table' AND name='version'", ExecCallback, (__bridge void *)self, NULL);
	if (result != SQLITE_OK) return NO;
	
	if (!isInitialized) {
		/*
		 *	Version is 0.
		 */
		 
		version = 0;
	} else {
		/*
		 *	Get the current version
		 */
		
		result = sqlite3_exec(sql,"SELECT max(version) FROM version",VersionCallback,(__bridge void *)self, NULL);
		if (result != SQLITE_OK) return NO;
	}
	
	/*
	 *	At this point we have the version, or the version is 0. If the version
	 *	is 0, create our version table
	 */
	 
	if (version == 0) {
		result = sqlite3_exec(sql,
					"CREATE TABLE version ( version INTEGER ); "
					"INSERT INTO version ( version) VALUES (1)",NULL,NULL,NULL);
		if (result != SQLITE_OK) return NO;
	}

	/*
	 *	Insert table version 1.
	 */
	 
	if (version < 1) {
		result = sqlite3_exec(sql,
					"CREATE TABLE project ( "
					"    id INTEGER PRIMARY KEY, "
					"    json TEXT NON NULL )",NULL,NULL,NULL);
		if (result != SQLITE_OK) return NO;
		
		result = sqlite3_exec(sql,
					"CREATE TABLE entry ( "
					"    id INTEGER PRIMARY KEY, "
					"    projectid INTEGER NON NULL, "
					"    day INTEGER NON NULL, "
					"    hours NUMERIC NON NULL, "
					"    billid INTEGER, "
					"    billhours INTEGER, "
					"    item TEXT NON NULL ); "
					"CREATE INDEX entry_index ON entry ( projectid ); "
					"CREATE INDEX entry_index_2 ON entry ( billid )",NULL,NULL,NULL);
		if (result != SQLITE_OK) return NO;
		
		result = sqlite3_exec(sql,
					"CREATE TABLE bill ( "
					"    id INTEGER PRIMARY KEY, "
					"    projectid INTEGER NON NULL, "
					"    billindex INTEGER NON NULL, "
					"    date INTEGER NON NULL, "
					"    rate INTEGER NON NULL, "
					"    paid INTEGER NON NULL, "
					"    notes TEXT NON NULL ); "
					"CREATE INDEX bill_index ON bill ( projectid ); "
					"CREATE INDEX bill_index_2 ON bill ( billindex );",NULL,NULL,NULL);
		if (result != SQLITE_OK) return NO;
	}
	
	/*
	 *	Preload the project table.
	 */
	 
	sqlite3_stmt *query;
	result = sqlite3_prepare_v2(sql, "SELECT id, json FROM project ORDER BY id", -1, &query, NULL);
	if (result != SQLITE_OK) return NO;
	
	for (;;) {
		result = sqlite3_step(query);
		
		if (result == SQLITE_ROW) {
			/*
			 *	Row returned, add to our list
			 */
			 
			int ident = sqlite3_column_int(query, 0);
			const unsigned char *json = sqlite3_column_text(query, 1);
			int size = sqlite3_column_bytes(query,1);
			
			NSData *data = [[NSData alloc] initWithBytes:json length:size];
			NSDictionary *jdata = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			
			ProjectData *pdata = [[ProjectData alloc] initWithJSON:jdata];
			pdata.sqliteID = ident;
			[projectData addObject:pdata];
			
		} else if (result == SQLITE_DONE) {
			/*
			 *	Out of rows, finish
			 */
			
			sqlite3_finalize(query);
			break;
			
		} else {
			/*
			 *	Error of some sort. (Bail. Not handling busy)
			 */
			
			sqlite3_finalize(query);
			return NO;
		}
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DATABASESTARTED object:self];
	return YES;
}

/****************************************************************************/
/*																			*/
/*	Project Data															*/
/*																			*/
/****************************************************************************/

- (NSInteger)numberOfProjects
{
	return projectData.count;
}

- (ProjectData *)projectAtIndex:(NSInteger)index
{
	return projectData[index];
}

- (BOOL)deleteProjectAtIndex:(NSInteger)index
{
	/*
	 *	Delete row from SQL database
	 */
	
	ProjectData *data = projectData[index];
	
	sqlite3_stmt *query;
	int result = sqlite3_prepare_v2(sql, "DELETE FROM project WHERE id = ?", -1, &query, NULL);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_bind_int(query, 1, (int)data.sqliteID);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_step(query);
	if (result != SQLITE_DONE) return NO;
	
	result = sqlite3_finalize(query);
	if (result != SQLITE_OK) return NO;
	
	/*
	 *	Now delete from local memory
	 */
	
	[projectData removeObjectAtIndex:index];
	return YES;
}

- (BOOL)addProject:(ProjectData *)data
{
	/*
	 *	Add project to database.
	 */
	 
	sqlite3_stmt *query;
	int result = sqlite3_prepare_v2(sql, "INSERT INTO project ( json ) VALUES ( ? )", -1, &query, NULL);
	if (result != SQLITE_OK) return NO;
	
	NSData *json = [NSJSONSerialization dataWithJSONObject:data.asJson options:0 error:nil];
	NSInteger len = json.length;
	
	result = sqlite3_bind_text(query, 1, json.bytes, (int)len, SQLITE_STATIC);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_step(query);
	if (result != SQLITE_DONE) return NO;
	
	result = sqlite3_finalize(query);
	if (result != SQLITE_OK) return NO;
	
	data.sqliteID = sqlite3_last_insert_rowid(sql);
	
	/*
	 *	Now append
	 */
	
	[projectData addObject:data];
	return YES;
}

- (BOOL)setProject:(ProjectData *)data atIndex:(NSInteger)index
{
	ProjectData *row = projectData[index];

	/*
	 *	Add project to database.
	 */
	 
	sqlite3_stmt *query;
	int result = sqlite3_prepare_v2(sql, "UPDATE project SET json = ? WHERE id = ?", -1, &query, NULL);
	if (result != SQLITE_OK) return NO;
	
	NSData *json = [NSJSONSerialization dataWithJSONObject:data.asJson options:0 error:nil];
	NSInteger len = json.length;
	
	result = sqlite3_bind_text(query, 1, json.bytes, (int)len, SQLITE_STATIC);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_bind_int(query, 2, (int)row.sqliteID);
	if (result != SQLITE_OK) return NO;

	result = sqlite3_step(query);
	if (result != SQLITE_DONE) return NO;
	
	result = sqlite3_finalize(query);
	if (result != SQLITE_OK) return NO;
		
	/*
	 *	Now replace
	 */
	
	data.sqliteID = row.sqliteID;
	projectData[index] = data;
	return YES;
}

/****************************************************************************/
/*																			*/
/*	Billing Data															*/
/*																			*/
/****************************************************************************/

- (void)syncTimeRecords:(NSInteger)index
{
	if ((index < 0) || (index >= projectData.count)) {
		projectIndexID = 0;
		projectTime = [[NSMutableArray alloc] init];
		return;
	}
	
	NSInteger projectIdent = projectData[index].sqliteID;
	if (projectIdent != projectIndexID) {
		/*
		 *	We need to load the proper time records
		 */
		
		projectTime = [[NSMutableArray alloc] init];
		projectIndexID = projectIdent;
		
		sqlite3_stmt *query;
		int result = sqlite3_prepare_v2(sql,"SELECT id, projectid, day, hours, billid, billhours, item FROM entry WHERE projectid = ? ORDER BY day",-1,&query,NULL);
		if (result != SQLITE_OK) return;
		
		result = sqlite3_bind_int(query, 1, (int)projectIdent);
		if (result != SQLITE_OK) return;

		for (;;) {
			result = sqlite3_step(query);
			
			if (result == SQLITE_ROW) {
				/*
				 *	Row returned, add to our list
				 */
				 
				TimeDataRecord *tr = [[TimeDataRecord alloc] init];
				
				tr.sqliteID = sqlite3_column_int(query,0);
				tr.projectID = sqlite3_column_int(query,1);
				tr.dayCount = sqlite3_column_int(query,2);
				tr.hours = sqlite3_column_int(query,3);
				tr.billID = sqlite3_column_int(query,4);
				tr.billHours = sqlite3_column_int(query,5);
				
				const unsigned char *str = sqlite3_column_text(query, 6);
				int len = sqlite3_column_bytes(query, 6);
				
				tr.itemDesc = [[NSString alloc] initWithBytes:str length:len encoding:NSUTF8StringEncoding];
				
				[projectTime addObject:tr];
				
			} else if (result == SQLITE_DONE) {
				/*
				 *	Out of rows, finish
				 */
				
				sqlite3_finalize(query);
				break;
				
			} else {
				/*
				 *	Error of some sort. (Bail. Not handling busy)
				 */
				
				sqlite3_finalize(query);
				break;
			}
		}
	}
}

- (NSInteger)numberOfTimeRecordsInProject:(NSInteger)projIndex
{
	[self syncTimeRecords:projIndex];
	return projectTime.count;
}

- (TimeDataRecord *)timeRecord:(NSInteger)index inProject:(NSInteger)projIndex
{
	[self syncTimeRecords:projIndex];
	
	return projectTime[index];
}

- (BOOL)deleteTimeRecord:(NSInteger)index inProject:(NSInteger)projIndex
{
	[self syncTimeRecords:projIndex];
	NSInteger projectIdent = projectData[projIndex].sqliteID;
	
	/*
	 *	Delete row from SQL database
	 */
	
	TimeDataRecord *data = projectTime[index];
	
	sqlite3_stmt *query;
	int result = sqlite3_prepare_v2(sql, "DELETE FROM entry WHERE id = ? AND projectid = ?", -1, &query, NULL);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_bind_int(query, 1, (int)data.sqliteID);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_bind_int(query, 2, (int)projectIdent);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_step(query);
	if (result != SQLITE_DONE) return NO;
	
	result = sqlite3_finalize(query);
	if (result != SQLITE_OK) return NO;
	
	/*
	 *	Now delete from local memory
	 */
	
	[projectTime removeObjectAtIndex:index];
	return YES;
}

- (BOOL)addTimeRecord:(TimeDataRecord *)r inProject:(NSInteger)projIndex
{
	[self syncTimeRecords:projIndex];
	NSInteger projectIdent = projectData[projIndex].sqliteID;

	/*
	 *	Add data to database.
	 */
	 
	sqlite3_stmt *query;
	int result = sqlite3_prepare_v2(sql, "INSERT INTO entry ( projectid, day, hours, item ) VALUES ( ?, ?, ?, ? )", -1, &query, NULL);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_bind_int(query, 1, (int)projectIdent);
	if (result != SQLITE_OK) return NO;

	result = sqlite3_bind_int(query, 2, (int)r.dayCount);
	if (result != SQLITE_OK) return NO;

	result = sqlite3_bind_int(query, 3, (int)r.hours);
	if (result != SQLITE_OK) return NO;

	const char *itemdesc = r.itemDesc.UTF8String;
	result = sqlite3_bind_text(query, 4, itemdesc, (int)strlen(itemdesc), SQLITE_STATIC);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_step(query);
	if (result != SQLITE_DONE) return NO;
	
	result = sqlite3_finalize(query);
	if (result != SQLITE_OK) return NO;
	
	r.sqliteID = sqlite3_last_insert_rowid(sql);
	
	/*
	 *	Now append
	 */
	
	[projectTime addObject:r];
	return YES;
}

- (BOOL)setTimeRecord:(TimeDataRecord *)data inProject:(NSInteger)projIndex atIndex:(NSInteger)index
{
	[self syncTimeRecords:projIndex];

	TimeDataRecord *row = projectTime[index];

	/*
	 *	Add project to database.
	 */
	 
	sqlite3_stmt *query;
	int result = sqlite3_prepare_v2(sql, "UPDATE entry SET day = ?, hours = ?, item = ? WHERE id = ?", -1, &query, NULL);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_bind_int(query, 1, data.dayCount);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_bind_int(query, 2, data.hours);
	if (result != SQLITE_OK) return NO;
	
	const char *itemdesc = data.itemDesc.UTF8String;
	result = sqlite3_bind_text(query, 3, itemdesc, (int)strlen(itemdesc), SQLITE_STATIC);
	if (result != SQLITE_OK) return NO;
		
	result = sqlite3_bind_int(query, 4, (int)row.sqliteID);
	if (result != SQLITE_OK) return NO;

	result = sqlite3_step(query);
	if (result != SQLITE_DONE) return NO;
	
	result = sqlite3_finalize(query);
	if (result != SQLITE_OK) return NO;
		
	/*
	 *	Now replace
	 */
	
	data.sqliteID = row.sqliteID;
	projectTime[index] = data;
	return YES;
}

/****************************************************************************/
/*																			*/
/*	Bill Generation															*/
/*																			*/
/****************************************************************************/

- (void)syncBills
{
	if (billData) return;
	
	/*
	 *	This is a bit stupid.
	 */
	
	sqlite3_stmt *query;
	int result = sqlite3_prepare_v2(sql, "SELECT id, projectid, billindex, date, rate, paid, notes FROM bill ORDER BY date", -1, &query, NULL);
	if (result != SQLITE_OK) return;
	
	billData = [[NSMutableArray alloc] init];
	
	for (;;) {
		result = sqlite3_step(query);
		
		if (result == SQLITE_ROW) {
			/*
			 *	Row returned, add to our list
			 */
			 
			BillData *data = [[BillData alloc] init];
			data.timeData = [[NSMutableArray alloc] init];
			data.totalHours = 0;
			
			data.sqliteID = sqlite3_column_int(query, 0);
			data.projetID = sqlite3_column_int(query, 1);
			data.billIndex = sqlite3_column_int(query, 2);
			data.date = sqlite3_column_int(query, 3);
			data.rate = sqlite3_column_int(query, 4);
			data.paid = (sqlite3_column_int(query, 5) == 0) ? NO : YES;
				
			const unsigned char *str = sqlite3_column_text(query, 6);
			int len = sqlite3_column_bytes(query, 6);
			
			data.notes = [[NSString alloc] initWithBytes:str length:len encoding:NSUTF8StringEncoding];
			
			[billData addObject:data];
			
		} else if (result == SQLITE_DONE) {
			/*
			 *	Out of rows, finish
			 */
			
			sqlite3_finalize(query);
			break;
			
		} else {
			/*
			 *	Error of some sort. (Bail. Not handling busy)
			 */
			
			sqlite3_finalize(query);
			break;
		}
	}
	
	/*
	 *	Now synthesize the dynamic elements. This is the stupid part.
	 */
	 
	for (BillData *data in billData) {
		/*
		 *	Find and insert the project data
		 */
		
		for (ProjectData *proj in projectData) {
			if (proj.sqliteID == data.projetID) {
				data.project = proj;
				
				NSInteger ix = proj.billingStartIndex + data.billIndex - 1;
				data.billID = [NSString stringWithFormat:@"%@-%d",proj.billingPrefix,(int)ix];
			
				break;
			}
		}
	}
	
	/*
	 *	Now for the really stupid part: grab the time data records and assign
	 *	them to our bills
	 */
	
	result = sqlite3_prepare_v2(sql,"SELECT id, projectid, day, hours, billid, billhours, item FROM entry ORDER BY day",-1,&query,NULL);
	if (result != SQLITE_OK) return;
	
	for (;;) {
		result = sqlite3_step(query);
		
		if (result == SQLITE_ROW) {
			/*
			 *	Row returned, add to our list
			 */
			 
			TimeDataRecord *tr = [[TimeDataRecord alloc] init];
			
			NSInteger billID = sqlite3_column_int(query, 4);
			for (BillData *b in billData) {
				if (b.sqliteID == billID) {
					tr.sqliteID = sqlite3_column_int(query,0);
					tr.projectID = sqlite3_column_int(query,1);
					tr.dayCount = sqlite3_column_int(query,2);
					tr.hours = sqlite3_column_int(query,3);
					tr.billID = sqlite3_column_int(query,4);
					tr.billHours = sqlite3_column_int(query,5);
					
					const unsigned char *str = sqlite3_column_text(query, 6);
					int len = sqlite3_column_bytes(query, 6);
					
					tr.itemDesc = [[NSString alloc] initWithBytes:str length:len encoding:NSUTF8StringEncoding];
					
					[b.timeData addObject:tr];
					break;
				}
			}
			
		} else if (result == SQLITE_DONE) {
			/*
			 *	Out of rows, finish
			 */
			
			sqlite3_finalize(query);
			break;
			
		} else {
			/*
			 *	Error of some sort. (Bail. Not handling busy)
			 */
			
			sqlite3_finalize(query);
			break;
		}
	}
	
	/*
	 *	Total up hours, bill
	 */
	
	for (BillData *b in billData) {
		b.totalHours = 0;
		for (TimeDataRecord *tr in b.timeData) {
			b.totalHours += tr.billHours;
		}
		b.totalBill = b.rate * b.totalHours / 60;
	}
}

- (int)nextBillIndexForProject:(int)projectID
{
	sqlite3_stmt *query;
	int result = sqlite3_prepare_v2(sql, "SELECT max(billindex) FROM bill WHERE projectid = ?", -1, &query, NULL);
	if (result != SQLITE_OK) return 0;
	
	result = sqlite3_bind_int(query, 1, (int)projectID);
	if (result != SQLITE_OK) return 0;
	
	int maxIndex = 0;
	for (;;) {
		result = sqlite3_step(query);
		
		if (result == SQLITE_ROW) {
			/*
			 *	Row returned, add to our list
			 */
			 
			maxIndex = sqlite3_column_int(query, 0);
			
		} else if (result == SQLITE_DONE) {
			/*
			 *	Out of rows, finish
			 */
			
			sqlite3_finalize(query);
			break;
			
		} else {
			/*
			 *	Error of some sort. (Bail. Not handling busy)
			 */
			
			sqlite3_finalize(query);
			break;
		}
	}
	return maxIndex;
}

- (NSString *)nextBillForProject:(NSInteger)projIndex
{
	ProjectData *data = projectData[projIndex];

	int maxIndex = [self nextBillIndexForProject:(int)(data.sqliteID)];
	maxIndex += data.billingStartIndex;
	return [NSString stringWithFormat:@"%@-%d",data.billingPrefix,maxIndex];
}

- (BillData *)generateBillForProject:(NSInteger)projIndex withTimeRecords:(NSIndexSet *)sel onDate:(uint32_t)date comments:(NSString *)note
{
	sqlite3_stmt *query;
	int result;
	[self syncTimeRecords:projIndex];
	ProjectData *data = projectData[projIndex];
	__block BillData *returnValue = [[BillData alloc] init];
	
	result = sqlite3_exec(sql,"BEGIN",NULL,NULL,NULL);
	if (result != SQLITE_OK) return NULL;
	
	/*
	 *	Step 1: get the next bill index
	 */
	
	int maxIndex = [self nextBillIndexForProject:(int)(data.sqliteID)] + 1;
	
	/*
	 *	Step 2: generate the bill record. We need to do this before we update
	 *	the time sheet records.
	 */
	
	result = sqlite3_prepare_v2(sql, "INSERT INTO bill ( projectid, billindex, date, rate, paid, notes ) VALUES ( ?, ?, ?, ?, 0, ? )", -1, &query, NULL);
	if (result != SQLITE_OK) {
		sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
		return NULL;
	}
	
	result = sqlite3_bind_int(query, 1, (int)data.sqliteID);
	if (result != SQLITE_OK) {
		sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
		return NULL;
	}
	
	result = sqlite3_bind_int(query, 2, maxIndex);
	if (result != SQLITE_OK) {
		sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
		return NULL;
	}
	
	result = sqlite3_bind_int(query, 3, date);
	if (result != SQLITE_OK) {
		sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
		return NULL;
	}
	
	result = sqlite3_bind_int(query, 4, (int)data.billingRate);
	if (result != SQLITE_OK) {
		sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
		return NULL;
	}
	
	const char *itemdesc = note.UTF8String;
	result = sqlite3_bind_text(query, 5, itemdesc, (int)strlen(itemdesc), SQLITE_STATIC);
	if (result != SQLITE_OK) {
		sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
		return NULL;
	}
	
	result = sqlite3_step(query);
	if (result != SQLITE_DONE) {
		sqlite3_finalize(query);
		sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
		return NULL;
	}
	
	result = sqlite3_finalize(query);
	if (result != SQLITE_OK) {
		sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
		return NULL;
	}
	
	returnValue.sqliteID = sqlite3_last_insert_rowid(sql);
	returnValue.projetID = data.sqliteID;
	returnValue.billIndex = maxIndex;
	returnValue.date = date;
	returnValue.rate = data.billingRate;
	returnValue.paid = NO;
	returnValue.notes = note;
	returnValue.billID = [NSString stringWithFormat:@"%@-%d",data.billingPrefix,(int)(maxIndex+data.billingStartIndex-1)];
	returnValue.project = data;
	
	returnValue.timeData = [[NSMutableArray alloc] init];
		
	/*
	 *	Step 3: Walk through and update all of the time records. Note we update
	 *	the time records regardless of state. Note that any routine which calls
	 *	this will need to trigger a reload of the tables to show which ones have
	 *	been billed.
	 */
		
	result = sqlite3_prepare_v2(sql, "UPDATE entry SET billid = ?, billhours = ? WHERE id = ?", -1, &query, NULL);
	if (result != SQLITE_OK) {
		sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
		return NULL;
	}
	
	__block BOOL finished = YES;
	__block NSInteger totalHours = 0;
	
	[sel enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		TimeDataRecord *tr = projectTime[idx];
		
		[returnValue.timeData addObject:tr];
		totalHours += tr.hours;
		
		int result = sqlite3_bind_int(query, 1, (int)returnValue.sqliteID);
		if (result != SQLITE_OK) {
			sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
			finished = NO;
			return;
		}
		
		result = sqlite3_bind_int(query, 2, (int)tr.hours);
		if (result != SQLITE_OK) {
			sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
			finished = NO;
			return;
		}
		
		result = sqlite3_bind_int(query, 3, (int)tr.sqliteID);
		if (result != SQLITE_OK) {
			sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
			finished = NO;
			return;
		}
		
		result = sqlite3_step(query);
		if (result != SQLITE_DONE) {
			sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
			finished = NO;
			return;
		}
		
		result = sqlite3_reset(query);
		if (result != SQLITE_OK) {
			sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
			finished = NO;
			return;
		}
	}];
	result = sqlite3_finalize(query);
	if (result != SQLITE_OK) {
		sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
		return NULL;
	}
	
	if (!finished) return NULL;
	
	returnValue.totalHours = totalHours;
	returnValue.totalBill = (returnValue.rate * totalHours)/60;

	result = sqlite3_exec(sql,"COMMIT",NULL,NULL,NULL);
	if (result != SQLITE_OK) {
		/* So close. */
		sqlite3_exec(sql,"ROLLBACK",NULL,NULL,NULL);
		return NULL;
	}
	
	/*
	 *	Flush and reload
	 */
	
	projectIndexID = -1;
	[self syncTimeRecords:projIndex];
	
	billData = nil;
	[self syncBills];

	return returnValue;
}

- (NSInteger)numberOfBills
{
	[self syncBills];
	return billData.count;
}

- (BillData *)billAtIndex:(NSInteger)index
{
	[self syncBills];
	return billData[index];
}

- (BOOL)setIsPaid:(BOOL)paid forBillAtIndex:(NSInteger)billIndex
{
	BillData *b = billData[billIndex];
	
	sqlite3_stmt *query;
	int result = sqlite3_prepare_v2(sql, "UPDATE bill SET paid = ? WHERE id = ?", -1, &query, NULL);
	if (result != SQLITE_OK) {
		return NO;
	}
		
	result = sqlite3_bind_int(query, 1, paid ? 1 : 0);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_bind_int(query, 2, (int)b.sqliteID);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_step(query);
	if (result != SQLITE_DONE) return NO;
	
	result = sqlite3_finalize(query);
	if (result != SQLITE_OK) return NO;

	b.paid = paid;
	return YES;
}

- (BOOL)updateNote:(NSString *)note forBillAtIndex:(NSInteger)billIndex
{
	BillData *b = billData[billIndex];
	
	sqlite3_stmt *query;
	int result = sqlite3_prepare_v2(sql, "UPDATE bill SET notes = ? WHERE id = ?", -1, &query, NULL);
	if (result != SQLITE_OK) {
		return NO;
	}
		
	const char *itemdesc = note.UTF8String;
	result = sqlite3_bind_text(query, 1, itemdesc, (int)strlen(itemdesc), SQLITE_STATIC);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_bind_int(query, 2, (int)b.sqliteID);
	if (result != SQLITE_OK) return NO;
	
	result = sqlite3_step(query);
	if (result != SQLITE_DONE) return NO;
	
	result = sqlite3_finalize(query);
	if (result != SQLITE_OK) return NO;

	b.notes = note;
	return YES;
}


@end
