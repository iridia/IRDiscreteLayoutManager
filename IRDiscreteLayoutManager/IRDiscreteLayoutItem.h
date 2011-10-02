//
//  IRDiscreteLayoutItem.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

@protocol IRDiscreteLayoutItem <NSObject>

- (NSString *) title;
- (NSArray *) representedMediaItems;
- (CFStringRef) typeForRepresentedMediaItem:(id)anItem;

- (NSString *) representedText;
- (NSURL *) representedImageURI;
- (NSURL *) representedVideoURI;

@end


//	A generic implementation for use inside and outside the framework.
//	Also the canonical one that is frequently tested.

@interface IRDiscreteLayoutItem  : NSObject <IRDiscreteLayoutItem>

@property (nonatomic, readwrite, retain) NSString *title;
@property (nonatomic, readonly, retain) NSArray *representedMediaItems;

- (BOOL) addMediaItem:(id)anItem withType:(CFStringRef)typeUTI;
- (BOOL) removeMediaItem:(id)anItem;

@end


#ifndef __IRDiscreteLayoutItemHelpers__
#define __IRDiscreteLayoutItemHelpers__

extern id IRDiscreteLayoutItemContentMediaForUTIType (id<IRDiscreteLayoutItem>self, CFStringRef aType);

#endif
