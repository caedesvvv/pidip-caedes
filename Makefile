PD_DIR = /home/usune/DEB/src/puredata-0.41.4/pd-0.41-4/
PDP_DIR = @PDP_DIR@
FFMPEG_SOURCE_DIR = /SOURCES/ffmpeg

PDP_PIDIP_LIBS = -ldv  -lbz2 -lz -ldl -logg -lvorbis -lvorbisenc
IMLIB_CFLAGS = -g -O2 -DQUICKTIME_NEWER=1
IMLIB_LIBS = -L/usr/lib/x86_64-linux-gnu -lImlib2
THEORA_LIBS = -ltheora -logg -lvorbis -lvorbisenc
PDP_PIDIP_INCLUDES =  -I/home/usune/DEB/src/puredata-0.41.4/pd-0.41-4//src -I. -I/usr/include/pdp -I../include -I../charmaps
PDP_PIDIP_VERSION = 0.12.20
MPEG4IP_CFLAGS = 

PDP_PIDIP_DISTRO = /mnt/c/ydegoyon.free.fr/pidip-$(PDP_PIDIP_VERSION)
PDP_PIDIP_TARBALL = $(PDP_PIDIP_DISTRO).tar.gz


PDP_PIDIP_CFLAGS  = $(MPEG4IP_CFLAGS) $(IMLIB_CFLAGS) \
    -DPD -DX_DISPLAY_MISSING -O2 -funroll-loops -fomit-frame-pointer  -ffast-math \
    -fPIC -Wall -W -Wstrict-prototypes \
    -Wno-unused -Wno-parentheses -Wno-switch \
    -DPDP_PIDIP_VERSION=\"$(PDP_PIDIP_VERSION)\" -g

PDP_PIDIP_CPPFLAGS  = $(MPEG4IP_CFLAGS) $(IMLIB_CFLAGS) \
    -DPD -DX_DISPLAY_MISSING -O2 -funroll-loops -fomit-frame-pointer  -ffast-math \
    -Wall -W -Wstrict-prototypes \
    -Wno-unused -Wno-parentheses -Wno-switch \
    -DPDP_PIDIP_VERSION=\"$(PDP_PIDIP_VERSION)\" -g

ifeq ($(shell uname -s),Darwin)
all: pidip.pd_darwin
endif

ifeq ($(shell uname -s),Linux)
all: pidip.pd_linux
endif

pdp_pidip_all:
	make -C system
	make -C modules

pidip.pd_darwin: pdp_pidip_all
	rm -f pidip.pd_darwin
	g++ -bundle -undefined dynamic_lookup -headerpad_max_install_names -o pidip.pd_darwin modules/*.o system/*.o -L/sw/lib $(THEORA_LIBS) $(PDP_PIDIP_LIBS) $(IMLIB_LIBS)
	strip -x pidip.pd_darwin

pidip.pd_linux: pdp_pidip_all
	rm -f pidip.pd_linux
	g++ -rdynamic -shared -o pidip.pd_linux modules/*.o system/*.o -L/usr/lib/i386-linux-gnu $(THEORA_LIBS) $(PDP_PIDIP_LIBS) $(IMLIB_LIBS)
	strip --strip-unneeded pidip.pd_linux

clean:
	rm -rf config.log config.guess config.status
	rm -f */*.o
	rm -f pidip.pd_linux

install:
	install -m 755 -d $prefix/share/pidip/patches
	install -m 755 -d $(prefix)/share/pidip/charmaps
	install -m 755 -d $(prefix)/share/pidip/patches/images
	install -m 644 patches/*.pd $(prefix)/share/pidip/patches
	install -m 644 charmaps/* $(prefix)/share/pidip/charmaps
	install -m 644 patches/images/* $(prefix)/share/pidip/patches/images
	install -m 755 pidip.pd_linux $(prefix)/lib/pd/extra
	install -m 644 fonts/* $(prefix)/X11R6/lib/X11/fonts/TTF
	install -m 644 doc/*.pd $(prefix)/lib/pd/doc/5.reference
	ln -s $(prefix)/lib/pd/doc/pidip $(prefix)/share/pidip/patches


distro: clean all
	rm -f */*.o
	rm -rf autom4te.cache
	cd .. && cp -rf pidip /tmp/pidip-$(PDP_PIDIP_VERSION)
	cd /tmp && tar vczf $(PDP_PIDIP_TARBALL) pidip-$(PDP_PIDIP_VERSION)
	cp /mnt/c/ydegoyon.free.fr/pidip-$(PDP_PIDIP_VERSION).tar.gz /mnt/c/Yves/Software
	rm -rf /tmp/pidip-$(PDP_PIDIP_VERSION)

.c.o:
	gcc $(PDP_PIDIP_INCLUDES) $(PDP_PIDIP_CFLAGS) -o $*.o -c $*.c

.cpp.o:
	g++ $(PDP_PIDIP_INCLUDES) $(PDP_PIDIP_CPPFLAGS) -o $*.o -c $*.cpp
