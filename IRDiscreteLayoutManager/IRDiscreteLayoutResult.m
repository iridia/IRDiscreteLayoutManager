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

- (void) dealloc {

	[grids release];
	[super dealloc];

}

@end
