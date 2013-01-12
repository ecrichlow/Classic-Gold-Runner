/*******************************************************************************
* RawImage.h
*
* Title:			Classic Gold Runner
* Description:		Classic Gold Runner for iPhone
*						This source file contains the implementation for using
*						raw image files from the MM/1 original
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2008 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	12/10/08		*	EGC	*	File creation date
*******************************************************************************/

#import "RawImage.h"
#import "Classic_Gold_RunnerAppDelegate.h"

@implementation RawImage

@synthesize rawImage;

#pragma mark - Object Lifecycle

- (id)init
{
	[super init];
	rawImage = nil;
	imageDataObject = nil;
	appDelegate = (Classic_Gold_RunnerAppDelegate *)[[UIApplication sharedApplication] delegate];
	return self;
}

- (void)dealloc
{
	
	[rawImage release];
	[imageDataObject release];
	[super dealloc];
}

#pragma mark - Business Logic

// Read an image file from the MM/1 version, which consists of width x height bytes, each
// corresponding to a color in a palette slot in the default palette file
- (BOOL)loadRawImage:(NSString *)filename withWidth:(int)width height:(int)height
{

	NSString			*imagePath = [[NSHomeDirectory() stringByAppendingString:DEFAULT_IMAGE_PATH] stringByAppendingString:filename];
	NSData				*imageRawData = [NSData dataWithContentsOfFile:imagePath];
	const void			*imageBytes = [imageRawData bytes];
	unsigned char		*dataMarker = (unsigned char *)imageBytes;			// Starts at the beginning of the data
	unsigned char		*imageData = malloc(width * height * DEFAULT_BYTES_PER_PIXEL);
	int					rowIndex = 0;
	int					columnIndex = 0;
	int					pixel = 0;
	unsigned char		*imageDataIndex = imageData;
	CGColorSpaceRef		colorspace = CGColorSpaceCreateDeviceRGB();
	CGDataProviderRef	dataProviderRef = NULL;

	memset (imageData, 0, width * height * DEFAULT_BYTES_PER_PIXEL);
	for (rowIndex=0;rowIndex<height;rowIndex++)
		{
		for (columnIndex=0;columnIndex<width;columnIndex++)
			{
			pixel = (unsigned char)*dataMarker++;
			*imageDataIndex++ = [[appDelegate customPalette] redComponentForPaletteSlot:pixel];
			*imageDataIndex++ = [[appDelegate customPalette] greenComponentForPaletteSlot:pixel];
			*imageDataIndex++ = [[appDelegate customPalette] blueComponentForPaletteSlot:pixel];
			*imageDataIndex++ = [[appDelegate customPalette] alphaComponentForPaletteSlot:pixel];
			}
		}
	imageDataObject = [[NSData alloc] initWithBytes:imageData length:(width * height * DEFAULT_BYTES_PER_PIXEL)];
	free (imageData);
	dataProviderRef = CGDataProviderCreateWithCFData ((CFDataRef)imageDataObject);
	rawImage = [[UIImage imageWithCGImage:CGImageCreate(width, height, DEFAULT_BITS_PER_COMPONENT, DEFAULT_BITS_PER_PIXEL, width * DEFAULT_BYTES_PER_PIXEL, colorspace, kCGImageAlphaLast | kCGBitmapByteOrder32Big, dataProviderRef, NULL, NO, kCGRenderingIntentDefault)] retain];
	CGDataProviderRelease (dataProviderRef);
	CGColorSpaceRelease (colorspace);
	return (YES);
}

@end
