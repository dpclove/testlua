#!/usr/bin/python
#coding:utf-8

import os
import hashlib
import sys
import shutil
import json
import commands
import configAssetsUpdate
import struct
import binascii
from ftplib import FTP

_XFER_FILE = 'FILE'
_XFER_DIR = 'DIR'

class Xfer(object):
    '''
    @note: upload local file or dirs recursively to ftp server
    '''
    def __init__(self):
        self.ftp = None

    def __del__(self):
        pass

    def setFtpParams(self, ip, uname, pwd, port = 21, timeout = 60):
        self.ip = ip
        self.uname = uname
        self.pwd = pwd
        self.port = port
        self.timeout = timeout

    def initEnv(self):
        if self.ftp is None:
            self.ftp = FTP()
            print '### connect ftp server: %s ...'%self.ip
            self.ftp.set_pasv(0)
            self.ftp.connect(self.ip, self.port, self.timeout)
            self.ftp.login(self.uname, self.pwd)
            print self.ftp.getwelcome()

    def clearEnv(self):
        if self.ftp:
            self.ftp.close()
            print '### disconnect ftp server: %s!'%self.ip
            self.ftp = None

    def uploadDir(self, localdir='./', remotedir='./'):
        if not os.path.isdir(localdir):
            return
        print 'remotedir = ' + remotedir + ', current = ' + self.ftp.pwd()
        self.ftp.cwd(remotedir)
        for file in os.listdir(localdir):
            src = os.path.join(localdir, file)
            if os.path.isfile(src):
                self.uploadFile(src, file)
            elif os.path.isdir(src):
                try:
                    self.ftp.mkd(file)
                except:
                    sys.stderr.write('the dir is exists %s'%file)
                self.uploadDir(src, file)
        self.ftp.cwd('..')

    def uploadFile(self, localpath, remotepath='./'):
        if not os.path.isfile(localpath) or os.path.basename(localpath) == ".DS_Store":
            return
        print '+++ upload %s to %s:%s'%(localpath, self.ip, remotepath)
        self.ftp.storbinary('STOR ' + remotepath, open(localpath, 'rb'))

    def __filetype(self, src):
        if os.path.isfile(src):
            index = src.rfind('\\')
            if index == -1:
                index = src.rfind('/')
            return _XFER_FILE, src[index+1:]
        elif os.path.isdir(src):
            return _XFER_DIR, ''

    def initDirs(self):
        items = configAssetsUpdate.Paths.items()
        sortItems = sorted(items)
        for src, dest in sortItems:
            subPaths = dest[1].split('/')
            subPath = ''
            for v in subPaths:
                if v == '.':
                    subPath = '.'
                else:
                    subPath = subPath + '/' + v
                    try:
                        self.ftp.mkd(subPath)
                    except:
                        print subPath + ' is exists!'

    def upload(self):
        items = configAssetsUpdate.Paths.items()
        sortItems = sorted(items)
        for src, dest in sortItems:
            self.initEnv()
            self.initDirs()
            filetype, filename = self.__filetype(dest[0])
            self.srcDir = dest[0]
            self.destDir = dest[1]
            if filetype == _XFER_DIR:
                self.uploadDir(self.srcDir, self.destDir)
            elif filetype == _XFER_FILE:
                self.uploadFile(self.srcDir, self.destDir + '/' + filename)
            self.clearEnv()


def getFileMd5(filename):
    if not os.path.isfile(filename):
        return
    myhash = hashlib.md5()# create a md5 object
    f = file(filename,'rb')
    while True:
        b = f.read(8096)# get file content.
        if not b :
            break
        myhash.update(b)#encrypt the file
    f.close()
    return myhash.hexdigest()

#获取添加结尾字符的md5
def getMoreFileMd5(filename):
    if not os.path.isfile(filename):
        return
    myhash = hashlib.md5()# create a md5 object
    f = file(filename,'rb')
    a = ''
    while True:
        b = f.read(8096)# get file content.
        if not b :
            break
        a = a + b

    c = binascii.b2a_hex(a)
    myhash.update(c.upper())
    f.close()
    myhash.update("3c6e0b8a9c15224a8228b9a98ca1531d")
    return myhash.hexdigest()

def getAssets(path, prefix):
    fl = os.listdir(path) # get what we have in the dir.
    for f in fl:
        if os.path.isdir(os.path.join(path,f)): # if is a dir.
            if prefix == '':
                getAssets(os.path.join(path,f), f)
            else:
                getAssets(os.path.join(path,f), prefix + '/' + f)
        else:
            if f != '.svn' and f != '.DS_Store' and f != 'version.manifest' and f != 'project.manifest':
                md5 = getFileMd5(os.path.join(path,f))
                configAssetsUpdate.assetsXml += "\n\t\t\"%s\" : {\n\t\t\t\"md5\" : \"%s\"\n\t\t}, " % (prefix + '/' + f, md5)
    return configAssetsUpdate.assetsXml

def getMoreAssets(path, prefix):
    fl = os.listdir(path) # get what we have in the dir.
    for f in fl:
        if os.path.isdir(os.path.join(path,f)): # if is a dir.
            if prefix == '':
                getMoreAssets(os.path.join(path,f), f)
            else:
                getMoreAssets(os.path.join(path,f), prefix + '/' + f)
        else:
            if  f != '.svn' and f != '.DS_Store' and f != 'version.manifest' and f != 'project.manifest':
                md5 = getMoreFileMd5(os.path.join(path,f))
                configAssetsUpdate.assetsMoreXml += "\"%s\" : {\"md5\" : \"%s\"}, " % (prefix + '/' + f, md5)
    return configAssetsUpdate.assetsMoreXml

# 拷贝res和src_et到release文件夹
def copySrcAndRes(versionString, oPath):
    if os.path.exists(oPath):
        shutil.rmtree(oPath)
    shutil.copytree("res", oPath + '/res')
    shutil.copytree("src_hyl", oPath + '/src_hyl')
    shutil.rmtree("src_hyl")

def copyToAndroid(src, dst):
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst)

# 拷贝src到release文件夹
def copySrc(oPath):
    shutil.copytree("src", oPath + '/src')

# 创建version.manifest文件
def createVersionFile(oPath, versionNumber, versionString):
    versionXml = configAssetsUpdate.getVersion(versionNumber, versionString)
    f = file(oPath + "/version.manifest", "w+")
    f.write(versionXml)
    f.close()

# 创建project.manifest文件
def createProjectFile(oPath, versionNumber, versionString, newassets):
    projectXml = configAssetsUpdate.getProject(versionNumber, versionString, newassets)
    f = file(oPath + "/project.manifest", "w+")
    f.write(projectXml)
    f.close()

#检查是否在项目路径运行脚本
def checkSafe():
    if not os.path.exists('res'):
        return False
    elif not os.path.exists('src'):
        return False
    # elif not os.path.exists('../simulator/win32/luacompiles.sh'):
    #     return False
    return True

if __name__ == "__main__":
    if not checkSafe():
        print 'res src or luacompiles.sh not exist!'
        sys.exit()

    print 'start generate script'
    #commandline = 'cocos luacompile -s ../simulator/win32/src -d src_et -e -k JyZxYxmj8live1 -b sign813live88 --disable-compile'
    commandline = 'cocos luacompile -s src -d src_hyl -e -k OgIYzvzKhdkVVLIRnLq6d7xdtb5JL610 -b T4uX1rPacw3hi7AzOp6eSGYyppniMt0A --disable-compile'
    #编译src到src_et
    #commandline = 'sh luacompiles.sh'
    os.system(commandline)

    # 拷贝src和res到release
    versionNumber = configAssetsUpdate.VersionNumber
    versionString = configAssetsUpdate.versionString
    operationPath = configAssetsUpdate.ReleasePath + '/' + configAssetsUpdate.ProjectName
    copySrcAndRes(versionString, operationPath)
    print 'copy src_hyl and res to release finish!'

    # 生成project和version
    configAssetsUpdate.assetsXml = ''
    assetsXml = getAssets(operationPath, '')
    assetsXml = assetsXml[:-2]
	
    #新的md5
    configAssetsUpdate.assetsMoreXml = ''
    assetsMoreXml = getMoreAssets(operationPath, '')
    assetsMoreXml = assetsMoreXml[:-2]
    createVersionFile(operationPath, versionNumber, versionString)
    createProjectFile(operationPath, versionNumber, versionString, assetsMoreXml)
    print 'create version and project manifest file finish!'
    print 'copy file to android project!'
    #copyToAndroid(operationPath, configAssetsUpdate.AndroidPath)
    os.system('open '+operationPath)


    #Android打包
    #os.chdir('../../frameworks/runtime-src/proj.android')
    #os.system('python build_native.py -b release')
    #os.system('cocos run -p android -m release')
    # 拷贝src留作备份
    #copySrc(operationPath)

    #将文件上传到FTP服务器
#    xfer = Xfer()
#    xfer.setFtpParams('218.244.133.26', 'hnmj', '8u9$ds&dk')
#    xfer.upload()

