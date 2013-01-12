/*******************************************************************************
* Palette.h
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the template for using the
*						palette file from the MM/1 original
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/09/08		*	EGC	*	File creation date
*******************************************************************************/

#import <Foundation/Foundation.h>

#define DEFAULT_PALETTE_SIZE		256
#define DEFAULT_PALETTE_PATH		@"/Gold Runner.app/"

@interface Palette : NSObject
{

	unsigned char				redComponents[DEFAULT_PALETTE_SIZE];
	unsigned char				greenComponents[DEFAULT_PALETTE_SIZE];
	unsigned char				blueComponents[DEFAULT_PALETTE_SIZE];
	unsigned char				alphaComponents[DEFAULT_PALETTE_SIZE];
}
- (BOOL)loadPalette:(NSString *)filename;
- (unsigned char)redComponentForPaletteSlot:(int)slot;			// Useful if you have to build data using color components in the range of 0 - 255
- (unsigned char)greenComponentForPaletteSlot:(int)slot;		// Useful if you have to build data using color components in the range of 0 - 255
- (unsigned char)blueComponentForPaletteSlot:(int)slot;			// Useful if you have to build data using color components in the range of 0 - 255
- (unsigned char)alphaComponentForPaletteSlot:(int)slot;		// Useful if you have to build data using color components in the range of 0 - 255
@end
