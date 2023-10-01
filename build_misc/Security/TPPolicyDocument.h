#import <Foundation/Foundation.h>
#import <TrustedPeers/TPSyncingPolicy.h>

@class TPPolicyVersion, NSData, NSArray;

@interface TPPolicyDocument : NSObject {

	TPPolicyVersion* _version;
	NSData* _protobuf;
}
@property (readonly) NSArray * keyViewMapping; 
@property (nonatomic,readonly) TPPolicyVersion * version;              //@synthesize version=_version - In the implementation block
@property (nonatomic,readonly) NSData * protobuf;                      //@synthesize protobuf=_protobuf - In the implementation block
+(void)addModelToCategory:(id)arg1 toPB:(id)arg2 ;
+(void)addIntroducersByCategory:(id)arg1 toPB:(id)arg2 ;
+(id)categoriesByViewFromPb:(id)arg1 ;
+(id)policyDocWithHash:(id)arg1 data:(id)arg2 ;
+(id)redactionWithEncrypter:(id)arg1 modelToCategory:(id)arg2 categoriesByView:(id)arg3 introducersByCategory:(id)arg4 keyViewMapping:(id)arg5 error:(id*)arg6 ;
+(void)addKeyViewMapping:(id)arg1 toPB:(id)arg2 ;
+(BOOL)isEqualKeyViewMapping:(id)arg1 other:(id)arg2 ;
+(id)modelToCategoryFromPb:(id)arg1 ;
+(void)addRedactions:(id)arg1 toPB:(id)arg2 ;
+(id)redactionsFromPb:(id)arg1 ;
+(id)introducersByCategoryFromPb:(id)arg1 ;
+(void)addCategoriesByView:(id)arg1 toPB:(id)arg2 ;
-(BOOL)isEqualToPolicyDocument:(id)arg1 ;
-(NSData *)protobuf;
-(id)policyWithSecrets:(id)arg1 decrypter:(id)arg2 error:(id*)arg3 ;
-(NSArray *)keyViewMapping;
-(TPPolicyVersion *)version;
-(id)description;
-(id)initWithHash:(id)arg1 data:(id)arg2 ;
-(id)initWithVersion:(unsigned long long)arg1 modelToCategory:(id)arg2 categoriesByView:(id)arg3 introducersByCategory:(id)arg4 redactions:(id)arg5 keyViewMapping:(id)arg6 userControllableViewList:(id)arg7 piggybackViews:(id)arg8 priorityViews:(id)arg9 inheritedExcludedViews:(id)arg10 hashAlgo:(long long)arg11 ;
-(BOOL)isEqual:(id)arg1 ;
-(id)cloneWithVersionNumber:(unsigned long long)arg1 prependingCategoriesByView:(id)arg2 prependingKeyViewMapping:(id)arg3 ;
-(unsigned long long)hash;
-(id)cloneWithVersionNumber:(unsigned long long)arg1 ;
-(id)encodeProtobuf;
@end
