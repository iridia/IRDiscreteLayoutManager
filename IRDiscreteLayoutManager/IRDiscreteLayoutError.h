//
//  IRDiscreteLayoutError.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 3/29/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const IRDiscreteLayoutErrorDomain;

extern NSError * IRDiscreteLayoutError (NSUInteger code, NSString *description, NSDictionary *userInfo);

enum {
  
	IRDiscreteLayoutGenericError,
	
	IRDiscreteLayoutManagerItemExhaustionFailureError,
	IRDiscreteLayoutManagerPrototypeSearchFailureError,
	
	IRDiscreteLayoutGridItemValidationFailureError,
	IRDiscreteLayoutGridFulfillmentFailureError
	
}; typedef NSUInteger IRDiscreteLayoutErrorCode;
