## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2019, Konrad Weihmann

## Configuration for static code analysis on image-level

inherit sca-global
inherit sca-helper
inherit sca-file-filter
inherit sca-blacklist

SCA_PACKAGE_LICENSE_FILTER = "CLOSED"
SCA_ENABLED_MODULES_IMAGE ?= "\
                            bandit \
                            bashate \
                            bitbake \
                            checkbashism \
                            configcheck \
                            detectsecrets \
                            flake8 \
                            gixy \
                            jsonlint \
                            lynis \
                            multimetric \
                            mypy \
                            nixauditor \
                            oelint \
                            pyfindinjection \
                            pylint \
                            systemdlint \
                            tiger \
                            tlv \
                            upc \
                            vulture \
                            xmllint \
                            yamllint \
                            yara \
                            "
SCA_SOURCES_DIR ?= "${IMAGE_ROOTFS}"

SCA_MODE = "image"
SCA_MODE_UPPER = "${@d.getVar('SCA_MODE', True).upper()}"

def sca_on_image_init(d):
    import bb
    from bb.parse.parse_py import BBHandler
    enabledModules = []
    for item in intersect_lists(d, d.getVar("SCA_ENABLED_MODULES", True), d.getVar("SCA_AVAILABLE_MODULES", True)):
        try:
            if sca_is_module_blacklisted(d, item):
                continue
            BBHandler.inherit("sca-{}-image".format(item), "sca-on-image", 1, d)
            func = "sca-{}-init".format(item).replace("-", "_")
            if d.getVar(func, False) is not None:
                bb.build.exec_func(func, d, **get_bb_exec_ext_parameter_support(d))
            okay = True
            enabledModules.append(item)
        except bb.parse.ParseError as exp:
            if d.getVar("SCA_VERBOSE_OUTPUT", True) != "0":
                bb.warn(str(exp))
    if any(enabledModules):
        if d.getVar("SCA_VERBOSE_OUTPUT", True) == "1":
            bb.note("Using SCA Module(s) {}".format(",".join(sorted(enabledModules))))
        ## inherit license-helper class
        BBHandler.inherit("sca-license-image-helper".format(item), "sca-on-image", 1, d)
        if d.getVar("SCA_ENABLE_BESTOF", True) == "1":
            BBHandler.inherit("sca-{}-image".format("bestof"), "sca-on-recipe", 1, d)
            func = "sca-{}-init".format("bestof").replace("-", "_")
            if d.getVar(func, False) is not None:
                bb.build.exec_func(func, d, **get_bb_exec_ext_parameter_support(d))
        if d.getVar("SCA_ENABLE_IMAGE_SUMMARY", True) == "1":
            BBHandler.inherit("sca-{}".format("image-summary"), "sca-on-image", 1, d)
            func = "sca-{}-init".format("image-summary").replace("-", "_")
            if d.getVar(func, False) is not None:
                bb.build.exec_func(func, d, **get_bb_exec_ext_parameter_support(d))