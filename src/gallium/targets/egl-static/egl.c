/*
 * Mesa 3-D graphics library
 * Version:  7.10
 *
 * Copyright (C) 2010-2011 LunarG Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Authors:
 *    Chia-I Wu <olv@lunarg.com>
 */

#include "common/egl_g3d_loader.h"
#include "egldriver.h"
#include "egllog.h"

#ifdef HAVE_LIBUDEV
#include <stdio.h>
#include <libudev.h>
#endif
#define DRIVER_MAP_GALLIUM_ONLY
#include "pci_ids/pci_id_driver_map.h"

#include "egl_pipe.h"
#include "egl_st.h"

static struct egl_g3d_loader egl_g3d_loader;

static struct st_module {
   boolean initialized;
   struct st_api *stapi;
} st_modules[ST_API_COUNT];

static struct st_api *
get_st_api(enum st_api_type api)
{
   struct st_module *stmod = &st_modules[api];

   if (!stmod->initialized) {
      stmod->stapi = egl_st_create_api(api);
      stmod->initialized = TRUE;
   }

   return stmod->stapi;
}

#ifndef HAVE_LIBUDEV

#include <xf86drm.h>
/* for i915 */
#include <i915_drm.h>
/* for radeon */
#include <radeon_drm.h>
static boolean
drm_fd_get_pci_id(int fd, int *vendor_id, int *chip_id)
{
   drmVersionPtr version;

   *chip_id = -1;

   version = drmGetVersion(fd);
   if (!version) {
      _eglLog(_EGL_WARNING, "invalid drm fd");
      return FALSE;
   }
   if (!version->name) {
      _eglLog(_EGL_WARNING, "unable to determine the driver name");
      drmFreeVersion(version);
      return FALSE;
   }

   if (strcmp(version->name, "i915") == 0) {
      struct drm_i915_getparam gp;
      int ret;

      *vendor_id = 0x8086;

      memset(&gp, 0, sizeof(gp));
      gp.param = I915_PARAM_CHIPSET_ID;
      gp.value = chip_id;
      ret = drmCommandWriteRead(fd, DRM_I915_GETPARAM, &gp, sizeof(gp));
      if (ret) {
         _eglLog(_EGL_WARNING, "failed to get param for i915");
	 *chip_id = -1;
      }
   }
   else if (strcmp(version->name, "radeon") == 0) {
      struct drm_radeon_info info;
      int ret;

      *vendor_id = 0x1002;

      memset(&info, 0, sizeof(info));
      info.request = RADEON_INFO_DEVICE_ID;
      info.value = (long) chip_id;
      ret = drmCommandWriteRead(fd, DRM_RADEON_INFO, &info, sizeof(info));
      if (ret) {
         _eglLog(_EGL_WARNING, "failed to get info for radeon");
	 *chip_id = -1;
      }
   }

   drmFreeVersion(version);

   return (*chip_id >= 0);
}

#endif /* HAVE_LIBUDEV */

static const char *
drm_fd_get_screen_name(int fd)
{
#ifdef HAVE_LIBUDEV
   struct udev *udev;
   struct udev_device *device, *parent;
   struct stat buf;
   const char *pci_id;
   int vendor_id, chip_id, idx = -1, i;

   udev = udev_new();
   if (fstat(fd, &buf) < 0) {
      _eglLog(_EGL_WARNING, "failed to stat fd %d", fd);
      return NULL;
   }

   device = udev_device_new_from_devnum(udev, 'c', buf.st_rdev);
   if (device == NULL) {
      _eglLog(_EGL_WARNING,
              "could not create udev device for fd %d", fd);
      return NULL;
   }

   parent = udev_device_get_parent(device);
   if (parent == NULL) {
      _eglLog(_EGL_WARNING, "could not get parent device");
      goto out;
   }

   pci_id = udev_device_get_property_value(parent, "PCI_ID");
   if (pci_id == NULL ||
       sscanf(pci_id, "%x:%x", &vendor_id, &chip_id) != 2) {
      _eglLog(_EGL_WARNING, "malformed or no PCI ID");
      goto out;
   }

   /* find the driver index */
   for (idx = 0; driver_map[idx].driver; idx++) {
      if (vendor_id != driver_map[idx].vendor_id)
         continue;

      if (driver_map[idx].num_chips_ids == -1)
         goto out;

      for (i = 0; i < driver_map[idx].num_chips_ids; i++) {
         if (driver_map[idx].chip_ids[i] == chip_id)
            goto out;
      }
   }

out:
   udev_device_unref(device);
   udev_unref(udev);

   if (idx >= 0) {
      _eglLog((driver_map[idx].driver) ? _EGL_INFO : _EGL_WARNING,
            "pci id for fd %d: %04x:%04x, driver %s",
            fd, vendor_id, chip_id, driver_map[idx].driver);

      return driver_map[idx].driver;
   }
#else
   int vendor_id, chip_id;

   if (drm_fd_get_pci_id(fd, &vendor_id, &chip_id)) {
      int idx, i;

      for (idx = 0; driver_map[idx].driver; idx++) {
         if (vendor_id != driver_map[idx].vendor_id)
            continue;

         if (driver_map[idx].num_chips_ids == -1)
            break;

         for (i = 0; i < driver_map[idx].num_chips_ids; i++) {
            if (driver_map[idx].chip_ids[i] == chip_id)
               break;
         }
         if (i < driver_map[idx].num_chips_ids)
            break;
      }

      _eglLog((driver_map[idx].driver) ? _EGL_INFO : _EGL_WARNING,
            "pci id for fd %d: %04x:%04x, driver %s",
            fd, vendor_id, chip_id, driver_map[idx].driver);

      return driver_map[idx].driver;
   }
#endif

   _eglLog(_EGL_WARNING, "failed to get driver name for fd %d", fd);

   return NULL;
}

static struct pipe_screen *
create_drm_screen(const char *name, int fd)
{
   struct pipe_screen *screen;

   if (!name) {
      name = drm_fd_get_screen_name(fd);
      if (!name)
         return NULL;
   }

   screen = egl_pipe_create_drm_screen(name, fd);
   if (screen)
      _eglLog(_EGL_INFO, "created a pipe screen for %s", name);
   else
      _eglLog(_EGL_WARNING, "failed to create a pipe screen for %s", name);

   return screen;
}

static struct pipe_screen *
create_sw_screen(struct sw_winsys *ws)
{
   return egl_pipe_create_swrast_screen(ws);
}

static const struct egl_g3d_loader *
loader_init(void)
{
   int i;

   for (i = 0; i < ST_API_COUNT; i++)
      egl_g3d_loader.profile_masks[i] = egl_st_get_profile_mask(i);

   egl_g3d_loader.get_st_api = get_st_api;
   egl_g3d_loader.create_drm_screen = create_drm_screen;
   egl_g3d_loader.create_sw_screen = create_sw_screen;

   return &egl_g3d_loader;
}

static void
loader_fini(void)
{
   int i;

   for (i = 0; i < ST_API_COUNT; i++) {
      struct st_module *stmod = &st_modules[i];

      if (stmod->stapi) {
         egl_st_destroy_api(stmod->stapi);
         stmod->stapi = NULL;
      }
      stmod->initialized = FALSE;
   }
}

static void
egl_g3d_unload(_EGLDriver *drv)
{
   egl_g3d_destroy_driver(drv);
   loader_fini();
}

_EGLDriver *
_EGL_MAIN(const char *args)
{
   const struct egl_g3d_loader *loader;
   _EGLDriver *drv;

   loader = loader_init();
   drv = egl_g3d_create_driver(loader);
   if (!drv) {
      loader_fini();
      return NULL;
   }

   drv->Name = "Gallium";
   drv->Unload = egl_g3d_unload;

   return drv;
}
