# Makefile for gcc version of SDL
#
# changes:
#  18-Apr: _ApolloKeyRGB565toRGB565: disabled AMMX version of ColorKeying (for now, storem is not working in Gold2)
#  17-Nov: - fixed Shadow Surfaces (hopefully), they were effectively impossible
#            in the code base I got
#          - fixed ARGB32 (CGX code was assuming RGBA all the time)
#  12-Feb: - deleted redundant includes, now only include/ directory remains (as it should)

PREFX := /opt/m68k-amigaos

CC := $(PREFX)/bin/m68k-amigaos-gcc
AS := $(PREFX)/bin/m68k-amigaos-as
AR := $(PREFX)/bin/m68k-amigaos-ar
LD := $(PREFX)/bin/m68k-amigaos-ld
RL := $(PREFX)/bin/m68k-amigaos-ranlib
VASM := $(PREFX)/bin/vasmm68k_mot

CPU := 68030

GCCFLAGS = -I$(PREFX)/include -I. -Iinclude -Isrc/thread -Isrc/video -Isrc/main/amigaos -Isrc/timer -Isrc/events -Iamiga/makefile-support \
		-Ofast -fomit-frame-pointer -m$(CPU) -mhard-float -ffast-math -noixemul \
		-DNOIXEMUL -D_HAVE_STDINT_H
GLFLAGS = -DSHARED_LIB -lamiga
GCCFLAGS += -DNO_AMIGADEBUG
GLFLAGS  += -DNO_AMIGADEBUG

GOBJS = src/audio/SDL_audio.go src/audio/SDL_audiocvt.go src/audio/SDL_mixer.go src/audio/SDL_mixer_m68k.go src/audio/SDL_wave.go src/audio/amigaos/SDL_ahiaudio.go \
	src/SDL_error.go src/SDL_fatal.go src/video/SDL_RLEaccel.go src/video/SDL_blit.go src/video/SDL_blit_0.go \
	src/video/SDL_blit_1.go src/video/SDL_blit_A.go src/video/SDL_blit_N.go \
	src/video/SDL_bmp.go src/video/SDL_cursor.go src/video/SDL_pixels.go src/video/SDL_surface.go src/video/SDL_stretch.go \
	src/video/SDL_yuv.go src/video/SDL_yuv_sw.go src/video/SDL_video.go \
	src/timer/amigaos/SDL_systimer.go src/timer/SDL_timer.go src/joystick/SDL_joystick.go \
	src/joystick/SDL_sysjoystick.go src/events/SDL_quit.go src/events/SDL_active.go \
	src/cpuinfo/SDL_cpuinfo.go src/events/SDL_keyboard.go src/events/SDL_mouse.go src/events/SDL_resize.go src/file/SDL_rwops.go src/SDL.go \
	src/events/SDL_events.go src/thread/amigaos/SDL_sysmutex.go src/thread/amigaos/SDL_syssem.go src/thread/amigaos/SDL_systhread.go src/thread/amigaos/SDL_thread.go \
	src/thread/amigaos/SDL_syscond.go src/video/cybergfx/SDL_cgxvideo.go src/video/cybergfx/SDL_cgxmodes.go src/video/cybergfx/SDL_cgximage.go src/video/cybergfx/SDL_amigaevents.go \
	src/video/cybergfx/SDL_amigamouse.go src/video/cybergfx/SDL_cgxgl.go src/video/cybergfx/SDL_cgxwm.go \
	src/video/cybergfx/SDL_cgxyuv.go src/video/cybergfx/SDL_cgxaccel.go src/video/cybergfx/SDL_cgxgl_wrapper.go \
	src/video/SDL_gamma.go src/main/amigaos/SDL_lutstub.ll src/stdlib/SDL_stdlib.go src/stdlib/SDL_string.go src/stdlib/SDL_malloc.go src/stdlib/SDL_getenv.go

# Disabled modules
# src/cdrom/SDL_cdrom.go src/cdrom/amigaos/SDL_syscdrom.go

#
# BEGIN APOLLO ASM SUPPORT
# ( build vasm: make CPU=m68k SYNTAX=mot )
#
VFLAGS = -devpac -I$(PREFX)/m68k-amigaos/ndk-include -Fhunk
GCCFLAGS += -DAPOLLO_BLIT -Isrc/video/apollo
# -DAPOLLO_BLITDBG
GOBJS += src/video/apollo/blitapollo.ao src/video/apollo/apolloammxenable.ao src/video/apollo/colorkeyapollo.ao

%.ao: %.asm
	$(VASM) $(VFLAGS) -o $@ $*.asm
#
# END APOLLO ASM SUPPORT
#

%.go: %.c
	$(CC) $(GCCFLAGS) $(GCCDEFINES) -o $@ -c $*.c

%.ll: %.s
	$(AS) -m$(CPU) -o $@ $*.s

all: libSDL.a

libSDL.a: $(GOBJS)
	-rm -f libSDL.a
	$(AR) cru libSDL.a $(GOBJS)
	$(RL) libSDL.a

clean:
	-rm -f $(GOBJS)
