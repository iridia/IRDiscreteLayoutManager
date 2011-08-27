//
//  IRDiscreteLayoutGrid.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//


//	The layout grid.  By design, the layout grid is only a dummy holder for intelligent layout areas.  The layout areas determine their own position, and the grid only manages them like a herd of cats.
//	The validator block takes an incoming item, and checks if it is suitabble for the layout area.  Generally, it always returns YES, though it might return NO if the view returned by layout area’s display block is specialized for some kind of contents.

@class IRDiscreteLayoutGrid;

#ifndef __IRDiscreteLayoutItem__
#define __IRDiscreteLayoutItem__

typedef BOOL (^IRDiscreteLayoutItemValidatorBlock) (IRDiscreteLayoutGrid *self, id anItem);
typedef CGRect (^IRDiscreteLayoutItemLayoutBlock) (IRDiscreteLayoutGrid *self, id anItem);
typedef id (^IRDiscreteLayoutItemDisplayBlock) (IRDiscreteLayoutGrid *self, id anItem);

#endif


@protocol IRDiscreteLayoutItem;

@interface IRDiscreteLayoutGrid : NSObject

@property (nonatomic, readwrite, assign) CGSize contentSize;
@property (nonatomic, readonly, retain) IRDiscreteLayoutGrid *prototype;

@property (nonatomic, readonly, retain) NSArray *layoutAreaNames;

- (void) registerLayoutAreaNamed:(NSString *)aName validatorBlock:(IRDiscreteLayoutItemValidatorBlock)aValidatorBlock layoutBlock:(IRDiscreteLayoutItemLayoutBlock)aLayoutBlock;

- (IRDiscreteLayoutGrid *) instantiatedGrid;
- (void) setLayoutItem:(id)aLayoutItem forAreaNamed:(NSString *)anAreaName;
- (id) layoutItemForAreaNamed:(NSString *)anAreaName;

- (void) enumerateLayoutAreaNamesWithBlock:(void(^)(NSString *anAreaName))aBlock;
- (void) enumerateLayoutAreasWithBlock:(void(^)(NSString *name, id item, IRDiscreteLayoutItemLayoutBlock layoutBlock, IRDiscreteLayoutItemValidatorBlock validatorBlock))aBlock;

@end




//	Helpers for layout blocks that latch on a certain content size, or a certain proportion in an unit rect.  The IRDiscreteLayoutGrid_LayoutBlockForProportions() is simply something that latches on the former using a unit rect of (0, 0, horizontalUnits, verticalUnits) for convenience.

extern IRDiscreteLayoutItemLayoutBlock IRDiscreteLayoutGridLayoutBlockForConstantSizeMake (CGRect size, CGSize defaultBounds, int autoresizingMask);

extern IRDiscreteLayoutItemLayoutBlock IRDiscreteLayoutGridLayoutBlockForProportionsMake (NSUInteger horizontalUnits, NSUInteger verticalUnits, NSUInteger horizontalSpan, NSUInteger verticalSpan);






















