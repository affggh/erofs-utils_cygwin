# erofs-utils for cygwin
## Include
**mkfs.erofs**    
**dump.erofs**    
**fsck.erofs**    
**extract.erofs**

## Thanks
[erofs-utils](https://github.com/hsiangkao/erofs-utils)    
[extract.erofs](https://github.com/sekaiacg/erofs-utils)    
aosp project

## How to build
### Prepare
#### prepare environment
install in setup_x86_64.exe from [cygwin](cygwin.org)      
make gcc-core gcc-g++ github    
libiconv-devel zlib-devel    
clang llvm libpcre-devel    
liblzma-devel gettext    
gettext-devel libtool    
automake autoconf po4a patch    
#### install xz 
if you no need lzma compressor you can skip this step
```sh
git clone https://github.com/xz-mirror/xz xz
cd xz && ./autogen.sh
./configure
make && make install
```
#### make 
```sh
git clone https://github.com/affggh/erofs-utils_cygwin erofs
cd erofs
# if you need extract.erofs
# git clone https://github.com/sekaiacg/erofs-utils extract
# then make
make
```
the output will be saved in bin folder
