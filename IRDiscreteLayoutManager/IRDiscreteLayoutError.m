//
//  IRDiscreteLayoutError.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 3/29/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutError.h"

NSString * const IRDiscreteLayoutErrorDomain = @"com.iridia.discreteLayout.layoutManager";

NSError * IRDiscreteLayoutError (NSUInteger code, NSString *description, NSDictionary *userInfo) {

	NSMutableDictionary *usedUserInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
	
		description, NSLocalizedDescriptionKey,
	
	nil];
	
	if (userInfo)
		[usedUserInfo addEntriesFromDictionary:userInfo];

	return [NSError errorWithDomain:IRDiscreteLayoutErrorDomain code:code userInfo:usedUserInfo];

}
