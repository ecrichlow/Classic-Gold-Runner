/*******************************************************************************
* ImageSet.h
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the template for using image
*						files from the MM/1 original
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/09/08		*	EGC	*	File creation date
*	04/24/18		*	EGC *	Converted to ARC
*******************************************************************************/

#import <Foundation/Foundation.h>
#import "Palette.h"

#define HEADER_LENGTH				3
#define IMAGE_MASTER_HEADER			"clp"
#define DEFAULT_IMAGE_PATH			@"/Gold Runner.app/"
#define MAX_NUM_IMAGES				256
#define DEFAULT_BITS_PER_COMPONENT	8
#define DEFAULT_BITS_PER_PIXEL		32
#define DEFAULT_BYTES_PER_PIXEL		4

@class Classic_Gold_RunnerAppDelegate;

@interface ImageSet : NSObject
{

	NSString						*filename;			// Name of the image file associated with this set
	NSMutableArray					*imageDataObjects;	// Holds the raw image data used for the UIImage objects
	NSMutableArray					*images;			// The set of UIImage objects this instance represents
	Classic_Gold_RunnerAppDelegate	*appDelegate;		// Used to retrieve palette data
	int								setType;			// 0 for tiles; 1 for sprites - needed to adjust transparency on sprites
}
@property (nonatomic, strong) NSString *filename;
- (BOOL)loadImages:(NSString *)fileName mode:(int)mode;
- (const void *)convertRawToRGBA:(unsigned char *)rawData forWidth:(int)width height:(int)height;
- (UIImage *)imageForSlot:(int)slotNumber;
- (NSMutableArray *)images;	// Just used for debugging
@end
