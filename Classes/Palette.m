/*******************************************************************************
* Palette.m
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the implementation for using
*						the palette file from the MM/1 original
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/09/08		*	EGC	*	File creation date
*	04/23/18		*	EGC *	Updated to properly access embedded resources
*******************************************************************************/

#import "Palette.h"

@implementation Palette

#pragma mark - Object Lifecycle

- (id)init
{
	[super init];
	memset (redComponents, 0, DEFAULT_PALETTE_SIZE);
	memset (greenComponents, 0, DEFAULT_PALETTE_SIZE);
	memset (blueComponents, 0, DEFAULT_PALETTE_SIZE);
	memset (alphaComponents, 0, DEFAULT_PALETTE_SIZE);
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark - Business Logic

// Read in the palette file from the MM/1 version, which contains 256 sets of 3 bytes of RGB
- (BOOL)loadPalette:(NSString *)filename
{

	NSArray					*fileComponents = [filename componentsSeparatedByString:@"."];
	NSString				*resourceName = [[NSBundle mainBundle] pathForResource:fileComponents[0] ofType:fileComponents[1]];
	NSData					*paletteData = [NSData dataWithContentsOfFile:resourceName];
	const void				*paletteBytes = [paletteData bytes];
	unsigned char			*dataMarker = (unsigned char *)paletteBytes;			// Starts at the beginning of the data
	int						index = 0;

	for (index=0;index<DEFAULT_PALETTE_SIZE;index++)
		{
		redComponents[index] = *dataMarker++;
		greenComponents[index] = *dataMarker++;
		blueComponents[index] = *dataMarker++;
		if (redComponents[index] == 0 && greenComponents[index] == 0 && blueComponents[index] == 0)		// The color is black, which the MM/1 version uses as its transparent color
			{
			alphaComponents[index] = 0;
			}
		else
			{
			alphaComponents[index] = 0xff;
			}
		}

	return (YES);
}

- (unsigned char)redComponentForPaletteSlot:(int)slot
{
	return (redComponents[slot]);
}

- (unsigned char)greenComponentForPaletteSlot:(int)slot
{
	return (greenComponents[slot]);
}

- (unsigned char)blueComponentForPaletteSlot:(int)slot
{
	return (blueComponents[slot]);
}

- (unsigned char)alphaComponentForPaletteSlot:(int)slot
{
	return (alphaComponents[slot]);
}

@end
