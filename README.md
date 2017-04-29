功能：

1.展示钥匙串所有组信息。

2.删除指定组钥匙串信息。

3.清理所有钥匙串信息。

分析:

一.授权文件中添加通配符，允许访问所有应用的keychain信息



二.钥匙串保存信息分析

说明:

每一个keyChain的组成如图,整体是一个字典结构. 

1.kSecClass key 定义属于那一种类型的keyChain。

2.不同的类型包含不同的Attributes,这些attributes定义了这个item的具体信息。

3.每个item可以包含一个密码项来存储对应的密码。

存储主要类型：

    密钥类型键

            CFTypeRef kSecClass

    密钥类型值

            CFTypeRef kSecClassGenericPassword //一般密码

            CFTypeRef kSecClassInternetPassword //网络密码

            CFTypeRef kSecClassCertificate //证书

            CFTypeRef kSecClassKey //密钥

            CFTypeRef kSecClassIdentity //身份证书(带私钥的证书)

    不同类型的钥匙串项对应的属性不同


Keychain操作

iOS中Security.framework框架提供了四个主要的方法来操作KeyChain:

// 查询

OSStatus SecItemCopyMatching(CFDictionaryRef query, CFTypeRef *result);

// 添加

OSStatus SecItemAdd(CFDictionaryRef attributes, CFTypeRef *result);

// 更新

KeyChain中的ItemOSStatus SecItemUpdate(CFDictionaryRef query, CFDictionaryRef attributesToUpdate);

// 删除

KeyChain中的ItemOSStatus SecItemDelete(CFDictionaryRef query)
        



