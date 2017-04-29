#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import "sqlite3.h"

/*
功能：
1.清空钥匙串信息
2.获取钥匙串所有的组信息
3.删除指定组钥匙串信息
*/

void printToStdOut(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *formattedString = [[NSString alloc] initWithFormat: format arguments: args];
    va_end(args);
    [[NSFileHandle fileHandleWithStandardOutput] writeData: [formattedString dataUsingEncoding: NSNEXTSTEPStringEncoding]];
	[formattedString release];
}

void printUsage()
{
	printToStdOut(@"-r -a: Delete All Keychain Items(Generic Passwords, Internet Passwords, Identities, Certificates, and Keys)\n");
	printToStdOut(@"-r -g: Delete This Group Keychain Items\n");
	printToStdOut(@"-l   : Show All Groups In Keychain\n");
}

NSArray * getKeychainObjectsForSecClass(CFTypeRef kSecClassType) {
	NSMutableDictionary *genericQuery = [[NSMutableDictionary alloc] init];	
	[genericQuery setObject:(id)kSecClassType forKey:(id)kSecClass];
	[genericQuery setObject:(id)kSecMatchLimitAll forKey:(id)kSecMatchLimit];
	[genericQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
	[genericQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnRef];
	[genericQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	
	NSArray *keychainItems = nil;
	if (SecItemCopyMatching((CFDictionaryRef)genericQuery, (CFTypeRef *)&keychainItems) != noErr)
	{
		keychainItems = nil;
	}
	[genericQuery release];
	return keychainItems;
}


NSArray * getAllGroupsInKeychainForSecClass(CFTypeRef kSecClassType)
{
	NSMutableArray * groups = [[NSMutableArray alloc]init];
	NSArray * keychainItems = getKeychainObjectsForSecClass(kSecClassType);
	for (id item in keychainItems)
	{
		NSString * agrp = item[@"agrp"];
		if(![groups containsObject:agrp])[groups addObject:agrp];
	}
	return [groups autorelease];
}

NSArray * getAllGroupsInKeychainObjecs()
{
	NSArray * SecClasses = @[(id)kSecClassGenericPassword,(id)kSecClassInternetPassword,
							 (id)kSecClassIdentity,(id)kSecClassCertificate,(id)kSecClassKey];
	NSMutableArray * allGroups = [NSMutableArray array];
	for(id kSecClassType in SecClasses )
	{
		NSArray * groups =	getAllGroupsInKeychainForSecClass(kSecClassType);
		[allGroups addObjectsFromArray:groups];
	}
	return allGroups;
}

void deleteKeychainObjectsForSecClass(CFTypeRef kSecClassType) {
	NSMutableDictionary *genericQuery = [[NSMutableDictionary alloc]init];
	[genericQuery setObject:(id)kSecClassType forKey:(id)kSecClass];
	SecItemDelete((CFDictionaryRef)genericQuery);
	[genericQuery release];

}
void deleteKeychainObjectsForSecClassWithGroup(CFTypeRef kSecClassType, NSString * group)
{
	
	NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										               									(id)kSecClassType,(id)kSecClass,
																		               group,(id)kSecAttrAccessGroup,nil];
    SecItemDelete(( CFDictionaryRef)keychainQuery);
}


void deleteKeychainObjectsForGroup(NSString * group)
{
	NSArray * secClasses = @[(id)kSecClassGenericPassword,(id)kSecClassInternetPassword,
							 (id)kSecClassIdentity,(id)kSecClassCertificate,(id)kSecClassKey];
	for(id secClass in secClasses)
	{
		deleteKeychainObjectsForSecClassWithGroup(secClass,group);
	}
}

void deleteAllKeychainObjects()
{
	NSArray * SecClasses = @[(id)kSecClassGenericPassword,(id)kSecClassInternetPassword,
							 (id)kSecClassIdentity,(id)kSecClassCertificate,(id)kSecClassKey];
	for(id kSecClassType in SecClasses )
	{
		deleteKeychainObjectsForSecClass(kSecClassType);
	}
	
}


int main(int argc, char **argv, char **envp) {

	NSArray *arguments = [[NSProcessInfo processInfo] arguments];
	
	if(arguments.count<=1)
	{
		printUsage();
		return 0;
	}

	for(int i= 0; i<arguments.count;i++)
	{
		NSString * item = arguments[i];
		if([item isEqualToString:@"-l"])
		{
			NSArray * groups = getAllGroupsInKeychainObjecs();
			NSLog(@"---KEYCHAIN_GROUPS---%@",groups);
			return 0;
		}
		if([item isEqualToString:@"-r"])
		{
			int index = i+1;
			if(index<arguments.count)
			{
				if([arguments[index] isEqualToString:@"-a"])
				{
					NSLog(@"----DELETE_ALL_KEYCHAIN_GROUPS----\n");
					deleteAllKeychainObjects();
					return 0;

				}else if([arguments[index] isEqualToString:@"-g"])
				{
					index = index+1;
					if(index<arguments.count)
					{
						NSLog(@"----DELETE:%@----\n",arguments[index]);
						deleteKeychainObjectsForGroup(arguments[index]);
						return 0;
					}
				}
			}
		}
	}
	printUsage();
	return 0;
}


