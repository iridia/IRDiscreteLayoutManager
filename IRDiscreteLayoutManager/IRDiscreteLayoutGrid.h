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

#ifndef __IRDiscreteLayoutGridAreaBlocks__
#define __IRDiscreteLayoutGridAreaBlocks__

typedef BOOL (^IRDiscreteLayoutGridAreaValidatorBlock) (IRDiscreteLayoutGrid *self, id anItem);
typedef CGRect (^IRDiscreteLayoutGridAreaLayoutBlock) (IRDiscreteLayoutGrid *self, id anItem);
typedef id (^IRDiscreteLayoutGridAreaDisplayBlock) (IRDiscreteLayoutGrid *self, id anItem);

#endif


@protocol IRDiscreteLayoutItem;

@protocol IRDiscreteLayoutGridEngineUsing <NSObject>

//	The protocol is here to allow custom grids that have variable layout content areas in the grid, which are determined dynamically
//	The method is invoked on any prototype, and then the prototype will instantiate something, then fill that thing up using available items
//	within the grid.  The layout manager will then look at the returned instance, and make sure the used items are not sent to another grid.

//	The layout manager will not enumerate the content areas and manually set everything.

- (IRDiscreteLayoutGrid *) instantiatedGridWithAvailableItems:(NSArray *)items;

@end


@interface IRDiscreteLayoutGrid : NSObject <NSCopying, IRDiscreteLayoutGridEngineUsing>

@property (nonatomic, readwrite, assign) CGSize contentSize;
@property (nonatomic, readonly, retain) IRDiscreteLayoutGrid *prototype;
@property (nonatomic, readonly, retain) NSArray *layoutAreaNames;

//	Prototypes are all that matters.  They can’t have layout items associated with their layout areas, instead they mainly work with understanding their layout areas only.
+ (IRDiscreteLayoutGrid *) prototype;
- (void) registerLayoutAreaNamed:(NSString *)aName validatorBlock:(IRDiscreteLayoutGridAreaValidatorBlock)aValidatorBlock layoutBlock:(IRDiscreteLayoutGridAreaLayoutBlock)aLayoutBlock displayBlock:(IRDiscreteLayoutGridAreaDisplayBlock)aDisplayBlock;
- (NSUInteger) numberOfLayoutAreas;

//	The -instantiatedGrid returned from a prototype is a grid that can be populated with stuff, and usually its layout areas can’t be changed.
- (IRDiscreteLayoutGrid *) instantiatedGrid;
- (void) setLayoutItem:(id)aLayoutItem forAreaNamed:(NSString *)anAreaName;
- (id) layoutItemForAreaNamed:(NSString *)anAreaName;

//	Generally, these enumerators always work no matter if the grid is a prototype or not.
- (void) enumerateLayoutAreaNamesWithBlock:(void(^)(NSString *anAreaName))aBlock;
- (void) enumerateLayoutAreasWithBlock:(void(^)(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock))aBlock;

- (NSString *) descriptionWithLocale:(id)locale indent:(NSUInteger)level;

@end

//	Helpers returning layout blocks that latch on a certain content size, or a certain proportion in an unit rect.
//	The layout blocks simply look at the grid’s contentSize, and reutrn a rect that shows up correctly.

extern CGRect IRAutoresizedRectMake (CGRect originalRect, CGSize originalBounds, CGSize newBounds, UIViewAutoresizing autoresizingMask);

extern IRDiscreteLayoutGridAreaLayoutBlock IRDiscreteLayoutGridAreaLayoutBlockForConstantSizeMake (CGRect size, CGSize defaultBounds, UIViewAutoresizing autoresizingMask);

extern IRDiscreteLayoutGridAreaLayoutBlock IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake (CGFloat totalUnitsX, CGFloat totalUnitsY, CGFloat unitsOffsetX, CGFloat unitsOffsetY, CGFloat unitsSpanX, CGFloat unitsSpanY);
