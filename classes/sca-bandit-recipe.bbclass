## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2019, Konrad Weihmann

inherit sca-helper
inherit sca-global
inherit sca-bandit-core

SCA_DEPLOY_TASK = "do_sca_deploy_bandit_recipe"

python do_sca_deploy_bandit_recipe() {
    sca_conv_deploy(d, "bandit", "json")
}

addtask do_sca_bandit_core before do_install after do_compile
addtask do_sca_deploy_bandit_recipe before do_package after do_sca_bandit_core

do_sca_bandit_core[depends] += "${@oe.utils.conditional('SCA_FORCE_RUN', '1', '${PN}:do_sca_do_force_meta_task', '', d)}"
do_sca_deploy_bandit_recipe[depends] += "${@oe.utils.conditional('SCA_FORCE_RUN', '1', '${PN}:do_sca_do_force_meta_task', '', d)}"

DEPENDS += "sca-recipe-bandit-rules-native"
