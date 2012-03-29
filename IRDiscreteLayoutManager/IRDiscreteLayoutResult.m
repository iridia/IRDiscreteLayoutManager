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
#import "IRDiscreteLayoutItem.h"


@interface IRDiscreteLayoutResult ()

@property (nonatomic, readwrite, retain) NSArray *grids;

@end


@implementation IRDiscreteLayoutResult

@synthesize grids;

+ (IRDiscreteLayoutResult *) resultWithGrids:(NSArray *)grids {

	return [[[self alloc] initWithGrids:grids] autorelease];

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

- (void) dealloc {

	[grids release];
	[super dealloc];

}

- (IRDiscreteLayoutGrid *) gridContainingItem:(id<IRDiscreteLayoutItem>)item {

	__block IRDiscreteLayoutGrid *foundGrid = nil;

	[self.grids enumerateObjectsUsingBlock: ^ (IRDiscreteLayoutGrid *grid, NSUInteger idx, BOOL *stopGridEnumeration) {
	
		[grid.layoutAreaNames enumerateObjectsUsingBlock: ^ (NSString *name, NSUInteger idx, BOOL *stopLayoutAreaEnumeration) {

			if ([[grid layoutItemForAreaNamed:name] isEqual:item]) {
			
				foundGrid = grid;
				*stopLayoutAreaEnumeration = YES;
				*stopGridEnumeration = YES;
			
			}
			
		}];
		
	}];
	
	return foundGrid;

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
