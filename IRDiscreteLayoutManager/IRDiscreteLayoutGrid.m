//
//  IRDiscreteLayoutGrid.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutGrid.h"


NSString * const IRDiscreteLayoutGridErrorDomain = @"com.iridia.discreteLayout.grid";


@interface IRDiscreteLayoutGrid ()
@property (nonatomic, readwrite, retain) IRDiscreteLayoutGrid *prototype;

@property (nonatomic, readwrite, retain) NSArray *layoutAreaNames;
@property (nonatomic, readwrite, retain) NSMutableDictionary *layoutAreaNamesToValidatorBlocks;
@property (nonatomic, readwrite, retain) NSMutableDictionary *layoutAreaNamesToLayoutBlocks;
@property (nonatomic, readwrite, retain) NSMutableDictionary *layoutAreaNamesToLayoutItems;
@property (nonatomic, readwrite, retain) NSMutableDictionary *layoutAreaNamesToDisplayBlocks;

@end


@implementation IRDiscreteLayoutGrid
@synthesize contentSize, prototype;
@synthesize layoutAreaNames;
@synthesize layoutAreaNamesToLayoutBlocks, layoutAreaNamesToValidatorBlocks, layoutAreaNamesToLayoutItems, layoutAreaNamesToDisplayBlocks;
@synthesize populationInspectorBlock;
@synthesize allowsPartialInstancePopulation;

+ (IRDiscreteLayoutGrid *) prototype {

	return [[[self alloc] init] autorelease];

}

- (IRDiscreteLayoutGrid *) instantiatedGrid {

	NSParameterAssert(!self.prototype);

	IRDiscreteLayoutGrid *returnedGrid = [self copy];
	returnedGrid.prototype = self;
	
	return [returnedGrid autorelease];

}

- (IRDiscreteLayoutGrid *) instantiatedGridWithAvailableItems:(NSArray *)items {

	NSParameterAssert(!self.prototype);

	//	This base implementation simply fills the grid up with some available items at the beginning of the array
	//	Subclasses can probably swizzle the prototype, and return a new instantiated grid
	
	NSUInteger numberOfItems = [items count];
	if (!numberOfItems)
		return nil;
	
	NSMutableArray *nonHandledItems = [[items mutableCopy] autorelease];
	NSMutableArray *consumedItems = [NSMutableArray array];
	
	IRDiscreteLayoutGrid *instance = [self instantiatedGrid];
	
	__block BOOL canContinue = (numberOfItems > 0);
	__block BOOL hasSkippedItem = NO;
		
	while (canContinue) {
	
		id nextItem = [nonHandledItems objectAtIndex:0];
		__block BOOL hasClaimedItem = NO;

		[instance enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
		
			if (hasClaimedItem || [instance layoutItemForAreaNamed:name])
				return;
			
			if ([instance setLayoutItem:nextItem forAreaNamed:name error:nil]) {
				[nonHandledItems removeObject:nextItem];
				[consumedItems addObject:nextItem];
				hasClaimedItem = YES;				
			}
			
		}];
		
		if (!hasClaimedItem) {
		
			[nonHandledItems removeObject:nextItem];
			hasSkippedItem = YES;
			
		}
		
		canContinue = !![nonHandledItems count];
		
	}
	
	//	The first item provided must be consumed.
	
	if (![consumedItems containsObject:[items objectAtIndex:0]])
		return nil;
	
	if (![consumedItems count])
		return nil;
	
	if ([instance isFullyPopulated])
		return instance;
	
	if (![nonHandledItems count])
	if (!hasSkippedItem)
	if (self.allowsPartialInstancePopulation)
		return instance;
	
	return nil;

}

- (id) init {

	self = [super init];
	if (!self)
		return nil;
		
	layoutAreaNames = [[NSArray array] retain];
	layoutAreaNamesToLayoutBlocks = [[NSMutableDictionary dictionary] retain];
	layoutAreaNamesToLayoutItems = [[NSMutableDictionary dictionary] retain];
	layoutAreaNamesToValidatorBlocks = [[NSMutableDictionary dictionary] retain];
	layoutAreaNamesToDisplayBlocks = [[NSMutableDictionary dictionary] retain];
	allowsPartialInstancePopulation = NO;
	
	return self;

}

- (void) dealloc {

	[prototype release];
	[layoutAreaNames release];
	[layoutAreaNamesToLayoutBlocks release];
	[layoutAreaNamesToValidatorBlocks release];
	[layoutAreaNamesToLayoutItems release];
	[layoutAreaNamesToDisplayBlocks release];
	
	[populationInspectorBlock release];
	
	[super dealloc];

}

- (id) copyWithZone:(NSZone *)zone {

	IRDiscreteLayoutGrid *copiedGrid = [[IRDiscreteLayoutGrid allocWithZone:zone] init];
	copiedGrid.contentSize = self.contentSize;
	copiedGrid.layoutAreaNames = [[self.layoutAreaNames copy] autorelease];
	copiedGrid.layoutAreaNamesToLayoutBlocks = [[self.layoutAreaNamesToLayoutBlocks mutableCopy] autorelease];
	copiedGrid.layoutAreaNamesToLayoutItems = [[self.layoutAreaNamesToLayoutItems mutableCopy] autorelease];
	copiedGrid.layoutAreaNamesToValidatorBlocks = [[self.layoutAreaNamesToValidatorBlocks mutableCopy] autorelease];
	copiedGrid.layoutAreaNamesToDisplayBlocks = [[self.layoutAreaNamesToDisplayBlocks mutableCopy] autorelease];
	copiedGrid.allowsPartialInstancePopulation = self.allowsPartialInstancePopulation;
	return copiedGrid;

}

- (void) registerLayoutAreaNamed:(NSString *)aName validatorBlock:(BOOL(^)(IRDiscreteLayoutGrid *self, id anItem))aValidatorBlock layoutBlock:(CGRect(^)(IRDiscreteLayoutGrid *self, id anItem))aLayoutBlock displayBlock:(id(^)(IRDiscreteLayoutGrid *self, id anItem))aDisplayBlock {

	NSParameterAssert(!self.prototype);
	NSParameterAssert(aLayoutBlock);
	
	[[self mutableArrayValueForKey:@"layoutAreaNames"] addObject:aName];
	
	if (aValidatorBlock)
		[self.layoutAreaNamesToValidatorBlocks setObject:[[aValidatorBlock copy] autorelease] forKey:aName];
	
	if (aLayoutBlock)
		[self.layoutAreaNamesToLayoutBlocks setObject:[[aLayoutBlock copy] autorelease] forKey:aName];
		
	if (aDisplayBlock)
		[self.layoutAreaNamesToDisplayBlocks setObject:[[aDisplayBlock copy] autorelease] forKey:aName];

}

- (NSUInteger) numberOfLayoutAreas {

	return [self.layoutAreaNames count];
	
}

- (void) setLayoutItem:(id)aLayoutItem forAreaNamed:(NSString *)anAreaName {

	[self setLayoutItem:aLayoutItem forAreaNamed:anAreaName error:nil];

}

- (BOOL) setLayoutItem:(id)aLayoutItem forAreaNamed:(NSString *)anAreaName error:(NSError **)outError {
	
	NSParameterAssert(self.prototype);
	NSParameterAssert(anAreaName);
	
	IRDiscreteLayoutGridAreaValidatorBlock validatorBlock = [self.layoutAreaNamesToValidatorBlocks objectForKey:anAreaName];
	if (aLayoutItem && validatorBlock && !validatorBlock(self, aLayoutItem)) {
		
		NSString *description = [NSString stringWithFormat:@"Item %@ is not accepted by the validator block of area named %@", aLayoutItem, anAreaName];
		
		if (outError) {
			*outError = [NSError errorWithDomain:IRDiscreteLayoutGridErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
				description, NSLocalizedDescriptionKey,
			nil]];
		}
		
		return NO;
		
	}
	
	if (aLayoutItem)
		[self.layoutAreaNamesToLayoutItems setObject:aLayoutItem forKey:anAreaName];
	else
		[self.layoutAreaNamesToLayoutItems removeObjectForKey:anAreaName];

	return YES;

}

- (id) layoutItemForAreaNamed:(NSString *)anAreaName {

	return [self.layoutAreaNamesToLayoutItems objectForKey:anAreaName];

}

- (void) enumerateLayoutAreaNamesWithBlock:(void(^)(NSString *anAreaName))aBlock {

	if (!aBlock)
		return;

	for (NSString *aName in self.layoutAreaNames)
		aBlock(aName);

}

- (void) enumerateLayoutAreasWithBlock:(void(^)(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock))aBlock {
	
	if (!aBlock)
		return;

	[self enumerateLayoutAreaNamesWithBlock:^(NSString *anAreaName) {
	
		aBlock(
			anAreaName,
			[self.layoutAreaNamesToLayoutItems objectForKey:anAreaName],
			[self.layoutAreaNamesToValidatorBlocks objectForKey:anAreaName],
			[self.layoutAreaNamesToLayoutBlocks objectForKey:anAreaName],
			[self.layoutAreaNamesToDisplayBlocks objectForKey:anAreaName]
		);
		
	}];

}

- (NSString *) descriptionWithLocale:(id)locale indent:(NSUInteger)level {

	return [[NSDictionary dictionaryWithObjectsAndKeys:
	
		[super description], @"Identity",
		self.prototype, @"Prototype",
		self.layoutAreaNames, @"Areas",
		self.layoutAreaNamesToLayoutItems, @"Items",
		
	nil] descriptionWithLocale:locale indent:level];

}

- (BOOL) isFullyPopulated {

	NSParameterAssert(self.prototype);
	
	if (self.populationInspectorBlock)
		return self.populationInspectorBlock(self);
	
	if (self.prototype.populationInspectorBlock)
		return self.prototype.populationInspectorBlock(self);
	
	__block BOOL answer = YES;
	
	[self enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
	
		if (!item)
			answer = NO;
			
	}];
	
	return answer;

}

@end





CGRect IRAutoresizedRectMake (CGRect originalRect, CGSize originalBounds, CGSize newBounds, UIViewAutoresizing autoresizingMask) {

	//	Three in the morning, not the best time to reinvent the wheel.
	//	So I stole all the autoresizing code in UIView.
	
	static UIView *referenceBoundingView = nil;
	static UIView *referenceInnerView = nil;
	static dispatch_once_t onceToken = 0;
	dispatch_once(&onceToken, ^ {
		referenceBoundingView = [[UIView alloc] initWithFrame:CGRectZero];
		referenceInnerView = [[UIView alloc] initWithFrame:CGRectZero];
		[referenceBoundingView addSubview:referenceInnerView];
	});
	
	referenceBoundingView.frame = (CGRect){ CGPointZero, originalBounds };
	referenceInnerView.frame = originalRect;
	referenceInnerView.autoresizingMask = autoresizingMask;
	referenceBoundingView.frame = (CGRect){ CGPointZero, newBounds };
	
  return referenceInnerView.frame;

}

IRDiscreteLayoutGridAreaLayoutBlock IRDiscreteLayoutGridAreaLayoutBlockForConstantSizeMake (CGRect size, CGSize defaultBounds, UIViewAutoresizing autoresizingMask) {

	return [[ ^ (IRDiscreteLayoutGrid *self, id anItem) {
	
		if (CGSizeEqualToSize(defaultBounds, self.contentSize))
			return size;
		else
			return IRAutoresizedRectMake(size, defaultBounds, self.contentSize, autoresizingMask);
	
	} copy] autorelease];

}

IRDiscreteLayoutGridAreaLayoutBlock IRDiscreteLayoutGridAreaLayoutBlockForProportionsMake (CGFloat totalUnitsX, CGFloat totalUnitsY, CGFloat unitsOffsetX, CGFloat unitsOffsetY, CGFloat unitsSpanX, CGFloat unitsSpanY) {

	return [[ ^ (IRDiscreteLayoutGrid *self, id anItem) {
		
		CGFloat xFactor = self.contentSize.width / totalUnitsX;
		CGFloat yFactor = self.contentSize.height / totalUnitsY;
		
		return CGRectIntegral((CGRect){
			(CGPoint){
				unitsOffsetX * xFactor,
				unitsOffsetY * yFactor
			},
			(CGSize){
				unitsSpanX * xFactor,
				unitsSpanY * yFactor
			}
		});
	
	} copy] autorelease];

};
