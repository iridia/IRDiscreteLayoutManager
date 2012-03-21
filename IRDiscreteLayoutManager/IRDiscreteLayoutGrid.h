//
//  IRDiscreteLayoutGrid.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//


//	The layout grid.  By design, the layout grid is only a dummy holder for intelligent layout areas.  The layout areas determine their own position, and the grid only manages them like a herd of cats.
//	The validator block takes an incoming item, and checks if it is suitabble for the layout area.  Generally, it always returns YES, though it might return NO if the view returned by layout area’s display block is specialized for some kind of contents.

@class IRDiscreteLayoutGrid, IRDiscreteLayoutItem;

typedef BOOL (^IRDiscreteLayoutGridAreaValidatorBlock) (IRDiscreteLayoutGrid *self, id anItem);
typedef CGRect (^IRDiscreteLayoutGridAreaLayoutBlock) (IRDiscreteLayoutGrid *self, id anItem);
typedef id (^IRDiscreteLayoutGridAreaDisplayBlock) (IRDiscreteLayoutGrid *self, id anItem);

extern NSString * const IRDiscreteLayoutGridErrorDomain;


@interface IRDiscreteLayoutGrid : NSObject <NSCopying>

@property (nonatomic, readwrite, assign) CGSize contentSize;

//	Prototypes are all that matters.  They can’t have layout items associated with their layout areas, instead they mainly work with understanding their layout areas only.
+ (IRDiscreteLayoutGrid *) prototype;	//	Returns new, empty, mutable prototype
- (IRDiscreteLayoutGrid *) prototype;	//	Returns prototype of a grid instance

- (void) registerLayoutAreaNamed:(NSString *)aName validatorBlock:(IRDiscreteLayoutGridAreaValidatorBlock)aValidatorBlock layoutBlock:(IRDiscreteLayoutGridAreaLayoutBlock)aLayoutBlock displayBlock:(IRDiscreteLayoutGridAreaDisplayBlock)aDisplayBlock;
- (NSUInteger) numberOfLayoutAreas;
- (NSArray *) layoutAreaNames;

//	The -instantiatedGrid returned from a prototype is a grid that can be populated with stuff, and usually its layout areas can’t be changed.
- (IRDiscreteLayoutGrid *) instantiatedGrid;
- (IRDiscreteLayoutGrid *) instantiatedGridWithAvailableItems:(NSArray *)items;	//	Grabs available items for use, preferred over -instantiatedGrid

- (void) setLayoutItem:(id)aLayoutItem forAreaNamed:(NSString *)anAreaName;	//	Will not alert if something gone wrong, use the version with an error pointer and a BOOL return to be safe
- (BOOL) setLayoutItem:(id)aLayoutItem forAreaNamed:(NSString *)anAreaName error:(NSError **)outError;
- (id) layoutItemForAreaNamed:(NSString *)anAreaName;

- (BOOL) isFullyPopulated;	//uses populationInspectorBlock if exists, otherwise checks if any layout grid is not associated with an item
@property (nonatomic, readwrite, copy) BOOL (^populationInspectorBlock)(IRDiscreteLayoutGrid *self);

//	Generally, these enumerators always work no matter if the grid is a prototype or not.
- (void) enumerateLayoutAreaNamesWithBlock:(void(^)(NSString *anAreaName))aBlock;
- (void) enumerateLayoutAreasWithBlock:(void(^)(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock))aBlock;

@property (nonatomic, readwrite, assign) BOOL allowsPartialInstancePopulation;
//	Whether to allow partial population.
//	Default is NO.  Affects behavior of -instantiatedGridWithAvailableItems:.
//	YES: instantiation always succeeds even if some available items are skipped
//	NO: instantiation returns nil if the grid instance is not fully populated, probably due to validator bailing.

- (NSString *) descriptionWithLocale:(id)locale indent:(NSUInteger)level;

@end


extern CGRect IRAutoresizedRectMake (CGRect originalRect, CGSize originalBounds, CGSize newBounds, UIViewAutoresizing autoresizingMask);
extern IRDiscreteLayoutGridAreaLayoutBlock IRDiscreteLayoutGridAreaLayoutBlockForConstantSizeMake (CGRect size, CGSize defaultBounds, UIViewAutoresizing autoresizingMask);
extern IRDiscreteLayoutGridAreaLayoutBlock IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake (CGFloat totalUnitsX, CGFloat totalUnitsY, CGFloat unitsOffsetX, CGFloat unitsOffsetY, CGFloat unitsSpanX, CGFloat unitsSpanY);
