#import <Foundation/Foundation.h>

@class NSString;

@interface TPPolicyVersion : NSObject <NSSecureCoding> {

	unsigned long long _versionNumber;
	NSString* _policyHash;
}
@property (readonly) unsigned long long versionNumber;              //@synthesize versionNumber=_versionNumber - In the implementation block
@property (retain,readonly) NSString * policyHash;                  //@synthesize policyHash=_policyHash - In the implementation block
+(BOOL)supportsSecureCoding;
-(void)encodeWithCoder:(id)arg1 ;
-(id)initWithVersion:(unsigned long long)arg1 hash:(id)arg2 ;
-(id)description;
-(BOOL)isEqual:(id)arg1 ;
-(id)initWithCoder:(id)arg1 ;
-(unsigned long long)versionNumber;
-(id)copyWithZone:(NSZone*)arg1 ;
-(NSString *)policyHash;
-(unsigned long long)hash;
@end
