# DatabaseDemo-FMDB-
FMDB在项目中的使用方式，包括数据库的创建方式（植入，sql创建），数据库版本升级，业务逻辑安排。此库不作为私有库直接使用，而是推荐一种使用方式以及代码组织规范，依赖FMDB。

分享内容：
# 数据存储与数据库

## 数据持久化
数据持久化就是将内存中的数据模型转换为存储模型，
以及将存储模型转换为内存中的数据模型的统称

## 持久化方式
- plist 属性列表
- NSUserDefault 偏好设置
- NSKeyedArchiver 归档 序列化
- SQLite3 嵌入式数据库
- CoreData 关系映射框架
- keychain

## plist
通过XML文件的方式持久化在本地目录中
配置信息：info.plist, 微博中贴纸滤镜信息
可被序列化的类
- NSString
- NSMutableString
- NSData
- NSMutableData
- NSArray
- NSMutableArray
- NSDictionary
- NSMutableDictionary
- NSNumber
- NSDate

'dict writeToFile:plistPath atomically:YES]' 

在write方法里, 为了安全, atomically一般情况都是YES. 它表示是否需要先写入一个辅助文件, 再把辅助文件拷贝到目标文件地址

优点：

 - 轻量级，简洁，存储方便
 - Xcode的可视化工具, 结构清晰方便查看
 
缺点：

- 操作对象有限
- 明文存储
- 存储对象不可变，单个值修改要重写整个plist文件

适用：
- 少量非敏感数据，数组或字典等结构存储
- 使用模板创建一些固定数据，如地理位置，省市等信息

## NSUserDefault

稍微特殊一点的plist，使用更简洁
``` NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:version forKey:@"version"];
    [defaults synchronize];
```
//引申代码规范，key直接用字符串，定义宏，宏集中，微博中统一Util方法
小规模数据，弱业务相关数据
一般存储程序配置信息
如果没有调用`synchronize`方法，系统会根据I/O情况不定时刻地保存到文件中
偏好设置会将所有数据保存到同一个文件中 /Library/Prefereces/bundleid.plist
使用setting bundle模板创建系统设置下应用的设置选项

app group  数据共享 

` [[NSUserDefaults alloc] initWithSuiteName:@"xxx"]`

### NSUserDefault—域
user defaults数据库中其实是由多个层级的域组成的，当你读取一个键值的数据时，NSUserDefaults从上到下透过域的层级寻找正确的值，不同的域有不同的功能，有些域是可持久的，有些域则不行。

	- 应用域（application domain）是最重要的域，它存储着你app通过NSUserDefaults set...forKey添加的设置。
	- 注册域（registration domain）仅有较低的优先权，只有在应用域没有找到值时才从注册域去寻找。->不能把默认数据存储到硬盘上,每次注册。
	- 全局域（global domain）则存储着系统的设置
	- 语言域（language-specific domains）则包括地区、日期等
	- 参数域（ argument domain）有最高优先权
  
## NSKeyedArchiver
把对象转为字节码，以文件的形式存储到磁盘上
—>微博草稿数据
凡是遵守NSCoding协议的对象都可以NSKeyedArchive进行归档
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder;

使用归档路径进行存取

//存储
`[NSKeyedArchiver archiveRootObject:classRoom toFile:archiverPath]; '
//读取
' ClassRoom *readClassRoom = [NSKeyedUnarchiver unarchiveObjectWithFile:archiverPath];'

- 如果需要归档的类中包含某个属性是自定义的类的实例，则需要相应的类也实现NSCoding协议。
- 保存文件的扩展名可以任意指定，归档文件是加密的。
- 如果需要归档的类是某个自定义类的子类时，就需要在归档和解档之前先实现父类的归档和解档方法。

可以存储一些复杂对象

好处：加密，安全性更高，可以压缩存放。

## Keychain
一种安全地存储敏感信息的工具，全局，不存在沙盒，即使app卸载仍保留
（UDID被弃后，使用UUID配合keychain实现，游客登录）
       Keychain 可以包含任意数量的 keychain item。每一个 keychain item 包含数据和一组属性。对于一个需要保护的 keychain item，比如密码或者私钥数据是加密的
       
item类型
- extern CFTypeRef kSecClassGenericPassword
- extern CFTypeRef kSecClassInternetPassword
- extern CFTypeRef kSecClassCertificate
- extern CFTypeRef kSecClassKey
- extern CFTypeRef kSecClassIdentity 

Keychain提供了以下的操作

	- SecItemAdd 添加一个item
	- SecItemUpdate 更新已存在的item
	- SecItemCopyMatching 搜索一个已存在的item
	- SecItemDelete 删除一个keychain item
  
Keychain 共享数据 keychain group
Keychain 通过iCloud备份跟跨设备共享。
