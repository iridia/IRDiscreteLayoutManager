//
//  IRDiscreteLayoutResult.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutResult.h"

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

@end
