## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2019, Konrad Weihmann

## Configuration for static code analysis on recipe-level

inherit sca-global
inherit sca-helper
inherit sca-file-filter
inherit sca-blacklist

SCA_ENABLED_MODULES_RECIPE ?= "\
                            bandit \
                            bashate \
                            bitbake \
                            cbmc \
                            checkbashism \
                            cppcheck \
                            cpplint \
                            darglint \
                            dennis \
                            detectsecrets \
                            flake8 \
                            flawfinder \
                            flint \
                            gcc \
                            jsonlint \
                            kconfighard \
                            looong \
                            luacheck \
                            msgcheck \
                            multimetric \
                            mypy \
                            oelint \
                            perl \
                            perlcritic \
                            pscan \
                            pyfindinjection \
                            pylint \
                            pysymcheck \
                            pytype \
                            rats \
                            ropgadget \
                            safety \
                            setuptoolslint \
                            sparse \
                            splint \
                            tlv \
                            tscancode \
                            vulture \
                            xmllint \
                            yamllint \
                            zrd \
                            "
SCA_SOURCES_DIR ?= "${B}"

SCA_MODE = "recipe"
SCA_MODE_UPPER = "${@d.getVar('SCA_MODE', True).upper()}"

def sca_on_recipe_init(d):
    import bb
    from bb.parse.parse_py import BBHandler
    enabledModules = []
    for item in intersect_lists(d, d.getVar("SCA_ENABLED_MODULES", True), d.getVar("SCA_AVAILABLE_MODULES", True)):
        if sca_is_module_blacklisted(d, item) or not any(sca_filter_by_license(d)):
            continue
        okay = False
        try:
            BBHandler.inherit("sca-{}".format(item), "sca-on-recipe", 1, d)
            func = "sca-{}-init".format(item).replace("-", "_")
            if d.getVar(func, False) is not None:
                bb.build.exec_func(func, d, **get_bb_exec_ext_parameter_support(d))
            okay = True
        except bb.parse.ParseError:
            pass
        try: 
            ## In case there is a split between image/recipe modules
            BBHandler.inherit("sca-{}-recipe".format(item), "sca-on-recipe", 1, d)
            func = "sca-{}-init".format(item).replace("-", "_")
            if d.getVar(func, False) is not None:
                bb.build.exec_func(func, d, **get_bb_exec_ext_parameter_support(d))
            okay = True
        except bb.parse.ParseError:
            pass
        if okay:
            enabledModules.append(item)
    if d.getVar("SCA_ENABLE_IMAGE_SUMMARY", True) == "1":
        BBHandler.inherit("sca-{}-recipe".format("bestof"), "sca-on-recipe", 1, d)
        func = "sca-{}-init".format("bestof").replace("-", "_")
        if d.getVar(func, False) is not None:
            bb.build.exec_func(func, d, **get_bb_exec_ext_parameter_support(d))
    if any(enabledModules):
        if d.getVar("SCA_VERBOSE_OUTPUT", True) == "1":
            bb.note("Using SCA Module(s) {}".format(",".join(sorted(enabledModules))))
