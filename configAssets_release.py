#!/usr/bin/python
#coding:utf-8
#--------------------------请配置以下信息-----------------------------

# 版本号



VersionNumber = "2.3.3"




# 版本号文件夹
versionString = "001"

# # 项目名称(需要作为路径使用,不允许使用非法字符)
# ProjectName = 'mahjong_changsha_test'

# 项目名称(需要作为路径使用,不允许使用非法字符)
ProjectName = 'sxmj'

# ftp服务器更新的项目目录名称
FTPProjectName = ''

# 发布前资源拷贝路径
ReleasePath = "../../../mohe-zjh-game-update"

# Android资源文件
AndroidPath = "../frameworks/runtime-src/proj.android/assets"

# 生成热更获取网址
#UpdateWebsite = "http://upd.haoyunlaiyule1.com/%s" % FTPProjectName
UpdateWebsite =  "http://pkupd.haoyunlaiyule2.com"

# 更新路径 格式为:   本地相对路径 : 服务器相对路径
#Paths = {
#	'1'	: ['%s/%s/%s/src_et' % (ReleasePath, ProjectName, versionString), './%s/update/%s/src_et' % (FTPProjectName, versionString)],
#	'2' : ['%s/%s/%s/res' % (ReleasePath, ProjectName, versionString), './%s/update/%s/res' % (FTPProjectName, versionString)],
#	'3' : ['%s/%s/%s/project.manifest' % (ReleasePath, ProjectName, versionString), './%s' % FTPProjectName],
#	'4' : ['%s/%s/%s/version.manifest' % (ReleasePath, ProjectName, versionString), './%s' % FTPProjectName],
#}
Paths = {
	'1'	: ['%s/%s/%s/src_hyl' % (ReleasePath, ProjectName, versionString), './update/%s/src_hyl' % (versionString)],
	'2' : ['%s/%s/%s/res' % (ReleasePath, ProjectName, versionString), './update/%s/res' % (versionString)],
	'3' : ['%s/%s/%s/project.manifest' % (ReleasePath, ProjectName, versionString), '.' ],
	'4' : ['%s/%s/%s/version.manifest' % (ReleasePath, ProjectName, versionString), '.' ],
}
#--------------------------配置信息结束-----------------------------

assetsXml = ''

def getVersion(versionNumber, versionString):
	return '{\n\
	"packageUrl" : "%s",\n\
	"remoteVersionUrl" : "%s/version.manifest",\n\
	"remoteManifestUrl" : "%s/project.manifest",\n\
	"version" : "%s",\n\
	"engineVersion" : "Cocos2d-x v3.10"\n\
}' % (UpdateWebsite, UpdateWebsite, UpdateWebsite, versionNumber)

def getProject(versionNumber, versionString, newassets):
	return '{\n\
    "packageUrl" : "%s",\n\
    "remoteVersionUrl" : "%s/version.manifest",\n\
    "remoteManifestUrl" : "%s/project.manifest",\n\
    "version" : "%s",\n\
    "engineVersion" : "Cocos2d-x v3.10",\n\n\
    "newassets" : {\
    %s\n\
    },\n\
    "searchPaths" : [\n\
    ]\n}' % (UpdateWebsite, UpdateWebsite, UpdateWebsite, versionNumber, newassets)
