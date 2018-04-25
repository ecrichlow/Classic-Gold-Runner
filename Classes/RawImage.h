/*******************************************************************************
* RawImage.h
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the template for using raw
*						image files from the MM/1 original
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/10/08		*	EGC	*	File creation date
*	04/24/18		*	EGC *	Converted to ARC
*******************************************************************************/

#import <Foundation/Foundation.h>

#define DEFAULT_IMAGE_PATH			@"/Gold Runner.app/"
#define DEFAULT_BITS_PER_COMPONENT	8
#define DEFAULT_BITS_PER_PIXEL		32
#define DEFAULT_BYTES_PER_PIXEL		4

@class Classic_Gold_RunnerAppDelegate;

@interface RawImage : NSObject
{

	UIImage							*rawImage;
	NSData							*imageDataObject;	// Holds the raw image data used for the UIImage
	Classic_Gold_RunnerAppDelegate	*appDelegate;		// Used to retrieve palette data
}
@property (nonatomic, strong) UIImage *rawImage;
- (BOOL)loadRawImage:(NSString *)filename withWidth:(int)width height:(int)height;
@end
