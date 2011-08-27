//
//  IRDiscreteLayoutManager.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutManager.h"

@implementation IRDiscreteLayoutManager

@synthesize dataSource, delegate, result;

- (void) dealloc {

	[result release];
	[super dealloc];

}

@end
