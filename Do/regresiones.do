****************************************
****** REGRESIONES TMI FA***************
********2015-07-09**********************
****************************************

clear all
set pagesize 1000
set more off
global CL "E:\Dropbox\CLEAR\Datos\"
global B "${CL}bases\"
cd "$CL"
global var1  vac_pro cob_sub cob_cont edu cons ips_pub ips_pri idm idi sgp_salud


***
use "${B}panel_tmi_fa", clear

set more off, permanently

** Incluidas en presentación

***
* MODELO 1
reg tmi fa ${var1} acue nbi i.year, vce(cluster codmun)
estimates store mod1
* MODELO 2
xtreg tmi fa , fe
estimates store mod2
* MODELO 3
xtreg tmi fa  ${var1}, fe
estimates store mod3
* MODELO 4
xtreg tmi fa  ${var1} i.year, fe
estimates store mod4
* MODELO 5
xtreg tmi fa  ${var1} acue nbi, re
estimates store mod5

esttab mod1 mod2 mod3 mod4 mod5 using "${T}modelos", cells(b(fmt(5) star) se(fmt(5) par)) stats(r2_w, fmt(2)) starlevels(* 0.1 ** 0.05 *** 0.01) keep(fa)  ///
mlabels(, none) collabels("") type replace booktabs noobs

************
* Regiones*
***********
* Andina 
xtreg tmi fa ${var1} i.year if gandina==1, fe
estimates store andi
* Caribe
xtreg tmi fa ${var1} i.year if gcaribe==1, fe
estimates store cari
* Pacifica
xtreg tmi fa ${var1} i.year if gpacifica==1, fe
estimates store paci
* Orinoquia
xtreg tmi fa ${var1} i.year if gorinoquia==1, fe
estimates store orin
* Amazonia
xtreg tmi fa ${var1} i.year if gamazonia==1, fe
estimates store amaz

esttab andi cari paci orin amaz using "${T}modelos_region", cells(b(fmt(5) star) se(fmt(5) par)) stats(r2_w N_g, fmt(2 0)) starlevels(* 0.1 ** 0.05 *** 0.01) keep(fa)  ///
mlabels(, none) collabels("") type replace booktabs noobs

****************************
** TMI, NBI y rural previo**
****************************
* TMI
xtreg tmi fa ${var1} i.year if g_tmi==1, fe
estimates store tmi_alto
xtreg tmi fa ${var1} i.year if g_tmi==0, fe
estimates store tmi_bajo
* NBI
xtreg tmi fa ${var1} i.year if g_nbi==1, fe
estimates store nbi_alto
xtreg tmi fa ${var1} i.year if g_nbi==0, fe
estimates store nbi_bajo
* Ruralidad
xtreg tmi fa ${var1} i.year if g_rural==1, fe
estimates store rural_alto
xtreg tmi fa ${var1} i.year if g_rural==0, fe
estimates store rural_bajo

esttab tmi_alto tmi_bajo nbi_alto nbi_bajo rural_alto rural_bajo using "${T}modelos_nbi_rural_tmi", cells(b(fmt(5) star) se(fmt(5) par)) stats(r2_w N_g, fmt(2 0)) starlevels(* 0.1 ** 0.05 *** 0.01) keep(fa)  ///
mlabels(, none) collabels("") type replace booktabs noobs

** Modelos con tasa de mortalidad construida

xtreg inf_tot  L.fa ${var1} i.year, fe
xtreg inf_intes  L.fa ${var1} i.year, fe
xtreg inf_nutri  L.fa ${var1} i.year, fe
xtreg inf_resp  L.fa ${var1} i.year, fe
xtreg inf_preven  L.fa ${var1} i.year, fe
xtreg inf_perin  L.fa ${var1} i.year, fe
xtreg inf_exter  L.fa ${var1} i.year, fe


xtreg uf_tot  fa ${var1} i.year, fe
xtreg uf_intes  fa L.fa ${var1} i.year, fe
xtreg uf_nutri  fa L.fa ${var1} i.year, fe
xtreg uf_resp  L.fa ${var1} i.year, fe
xtreg uf_preven  L.fa ${var1} i.year, fe
xtreg uf_perin  L.fa ${var1} i.year, fe
xtreg uf_exter  L.fa ${var1} i.year, re














/** MODELO1: Incluyendo FA, vacunación, cobertura salud,educación de la madre, controles prenatales

* FE: TMI VS FA, Vacunación, cobertura salud, educación de la madre, controles prenatales
xtreg tmi fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons , fe
estimates store mod_1_fe
* BE: TMI VS FA, Vacunación, cobertura salud, educación de la madre, controles prenatales, Cobertura acueducto y alcantarillado, NBI
xtreg tmi fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons acue alcan nbi, be
estimates store mod_1_be
* RE: TMI VS FA, Vacunación, cobertura salud, educación de la madre, controles prenatales, Cobertura acueducto y alcantarillado, NBI
xtreg tmi fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons acue alcan nbi, re
estimates store mod_1_re

*** MODELO2: Incluyendo inversion en salud

* FE: TMI VS FA, Vacunación, cobertura salud, educación de la madre, controles prenatales, inversión en salud (per capita) y agua
xtreg tmi fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons invsalud_pc , fe
* RE: TMI VS FA, Vacunación, cobertura salud, educación de la madre, controles prenatales, Cobertura acueducto y alcantarillado, NBI, inversión en salud (per cápita)
xtreg tmi fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons acue nbi alcan invsalud_pc, re

*** MODELO3: Incluyendo prestadores de salud
* FE: TMI VS FA, Vacunación, cobertura salud, educación de la madre, controles prenatales, inversión en salud (per capita) y agua, Prestadores públicos y privados
xtreg tmi fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons invsalud_pc ips_pub ips_pri, fe
* RE: TMI VS FA, Vacunación, cobertura salud, educación de la madre, controles prenatales, Cobertura acueducto y alcantarillado, NBI, inversión en salud (per cápita)
xtreg tmi fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons acue nbi alcan invsalud_pc ips_pub ips_pri, re

*** MODELO4: Incluyendo Indice de desarrollo municipal, Indice de desempeño integral, ingresos tributarios y recursos sgp de salud y agua per cápita
* FE: TMI VS FA, Vacunación, cobertura salud, educación de la madre, controles prenatales, Prestadores públicos y privados, SGP salud, ingresos tributarios, Indice de desarrollo municipal
xtreg tmi fa vac_pol vac_dpt vac_bcg vac_hb cob_sub cob_cont edu cons ips_pub ips_pri idm idi ing sgp_salud, fe
estimates store mod4_fe
* RE: TMI VS FA, Vacunación, cobertura salud, educación de la madre, controles prenatales, Prestadores públicos y privados, SGP salud, ingresos tributarios, Indice de desarrollo municipal, Acueducto
xtreg tmi fa vac_pol vac_dpt vac_bcg vac_hb cob_sub cob_cont edu cons ips_pub ips_pri idm ing sgp_salud acue, re
estimates store mod4_re
** tmi calculos propios
gen excl=(codep==91 | codep==94 | codep==95 |codep==97 | codep==99 )
xtreg inf_tot fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons invsalud_pc ips_pub ips_pri , fe
xtreg inf_suav fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons invsalud_pc ips_pub ips_pri , fe
xtreg inf_suav fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons invsalud_pc ips_pub ips_pri if excl==0, fe

* FE: TMI VS FA, Vacunación, cobertura salud, educación de la madre, controles prenatales, Prestadores públicos y privados, SGP salud, ingresos tributarios, Indice de desarrollo municipal
xtreg inf_tot fa vac_pol vac_dpt vac_bcg vac_hb cob_sub cob_cont edu cons ips_pub ips_pri idm  ing sgp_salud, fe

xtreg inf_tot fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons acue nbi alcan invsalud_pc ips_pub ips_pri if excl==0, re

xtreg inf_nutri fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons invsalud_pc ips_pub ips_pri, fe
xtreg uf_tot fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons invsalud_pc ips_pub ips_pri if excl==0, fe

xtreg inf_intes fa vac_pol vac_dpt vac_bcg vac_hb cob_tot edu cons acue nbi alcan invsalud_pc ips_pub ips_pri, re


