/*******************************************************************************
* Gameboard.m
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the implementation for using
*						gameboard files from the MM/1 original
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/09/08		*	EGC	*	File creation date
*	04/23/18		*	EGC *	Updated to properly access embedded resources
*******************************************************************************/

#import "Gameboard.h"

@implementation Gameboard

@synthesize tileFilename;
@synthesize spriteFilename;
@synthesize tileRows;

#pragma mark - Object Lifecycle

- (id)init
{
	
	[super init];
	tileRows = nil;
	attachmentRows = nil;
	characteristicRows = nil;
	tileFilename = nil;
	spriteFilename = nil;
	boardWidth = 0;
	boardHeight = 0;
	tileWidth = 0;
	tileHeight = 0;
	return self;
}

- (void)dealloc
{
	
	[tileRows release];
	[attachmentRows release];
	[characteristicRows release];
	[tileFilename release];
	[spriteFilename release];
	[super dealloc];
}

#pragma mark - Business Logic

// Read in a gameboard from the MM/1 version, which consists of a 6 byte standard header: "gmb", followed
// by 1 byte: board length, 1 byte: board height, 1 byte: upper 4 bits - pixel width of tiles, lower
// 4 bits - pixel height of tiles; Next comes a variable length section of the header, consisting of 1 byte:
// length of the tile filename, followed by the tile filename, 1 byte: length of character filename,
// followed by the character filename; Next is board height rows of board length columns of sets of data
// formatted as: 1 byte: tile characteristic attribute, 1 byte: tile attachment attribute (index of image
// in the character file), and 1 byte: tile attribute (index of image in the tile file)
- (BOOL)loadGameboard:(int)levelNumber
{

	NSString			*resourceName = [[NSBundle mainBundle] pathForResource:[@"level" stringByAppendingString:[[NSNumber numberWithInt:levelNumber] stringValue]] ofType:@".gmb"];
	NSData				*boardData = [NSData dataWithContentsOfFile:resourceName];
	const void			*boardBytes = [boardData bytes];
	unsigned char		*dataMarker = (unsigned char *)boardBytes;			// Starts at the beginning of the header
	unsigned char		header[HEADER_LENGTH + 1];
	int					filenameLength = 0;
	unsigned char		tempString[TEMP_STRING_LENGTH];
	int					heightIndex = 0;
	int					widthIndex = 0;
	int					intValue = 0;

	memset (header, 0, HEADER_LENGTH + 1);

	characteristicRows = [[NSMutableArray alloc] init];
	attachmentRows = [[NSMutableArray alloc] init];
	tileRows = [[NSMutableArray alloc] init];

	// Now process the file
	memcpy(header, dataMarker, HEADER_LENGTH);
	if (strcmp(header, GAMBIT_HEADER))
		{
		return NO;			// gameboard file didn't have the right header; it's either corrupt or a phony
		}
	else
		{
		dataMarker += HEADER_LENGTH;
		boardWidth = *dataMarker++;
		boardHeight = *dataMarker++;
			// Tile dimensions are compressed into one byte
		tileWidth = (*dataMarker & 0xf0) >> 4;
		tileHeight = *dataMarker & 0x0f;
		dataMarker++;
		filenameLength = *dataMarker++;			// Length of tile filename
		memset (tempString, 0, TEMP_STRING_LENGTH);
		strncpy(tempString, dataMarker, filenameLength);
		self.tileFilename = [NSString stringWithCString:tempString encoding:NSASCIIStringEncoding];
		dataMarker += filenameLength;
		filenameLength = *dataMarker++;			// Length of sprite filename
		memset (tempString, 0, TEMP_STRING_LENGTH);
		strncpy(tempString, dataMarker, filenameLength);
		self.spriteFilename = [NSString stringWithCString:tempString encoding:NSASCIIStringEncoding];
		dataMarker += filenameLength;
			// Header done - now we get to the raw board data
		for (heightIndex=0;heightIndex<boardHeight;heightIndex++)
			{
			NSMutableArray *characteristicColumns = [[[NSMutableArray alloc] initWithCapacity:boardWidth] autorelease];
			NSMutableArray *attachmentColumns = [[[NSMutableArray alloc] initWithCapacity:boardWidth] autorelease];
			NSMutableArray *tileColumns = [[[NSMutableArray alloc] initWithCapacity:boardWidth] autorelease];
			for (widthIndex=0;widthIndex<boardWidth;widthIndex++)
				{
				intValue = *dataMarker++;
				[characteristicColumns addObject:[NSNumber numberWithInt:intValue]];
				intValue = *dataMarker++;
				[attachmentColumns addObject:[NSNumber numberWithInt:intValue]];
				intValue = *dataMarker++;
				[tileColumns addObject:[NSNumber numberWithInt:intValue]];
				}
			[characteristicRows addObject:characteristicColumns];
			[attachmentRows addObject:attachmentColumns];
			[tileRows addObject:tileColumns];
			}
		}
	return YES;
}

/* The original engine didn't have bounds checking for the edges of the gameboard, and thus suffers from crashes now - adding fix to return solid, undiggable block on the outside of the boundaries */
- (unsigned char)tileForRow:(int)row column:(int)column
{
	if (row == -1 || row == boardHeight || column == -1 || column == boardWidth)
		return (0x02);		// The tile for the undiggable block
	else
		return ([[[tileRows objectAtIndex:row] objectAtIndex:column] unsignedCharValue]);
}

/* The original engine didn't have bounds checking for the edges of the gameboard, and thus suffers from crashes now - adding fix to return solid, undiggable block on the outside of the boundaries */
- (unsigned char)attachmentForRow:(int)row column:(int)column
{
	if (row == -1 || row == boardHeight || column == -1 || column == boardWidth)
		return (0x00);
	else
		return ([[[attachmentRows objectAtIndex:row] objectAtIndex:column] unsignedCharValue]);
}

/* The original engine didn't have bounds checking for the edges of the gameboard, and thus suffers from crashes now - adding fix to return solid, undiggable block on the outside of the boundaries */
- (unsigned char)characteristicForRow:(int)row column:(int)column
{
	if (row == -1 || row == boardHeight || column == -1 || column == boardWidth)
		return (TILE_STONE);
	else
		return ([[[characteristicRows objectAtIndex:row] objectAtIndex:column] unsignedCharValue]);
}

- (void)setTile:(unsigned char)newTile forRow:(int)row column:(int)column
{

	int tileNumber = newTile;

	[[tileRows objectAtIndex:row] replaceObjectAtIndex:column withObject:[NSNumber numberWithInt:tileNumber]];
}

- (void)setAttachment:(unsigned char)newAttachment forRow:(int)row column:(int)column
{

	int attachmentNumber = newAttachment;

	[[attachmentRows objectAtIndex:row] replaceObjectAtIndex:column withObject:[NSNumber numberWithInt:attachmentNumber]];
}

- (void)setCharacteristic:(unsigned char)newCharacteristic forRow:(int)row column:(int)column
{

	int characteristicNumber = newCharacteristic;

	[[characteristicRows objectAtIndex:row] replaceObjectAtIndex:column withObject:[NSNumber numberWithInt:characteristicNumber]];
}

- (int)boardWidth
{
	return boardWidth;
}

- (int)boardHeight
{
	return boardHeight;
}

- (int)tileWidth
{
	return tileWidth;
}

- (int)tileHeight
{
	return tileHeight;
}

@end
