/*******************************************************************************
* Gameboard.h
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the template for using
*						gameboard files from the MM/1 original
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/09/08		*	EGC	*	File creation date
*******************************************************************************/

#import <Foundation/Foundation.h>

#define HEADER_LENGTH				3
#define GAMBIT_HEADER				"gmb"
#define DEFAULT_GAMEBOARD_PATH		@"/Gold Runner.app/"

@interface Gameboard : NSObject
{

	NSMutableArray				*tileRows;				// An array of rows, each containing an array with a value for each column, for the tile data
	NSMutableArray				*attachmentRows;		// An array of rows, each containing an array with a value for each column, for the attachment data
	NSMutableArray				*characteristicRows;	// An array of rows, each containing an array with a value for each column, for the tile characteristic data
	NSString					*tileFilename;			// Name of the tile file for this board
	NSString					*spriteFilename;		// Name of the sprite file for this board
	int							boardWidth;				// Number of tiles wide the board is
	int							boardHeight;			// Number of tiles high the board is
	int							tileWidth;				// Number of pixels wide the board tiles are
	int							tileHeight;				// Number of pixels high the board tiles are
}
@property (nonatomic, retain) NSString *tileFilename;
@property (nonatomic, retain) NSString *spriteFilename;
@property (nonatomic, retain) NSMutableArray *tileRows;
- (BOOL)loadGameboard:(int)levelNumber;
- (unsigned char)tileForRow:(int)row column:(int)column;
- (unsigned char)attachmentForRow:(int)row column:(int)column;
- (unsigned char)characteristicForRow:(int)row column:(int)column;
- (void)setTile:(unsigned char)newTile forRow:(int)row column:(int)column;
- (void)setAttachment:(unsigned char)newAttachment forRow:(int)row column:(int)column;
- (void)setCharacteristic:(unsigned char)newCharacteristic forRow:(int)row column:(int)column;
- (int)boardWidth;
- (int)boardHeight;
- (int)tileWidth;
- (int)tileHeight;
@end
