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

## CoreData

苹果官方在iOS5之后推出的综合性数据库，其使用了对象关系映射技术，将对象转换成数据，将数据存储在本地的数据库中。

PS: CoreData并不是数据库！而是个框架

使用了对象关系映射技术，底层通常使用 SQLit3

## SQLite数据库
一个轻量级，跨平台的小型数据库，可移植性比较高
      ios使用 libsqlite3.0,
      
前几种方法属于覆盖式存储, 如果要改变其中某一条, 需要整体取出修改后再行归档. 

- 该方案可以存储大量的数据,存储和检索的速度非常快。
- 能对数据进行大量的聚合
- CRUD更方便快速

## 数据库
按照一定的数据结构来组织、存储数据的仓库

根据不同的数据结构分为
- 层次式数据库
- 网络式数据库
- 关系式数据库

如今常见的分

- 非关系型数据库（NoSQL = NOT ONLY SQL）
- 关系型数据库

### 非关系型数据库

互联网web2.0网站的兴起，传统的关系数据库在应付web2.0网站，特别是超大规模和高并发的SNS类型的web2.0纯动态网站已经显得力不从心，暴露了很多难以克服的问题

NoSQL数据库在特定的场景下可以发挥出难以想象
的高效率和高性能，它是作为对传统关系型数据库的一个有效的补充

### 非关系型数据库种类

- 键值存储数据库（key-value）：Memcached、Redis、MemcacheDB

 键值数据库就类似传统语言中使用的哈希表。可以通过key来添加、查询或者删除数据库，因为使用key主键访问，所以会获得很高的性能及扩展性。
键值数据库主要使用一个哈希表，这个表中有一个特定的键和一个指针指向特定的数据

优势：简单、易部署、高并发

- 列存储（Column-oriented）数据库：Cassandra、HBase

列存储数据库将数据存储在列族中，一个列族存储经常被一起查询的相关数据
微博用户常用信息放一个列族，扩展信息不常用的放其他列族，分布式列族
通常用来应对分布式存储海量数据

- 面向文档（Document-Oriented）数据库：MongoDB、CouchDB 

类似键值数据库。该类型的数据模型是版本化的文档，半结构化的文档以特定的格式存
储，比如JSON。文档型数据库可以看作是键值数据库的升级版，允许之间嵌套键值。

将数据以文档形式存储。每个文档都是自包含的数据单元，是一系列数据项的集合。每个数据项都有一个名词与对应值
值既可以是简单的数据类型，也可以是复杂的类型

文档型数据库比键值数据库的查询效率更高

- 图形数据库：Neo4J、InforGrid

图形数据库允许我们将数据以图的方式存储。实体会被作为顶点，而实体之间的关系则会被作为边。
比如我们有三个实体，Steve Jobs、Apple和Next，则会
有两个“Founded by”的边将Apple和Next连接到Steve Jobs。

### 局限

虽然网状数据库和层次数据库已经很好的解决了数据的集中和共享问题  
但是在数据库独立性和抽象级别上扔有很大欠缺.  
用户在对这两种数据库进行存取时.  
仍然需要明确数据的存储结构，指出存取路径  

### 关系型数据库

把复杂的数据结构归结为简单的二元关系（即二维表格形式）。

在关系型数据库中，对数据的操作几乎全部建立在一个或多个关系表格上，
通过对这些关联的表格分类、合并、连接或选取等运算来实现数据库的管理

典型产品：  
Oracle , MySQL, MariaDB，SQLServer, PostgreSQL, Access, DB2

### 关系型数据库三大范式
1. 确保每列保持原子性  
数据库表中的所有字段值都是不可分解的原子值

2. 确保表中的每列都和主键相关  
在一个数据库表中，一个表中只能保存一种数据，不可以把多种数据保存在同一张数据库表中。

3. 确保每列都和主键列直接相关,而不是间接相关  
在一个数据库表中，一个表中只能保存一种数据，不可以把多种数据保存在同一张数据库表中。
消除传递依赖，去除冗余信息。

### 关系型数据库五大约束
1.—主键约束（Primay Key Coustraint） 唯一性，非空性  
2.—唯一约束 （Unique Counstraint）唯一性，可以空，但只能有一个  
3.—检查约束 (Check Counstraint) 对该列数据的范围、格式的限制（如：年龄、性别等）  
4.—默认约束 (Default Counstraint) 该数据的默认值  
5.—外键约束 (Foreign Key Counstraint) 需要建立两表间的关系并引用主表的列  
