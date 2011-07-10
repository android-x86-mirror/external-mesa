# Mesa 3-D graphics library
# Version:  7.11
#
# Copyright (C) 2010-2011 Chia-I Wu <olvaffe@gmail.com>
# Copyright (C) 2010-2011 LunarG Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

LOCAL_PATH := $(call my-dir)

# from Makefile
C_SOURCES = \
	cso_cache/cso_cache.c \
	cso_cache/cso_context.c \
	cso_cache/cso_hash.c \
	draw/draw_context.c \
	draw/draw_fs.c \
	draw/draw_gs.c \
	draw/draw_pipe.c \
	draw/draw_pipe_aaline.c \
	draw/draw_pipe_aapoint.c \
	draw/draw_pipe_clip.c \
	draw/draw_pipe_cull.c \
	draw/draw_pipe_flatshade.c \
	draw/draw_pipe_offset.c \
	draw/draw_pipe_pstipple.c \
	draw/draw_pipe_stipple.c \
	draw/draw_pipe_twoside.c \
	draw/draw_pipe_unfilled.c \
	draw/draw_pipe_util.c \
	draw/draw_pipe_validate.c \
	draw/draw_pipe_vbuf.c \
	draw/draw_pipe_wide_line.c \
	draw/draw_pipe_wide_point.c \
	draw/draw_pt.c \
	draw/draw_pt_emit.c \
	draw/draw_pt_fetch.c \
	draw/draw_pt_fetch_emit.c \
	draw/draw_pt_fetch_shade_emit.c \
	draw/draw_pt_fetch_shade_pipeline.c \
	draw/draw_pt_post_vs.c \
	draw/draw_pt_so_emit.c \
	draw/draw_pt_util.c \
	draw/draw_pt_vsplit.c \
	draw/draw_vertex.c \
	draw/draw_vs.c \
	draw/draw_vs_aos.c \
	draw/draw_vs_aos_io.c \
	draw/draw_vs_aos_machine.c \
	draw/draw_vs_exec.c \
	draw/draw_vs_ppc.c \
	draw/draw_vs_sse.c \
	draw/draw_vs_variant.c \
	indices/u_indices_gen.c \
	indices/u_unfilled_gen.c \
	os/os_misc.c \
	os/os_stream.c \
	os/os_stream_log.c \
	os/os_stream_null.c \
	os/os_stream_stdc.c \
	os/os_stream_str.c \
	os/os_time.c \
	pipebuffer/pb_buffer_fenced.c \
	pipebuffer/pb_buffer_malloc.c \
	pipebuffer/pb_bufmgr_alt.c \
	pipebuffer/pb_bufmgr_cache.c \
	pipebuffer/pb_bufmgr_debug.c \
	pipebuffer/pb_bufmgr_mm.c \
	pipebuffer/pb_bufmgr_ondemand.c \
	pipebuffer/pb_bufmgr_pool.c \
	pipebuffer/pb_bufmgr_slab.c \
	pipebuffer/pb_validate.c \
	rbug/rbug_connection.c \
	rbug/rbug_context.c \
	rbug/rbug_core.c \
	rbug/rbug_demarshal.c \
	rbug/rbug_texture.c \
	rbug/rbug_shader.c \
	rtasm/rtasm_cpu.c \
	rtasm/rtasm_execmem.c \
	rtasm/rtasm_ppc.c \
	rtasm/rtasm_ppc_spe.c \
	rtasm/rtasm_x86sse.c \
	tgsi/tgsi_build.c \
	tgsi/tgsi_dump.c \
	tgsi/tgsi_exec.c \
	tgsi/tgsi_info.c \
	tgsi/tgsi_iterate.c \
	tgsi/tgsi_parse.c \
	tgsi/tgsi_ppc.c \
	tgsi/tgsi_sanity.c \
	tgsi/tgsi_scan.c \
	tgsi/tgsi_sse2.c \
	tgsi/tgsi_text.c \
	tgsi/tgsi_transform.c \
	tgsi/tgsi_ureg.c \
	tgsi/tgsi_util.c \
	translate/translate.c \
	translate/translate_cache.c \
	translate/translate_generic.c \
	translate/translate_sse.c \
	util/u_debug.c \
	util/u_debug_describe.c \
	util/u_debug_refcnt.c \
	util/u_debug_stack.c \
	util/u_debug_symbol.c \
	util/u_dump_defines.c \
	util/u_dump_state.c \
	util/u_bitmask.c \
	util/u_blit.c \
	util/u_blitter.c \
	util/u_cache.c \
	util/u_caps.c \
	util/u_cpu_detect.c \
	util/u_dl.c \
	util/u_draw.c \
	util/u_draw_quad.c \
	util/u_format.c \
	util/u_format_other.c \
	util/u_format_latc.c \
	util/u_format_s3tc.c \
	util/u_format_rgtc.c \
	util/u_format_srgb.c \
	util/u_format_table.c \
	util/u_format_tests.c \
	util/u_format_yuv.c \
	util/u_format_zs.c \
	util/u_framebuffer.c \
	util/u_gen_mipmap.c \
	util/u_half.c \
	util/u_handle_table.c \
	util/u_hash.c \
	util/u_hash_table.c \
	util/u_index_modify.c \
	util/u_keymap.c \
	util/u_linear.c \
	util/u_linkage.c \
	util/u_network.c \
	util/u_math.c \
	util/u_mm.c \
	util/u_pstipple.c \
	util/u_rect.c \
	util/u_ringbuffer.c \
	util/u_sampler.c \
	util/u_simple_shaders.c \
	util/u_slab.c \
	util/u_snprintf.c \
	util/u_staging.c \
	util/u_surface.c \
	util/u_surfaces.c \
	util/u_texture.c \
	util/u_tile.c \
	util/u_transfer.c \
	util/u_resource.c \
	util/u_upload_mgr.c \
	util/u_vbuf_mgr.c

	# Disabling until pipe-video branch gets merged in
	#vl/vl_bitstream_parser.c \
	#vl/vl_mpeg12_mc_renderer.c \
	#vl/vl_compositor.c \
	#vl/vl_csc.c \
	#vl/vl_shader_build.c \

GALLIVM_SOURCES = \
        gallivm/lp_bld_arit.c \
        gallivm/lp_bld_assert.c \
        gallivm/lp_bld_bitarit.c \
        gallivm/lp_bld_const.c \
        gallivm/lp_bld_conv.c \
        gallivm/lp_bld_flow.c \
        gallivm/lp_bld_format_aos.c \
        gallivm/lp_bld_format_soa.c \
        gallivm/lp_bld_format_yuv.c \
        gallivm/lp_bld_gather.c \
        gallivm/lp_bld_init.c \
        gallivm/lp_bld_intr.c \
        gallivm/lp_bld_logic.c \
        gallivm/lp_bld_pack.c \
        gallivm/lp_bld_printf.c \
        gallivm/lp_bld_quad.c \
        gallivm/lp_bld_sample.c \
        gallivm/lp_bld_sample_aos.c \
        gallivm/lp_bld_sample_soa.c \
        gallivm/lp_bld_struct.c \
        gallivm/lp_bld_swizzle.c \
        gallivm/lp_bld_tgsi_aos.c \
        gallivm/lp_bld_tgsi_info.c \
        gallivm/lp_bld_tgsi_soa.c \
        gallivm/lp_bld_type.c \
        draw/draw_llvm.c \
        draw/draw_llvm_sample.c \
        draw/draw_llvm_translate.c \
        draw/draw_vs_llvm.c \
        draw/draw_pt_fetch_shade_pipeline_llvm.c

GALLIVM_CPP_SOURCES = \
	gallivm/lp_bld_debug.cpp \
	gallivm/lp_bld_misc.cpp

GENERATED_SOURCES = \
	indices/u_indices_gen.c \
	indices/u_unfilled_gen.c \
	util/u_format_srgb.c \
	util/u_format_table.c \
	util/u_half.c

include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(filter-out $(GENERATED_SOURCES), $(C_SOURCES))

LOCAL_C_INCLUDES := $(GALLIUM_TOP)/auxiliary/util

LOCAL_MODULE := libmesa_gallium

# generate sources
LOCAL_MODULE_CLASS := STATIC_LIBRARIES
intermediates := $(call local-intermediates-dir)
LOCAL_GENERATED_SOURCES := $(addprefix $(intermediates)/, $(GENERATED_SOURCES))

$(LOCAL_GENERATED_SOURCES): PRIVATE_CUSTOM_TOOL = python $^ > $@

$(intermediates)/indices/u_indices_gen.c \
$(intermediates)/indices/u_unfilled_gen.c \
$(intermediates)/util/u_format_srgb.c \
$(intermediates)/util/u_half.c: $(intermediates)/%.c: $(LOCAL_PATH)/%.py
	$(transform-generated-source)

$(intermediates)/util/u_format_table.c: $(intermediates)/%.c: $(LOCAL_PATH)/%.py $(LOCAL_PATH)/util/u_format.csv
	$(transform-generated-source)

# LLVM
ifneq ($(strip $(GALLIUM_LLVM_VERSION)),)
LOCAL_SRC_FILES += $(GALLIVM_SOURCES) $(GALLIVM_CPP_SOURCES)
include $(GALLIUM_LLVM_TEMPLATE)
endif

include $(GALLIUM_TEMPLATE)
include $(BUILD_STATIC_LIBRARY)
