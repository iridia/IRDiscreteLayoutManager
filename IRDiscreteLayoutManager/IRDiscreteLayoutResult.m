//
//  IRDiscreteLayoutResult.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutResult.h"
#import "IRDiscreteLayoutGrid.h"

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
		
	self.grids = newGrids;
	
	return self;

}

- (void) dealloc {

	[grids release];
	[super dealloc];

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
