inherit sca-helper
inherit sca-global
inherit sca-shellcheck-core
inherit sca-conv-checkstyle-helper

SCA_DEPLOY_TASK = "do_sca_deploy_shellcheck_image"

python do_sca_deploy_shellcheck_image() {
    import os
    import shutil

    os.makedirs(os.path.join(d.getVar("SCA_EXPORT_DIR"), "shellcheck", "raw"), exist_ok=True)
    os.makedirs(os.path.join(d.getVar("SCA_EXPORT_DIR"), "shellcheck", "checkstyle"), exist_ok=True)

    import os
    from xml.etree.ElementTree import Element, SubElement, Comment, tostring
    from xml.etree import ElementTree
    from xml.dom import minidom

    for _file in ["sca_raw_shellcheck.xml", "sca_checkstyle_shellcheck.xml"]:
        if not os.path.exists(os.path.join(d.getVar("T"), _file)):
            continue
        try:
            data = ElementTree.parse(os.path.join(d.getVar("T"), _file)).getroot()
            for node in data.findall(".//error"):
                ## Patch to common format
                node.attrib["message"] = "[Package:'{}' Tool:shellcheck] {}".format(d.getVar("PN"), node.attrib["message"])
                node.attrib["source"] = "ShellCheck.{}".format(node.attrib["source"])

            res = ""
            try:
                res = checkstyle_prettify(d, data).decode("utf-8")
            except:
                res = checkstyle_prettify(d, data)
            with open(os.path.join(d.getVar("T"), _file), "w") as f:
                f.write(res)
        except:
            pass

    raw_target = os.path.join(d.getVar("SCA_EXPORT_DIR"), "shellcheck", "raw", "{}-{}.xml".format(d.getVar("PN"), d.getVar("PV")))
    cs_target = os.path.join(d.getVar("SCA_EXPORT_DIR"), "shellcheck", "checkstyle", "{}-{}.xml".format(d.getVar("PN"), d.getVar("PV")))
    src_raw = os.path.join(d.getVar("T"), "sca_raw_shellcheck.xml")
    src_conv = os.path.join(d.getVar("T"), "sca_checkstyle_shellcheck.xml")
    if os.path.exists(src_raw):
        shutil.copy(src_raw, raw_target)
    if os.path.exists(src_conv):
        shutil.copy(src_conv, cs_target)
    if os.path.exists(cs_target):
        do_sca_export_sources(d, cs_target)
}

addtask do_sca_shellcheck_core before do_image_complete after do_image
addtask do_sca_deploy_shellcheck_image before do_image_complete after do_sca_shellcheck_core

DEPENDS += "sca-image-shellcheck-rules-native"
