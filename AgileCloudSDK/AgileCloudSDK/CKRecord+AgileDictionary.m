//
//  CKRecord+AgileDictionary.m
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKRecord+AgileDictionary.h"
#import "CKRecordID+AgileDictionary.h"
#import "CKRecordZoneID+AgileDictionary.h"
#import "CKAsset+AgileDictionary.h"
#import "CLLocation+AgileDictionary.h"
#import "CKReference+AgileDictionary.h"
#import "Defines.h"

@implementation CKRecord (AgileDictionary)

- (NSDictionary *)asAgileDictionary {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"recordName": self.recordID.recordName,
																				 @"zoneID": self.recordID.zoneID.zoneName,
																				 @"recordType": self.recordType,
																				 @"fields": [self agileFieldsDictionary] }];
	if (self.recordChangeTag) {
		[dict setObject:self.recordChangeTag forKey:@"recordChangeTag"];
	}
	return dict;
}

- (NSDictionary *)agileFieldsDictionary {
	NSMutableDictionary *output = [NSMutableDictionary dictionary];
	
	for (NSString *key in [self allKeys]) {
		output[key] = [CKRecord recordFieldDictionaryForValue:[self objectForKey:key]];
	}
	
	return output;
}

+(NSDictionary*) recordFieldDictionaryForValue:(NSObject<CKRecordValue>*)val{
    
    if([val respondsToSelector:@selector(asAgileDictionary)]){
        return @{ @"value": [(id)val asAgileDictionary] };
    }
    
    return @{ @"value": [CKRecord encodedObject:val] };
}

+ (id)encodedObject:(NSObject<CKRecordValue> *)val {
	if ([val isKindOfClass:[NSString class]]) {
		return val;
	}
	else if ([val isKindOfClass:[NSNumber class]]) {
		if (strcmp([(NSNumber *)val objCType], @encode(BOOL)) == 0) {
			// make sure booleans encode as integers
			return [NSNumber numberWithInteger:[(NSNumber *)val integerValue]];
		}
		else {
			return val;
		}
	}
	else if ([val isKindOfClass:[NSDate class]]) {
		return @((NSInteger)([(NSDate *)val timeIntervalSince1970] * 1000));
	}
	else if ([val isKindOfClass:[NSData class]]) {
		return [(NSData *)val base64EncodedStringWithOptions:0];
	}
	else if ([val isKindOfClass:[CKReference class]]) {
		CKReference *ref = (CKReference *)val;
		return [ref asAgileDictionary];
	}
	else if ([val isKindOfClass:[CLLocation class]]) {
		return [(CLLocation *)val asAgileDictionary];
	}
	else if ([val isKindOfClass:[NSArray class]]) {
		NSMutableArray *vals = [NSMutableArray array];
		[(NSArray *)val enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
			[vals addObject:[self encodedObject:obj]];
		}];
		return vals;
	}
	else if ([val isKindOfClass:[CKAsset class]]) {
		return [(CKAsset *)val asAgileDictionary];
	}
    
	NSMutableDictionary *output = [NSMutableDictionary dictionary];
	
	for (NSString *key in [(id)val allKeys]) {
		output[key] = @{ @"value": [(id)val objectForKey:key] };
	}
	
	return output;
}

@end
