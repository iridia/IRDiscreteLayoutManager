//
//  IRDiscreteLayoutResult.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutResult.h"
#import "IRDiscreteLayoutGrid.h"
#import "IRDiscreteLayoutGrid+DebugSupport.h"
#import "IRDiscreteLayoutArea.h"
#import "IRDiscreteLayoutItem.h"


@interface IRDiscreteLayoutResult ()

@property (nonatomic, readwrite, strong) NSArray *grids;

@end


@implementation IRDiscreteLayoutResult

@synthesize grids;

+ (IRDiscreteLayoutResult *) resultWithGrids:(NSArray *)grids {

	return [[self alloc] initWithGrids:grids];

}

- (id) init {

	return [self initWithGrids:nil];

}

- (IRDiscreteLayoutResult *) initWithGrids:(NSArray *)newGrids {

	self = [super init];
	if (!self)
		return nil;
		
	for (IRDiscreteLayoutGrid *aGrid in newGrids)
		NSAssert1(aGrid.prototype, @"Grid %@ must be an instance", aGrid);

	self.grids = newGrids;
	
	return self;

}


- (IRDiscreteLayoutGrid *) gridContainingItem:(id<IRDiscreteLayoutItem>)item {

	__block IRDiscreteLayoutGrid *foundGrid = nil;

	[self.grids enumerateObjectsUsingBlock: ^ (IRDiscreteLayoutGrid *grid, NSUInteger idx, BOOL *stopGridEnumeration) {
	
		[grid.layoutAreas enumerateObjectsUsingBlock: ^ (IRDiscreteLayoutArea *area, NSUInteger idx, BOOL *stopLayoutAreaEnumeration) {
		
			if ([area.item isEqual:item]) {
			
				foundGrid = grid;
				*stopLayoutAreaEnumeration = YES;
				*stopGridEnumeration = YES;
			
			}
			
		}];
		
	}];
	
	return foundGrid;

}

- (IRDiscreteLayoutGrid *) bestGridMatchingItemsInInstance:(IRDiscreteLayoutGrid *)instance {

	NSMutableDictionary *gridsToScores = [NSMutableDictionary dictionaryWithCapacity:[instance.layoutAreas count]];
	NSUInteger (^gridScore)(IRDiscreteLayoutGrid *) = ^ (IRDiscreteLayoutGrid *grid) {
		return [[gridsToScores objectForKey:[NSValue valueWithNonretainedObject:grid]] unsignedIntegerValue];
	};
	void (^setGridScore)(IRDiscreteLayoutGrid *, NSUInteger) = ^ (IRDiscreteLayoutGrid *grid, NSUInteger score) {
		[gridsToScores setObject:[NSNumber numberWithUnsignedInteger:score] forKey:[NSValue valueWithNonretainedObject:grid]];
	};
	
	for (IRDiscreteLayoutArea *area in instance.layoutAreas) {
		id<IRDiscreteLayoutItem> item = area.item;
		IRDiscreteLayoutGrid *enclosingGrid = [self gridContainingItem:item];
		if (enclosingGrid) {
			setGridScore(enclosingGrid, gridScore(enclosingGrid) + 1);
		}
	}
	
	NSArray *sortedGridValues = [[gridsToScores allKeys] sortedArrayUsingComparator:^(NSValue *lhs, NSValue *rhs) {
	
		return [[gridsToScores objectForKey:lhs] compare:[gridsToScores objectForKey:rhs]];
		
	}];
	
	if ([sortedGridValues count])
		return [[sortedGridValues lastObject] nonretainedObjectValue];
	
	return nil;

}

- (NSString *) description {
	
	NSMutableString *returnedString = [NSMutableString string];
	
	[returnedString appendFormat:@"%@\n(\n", [super description]];
	
	NSUInteger numberOfGrids = [self.grids count];
	[self.grids enumerateObjectsUsingBlock: ^ (IRDiscreteLayoutGrid *aGrid, NSUInteger idx, BOOL *stop) {
		
		[returnedString appendString:[aGrid descriptionWithLocale:nil indent:1]];
		
		if (idx != (numberOfGrids - 1))
			[returnedString appendString:@","];
		
		[returnedString appendString:@"\n"];
	
	}];
	
	[returnedString appendFormat:@")"];
	
	return returnedString;

}

@end
