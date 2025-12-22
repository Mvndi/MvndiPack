import shutil

source_file = 'en_us.json'

targets = [
    'af_za.json', 'bs_ba.json', 'en_gb.json', 'es_es.json', 'fr_ca.json', 'hr_hr.json', 'ka_ge.json', 'lol_us.json', 'nl_nl.json', 'ru_ru.json', 'sxu.json', 'val_es.json',
    'ar_sa.json', 'ca_es.json', 'en_nz.json', 'es_mx.json', 'fr_fr.json', 'hu_hu.json', 'kk_kz.json', 'lt_lt.json', 'nn_no.json', 'ry_ua.json', 'szl.json', 'vec_it.json',
    'ast_es.json', 'cs_cz.json', 'en_pt.json', 'es_uy.json', 'fra_de.json', 'hy_am.json', 'kn_in.json', 'lv_lv.json', 'no_no.json', 'sah_sah.json', 'ta_in.json', 'vi_vn.json',
    'az_az.json', 'cy_gb.json', 'en_ud.json', 'es_ve.json', 'fur_it.json', 'id_id.json', 'ko_kr.json', 'lzh.json', 'oc_fr.json', 'se_no.json', 'th_th.json', 'vp_vl.json',
    'ba_ru.json', 'da_dk.json', 'esan.json', 'fy_nl.json', 'ig_ng.json', 'ksh.json', 'mk_mk.json', 'ovd.json', 'sk_sk.json', 'tl_ph.json', 'yi_de.json',
    'bar.json', 'de_at.json', 'enp.json', 'et_ee.json', 'ga_ie.json', 'io_en.json', 'kw_gb.json', 'mn_mn.json', 'pl_pl.json', 'sl_si.json', 'tlh_aa.json', 'yo_ng.json',
    'be_by.json', 'de_ch.json', 'enws.json', 'eu_es.json', 'gd_gb.json', 'is_is.json', 'la_la.json', 'ms_my.json', 'pt_br.json', 'so_so.json', 'tok.json', 'zh_cn.json',
    'be_latn.json', 'de_de.json', 'eo_uy.json', 'fa_ir.json', 'gl_es.json', 'isv.json', 'lb_lu.json', 'mt_mt.json', 'pt_pt.json', 'sq_al.json', 'tr_tr.json', 'zh_hk.json',
    'bg_bg.json', 'el_gr.json', 'es_ar.json', 'fi_fi.json', 'haw_us.json', 'it_it.json', 'li_li.json', 'nah.json', 'qya_aa.json', 'sr_cs.json', 'tt_ru.json', 'zh_tw.json',
    'br_fr.json', 'en_au.json', 'es_cl.json', 'fil_ph.json', 'he_il.json', 'ja_jp.json', 'lmo.json', 'nds_de.json', 'ro_ro.json', 'sr_sp.json', 'tzo_mx.json', 'zlm_arab.json',
    'brb.json', 'en_ca.json', 'es_ec.json', 'fo_fo.json', 'hi_in.json', 'jbo_en.json', 'lo_la.json', 'nl_be.json', 'rpr.json', 'sv_se.json', 'uk_ua.json'
]

for target_file in targets:
    shutil.copyfile(source_file, target_file)
    print(f'Copied content from {source_file} to {target_file}')
