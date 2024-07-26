/*
101 001//enfermedades infecciosas intestinales
104 004// Ciertas enfermedades prevenibles por vacuna
401-407 079-086// Afecciones originadas en el periodo perinatal
501-514 90-105// Causas externas
602 042// deficiencias nutricionales
605-608 059-062//  enfermedades respiratorias

*/
clear all
set pagesize 1000
set more off
global CL "E:\Dropbox\CLEAR\Datos\"
global B "${CL}bases\"
global P "E:\Datos\panel municipal uniandes\"
cd "$CL"

************************************************************************
***************MORTALIDAD POR CAUSA*************************************
************************************************************************

forvalues i=2006/2011{
import excel using "${B}mortalidad.xls", sheet(`i') firstrow clear

replace causa=substr(causa,1,3)
replace causa=causa[_n-1] if causa==""
drop if codmun=="" | codmun==" Total" | substr(codmun,-3,3)=="999" | substr(codmun,1,2)=="75"
destring codmun edad*, replace force

keep if causa=="001" | causa=="004" |  causa=="079" | causa=="080" ///
| causa=="081" |  causa=="082" | causa=="083" | causa=="084" | causa=="085" | ///
 causa=="086" | causa=="090" | causa=="091" | causa=="092" | causa=="093" | ///
  causa=="094" | causa=="095" | causa=="096" | causa=="097" | causa=="098" | ///
 causa=="099" | causa=="100" | causa=="101" |  causa=="102" |  causa=="103" | ///
  causa=="104" | causa=="105" |  causa=="042" |  causa=="059" |  causa=="060" | ///
   causa=="061" |  causa=="062"  | causa=="Tot"


levelsof causa, local(causa) clean
reshape wide edad*, i(codmun) j(causa) string

* Mortalidad todas las causas y causas especificas
foreach x of local causa{
egen m_neo_`x'=rowtotal(edad_1_`x' edad_2_`x')
egen m_inf_`x'=rowtotal(edad_1_`x' edad_2_`x' edad_3_`x' edad_4_`x')
egen m_uf_`x'=rowtotal(edad*`x')
}
*
order codmun m_neo* m_inf* m_uf*
foreach x in neo inf uf{
egen mort_`x'_intes_`i'=rowtotal(m_`x'_001) // Infecciones instestinales
egen mort_`x'_preven_`i'=rowtotal(m_`x'_004) // Prevenibles por vacunas
egen mort_`x'_perin_`i'=rowtotal(m_`x'_079-m_`x'_086) // periodo perinatal
egen mort_`x'_exter_`i'=rowtotal(m_`x'_090-m_`x'_105) // Causas externas
egen mort_`x'_nutri_`i'=rowtotal(m_`x'_042) // Deficiencias nutricionales
egen mort_`x'_resp_`i'=rowtotal(m_`x'_059-m_`x'_062) // Enfermedades respiratorias
egen mort_`x'_tot_`i'=rowtotal(m_`x'_Tot)
}
*

keep codmun mort_*

tempfile mortalidad_`i'

save `mortalidad_`i''

}
*
use `mortalidad_2006'

forvalues i=2007/2011{
merge 1:1 codmun using "`mortalidad_`i''", nogen
}
*
qui: mvencode _all, mv(0) override

tempfile mortalidad
save `mortalidad'

**********************************************************************
****NACIMIENTOS*******************************************************
**********************************************************************

forvalues i=1/2{
import excel using "${B}nacimientos.xls", sheet(`i') firstrow clear
drop if substr(codmun,-3,3)=="999" | substr(codmun,1,2)=="75"
destring, replace force
drop if codmun==.
qui: mvencode _all, mv(0) override
tempfile nac_`i'
save `nac_`i''
}
use `nac_1'
merge 1:1 codmun using `nac_2', nogen keep(3)
keep codmun nac_2006-nac_2011

**********************************************************************
********CALCULO TMI***************************************************
**********************************************************************
merge 1:1 codmun using `mortalidad', keep(3)

foreach x in neo inf uf{
foreach y in intes preven perin exter nutri resp tot{
forvalues i=2006/2011{
gen `x'_`y'_`i'=(mort_`x'_`y'_`i'/nac_`i')*1000
}
}
}
*
forvalues i=2006/2011{
egen media_`i'=mean(inf_tot_`i')
egen sd_`i'=sd(inf_tot_`i')
gen var_`i'=sd_`i'^2
gen w_`i'=var_`i'/(var_`i'+(media_`i'/nac_`i'))
gen inf_suav_`i'=w_`i'*inf_tot_`i'+(1-w_`i')*media_`i'
}
keep codmun neo_tot* inf* uf* nac_*

save "${B}tmi_causas", replace

**********************************************************************
* TMI DANE************************************************************
**********************************************************************

import excel "${B}tmi_dane.xls", first clear

destring codmun codep, replace
drop if codmun==0
save "${B}tmi_dane", replace

**********************************************************************
***NIVEL EDUCATIVO DE LA MADRE****************************************
**********************************************************************

import excel "${B}nacimientos_educacion.xls", sheet(1998_2007) first clear

replace codmun=codmun[_n-1] if codmun==""
drop if substr(codmun,-3,3)=="999" | substr(codmun,1,2)=="75"
drop if nivel_edu==""
egen educacion=group(nivel_edu), label
drop nivel_edu edu_1998-edu_2005

reshape wide edu_*, i(codmun) j(educacion)
destring codmun edu*, replace force
qui: mvencode _all, mv(0) override

forvalue i=2006/2007{
gen edu_`i'=100*(edu_`i'1+edu_`i'2+edu_`i'3+edu_`i'4)/edu_`i'8
}
*
tempfile edu_1
save `edu_1'
**
import excel "${B}nacimientos_educacion.xls", sheet(2008_2012) first clear
replace codmun=codmun[_n-1] if codmun==""
drop if substr(codmun,-3,3)=="999" | substr(codmun,1,2)=="75"
drop if nivel_edu==""
egen educacion=group(nivel_edu), label
drop nivel_edu edu_2012

reshape wide edu_*, i(codmun) j(educacion)
destring codmun edu*, replace force
qui: mvencode _all, mv(0) override

forvalue i=2008/2011{
gen edu_`i'=100*(edu_`i'8+edu_`i'10+edu_`i'1)/edu_`i'14
}
*

merge 1:1 codmun using `edu_1', nogen keep(3)
drop if codmun==0
save "${B}edu_madre", replace

**********************************************************************
***NÚMERO DE CONSULTAS PRENATALES*************************************
**********************************************************************
forvalues i=1/2{
import excel "${B}nacimientos_controles.xls", sheet(`i') first clear

replace codmun=codmun[_n-1] if codmun==""
drop if substr(codmun,-3,3)=="999" | substr(codmun,1,2)=="75"
capture drop cons_1998-cons_2005
capture drop cons_2012
replace ncons="40" if ncons=="0" & ncons[_n-1]!=""
replace ncons="tot" if ncons==" Total"
keep if ncons=="0" | ncons=="1" | ncons=="2" | ncons=="3" | ncons=="tot"

reshape wide cons*, i(codmun) j(ncons) string
destring codmun cons*, replace force
qui: mvencode _all, mv(0) override
tempfile cons_`i'
save `cons_`i''
}
merge 1:1 codmun using `cons_1', nogen keep(3)
drop if codmun==0
forvalue i=2006/2011{
gen cons_`i'=100*(cons_`i'_0 +cons_`i'_1+cons_`i'_2+cons_`i'_3)/cons_`i'_tot
}
*
save "${B}cons_madre", replace
***********************************************************************
*****VACUNACIÓN********************************************************
***********************************************************************

forvalues i=2006/2011{
import excel "${B}vacunacion", first sheet(`i') clear
keep codmun vac*
egen vac_pro_`i'=rowmean(vac*)
tempfile vac_`i'
save `vac_`i''
}
use `vac_2006'
forvalues i=2007/2011{
merge 1:1 codmun using `vac_`i'', nogen keep(3)
}
*
destring codmun, replace

save "${B}vacunacion", replace

***********************************************************************
****** COBERTURA DE SALUD**********************************************
***********************************************************************
foreach x in cont sub{
import excel "${B}cobertura_salud", first sheet(2007_`x') clear
replace codmun=codep+codmun
destring codmun, replace force
drop if codmun==.
drop codep
tempfile `x'
save ``x''
}
merge 1:1 codmun using "`cont'", nogen
merge 1:1 codmun using "${B}poblacion_colombia", nogen keepusing(total_2007) keep(3)
qui: mvencode _all, mv(0) override

gen cob_sub_2007=100*sub_2007/total_2007
gen cob_cont_2007=100*cont_2007/total_2007
gen cob_tot_2007=100*(sub_2007+cont_2007)/total_2007

tempfile cob_2007
save `cob_2007'

forvalues i=2008/2011{
import excel "${B}cobertura_salud", first sheet(`i') clear
destring codmun, replace
drop if codmun==.
qui: mvencode _all, mv(0) override

gen cob_sub_`i'=100*sub_`i'/pob_`i'
gen cob_cont_`i'=100*cont_`i'/pob_`i'
gen cob_tot_`i'=cob_sub_`i'+cob_cont_`i'

tempfile cob_`i'
save `cob_`i''
}
*
use `cob_2007'
forvalues i=2008/2011{
merge 1:1 codmun using `cob_`i'', nogen keep(3)
}
*
save "${B}cobertura_salud", replace

*********************************************************************
*******FAMILIAS EN ACCIÓN********************************************
*********************************************************************
set more off
import excel "${B}FA.xls", first sheet(tam_hogar) clear
destring codmun, replace
merge 1:1 codmun using "${B}poblacion_colombia", keepusing(total_2006 total_2007 total_2008 total_2009 total_2010 total_2011) keep(3) nogen
forvalues i=2006/2011{
gen hogar_`i'=total_`i'/tam_hogar
}
tempfile hogar
save `hogar'
*******************
forvalues i=2006/2011{
foreach x in desp sisb{
import excel "${B}FA.xls", first sheet(`i'_`x') clear
destring codmun, replace
tempfile `i'_`x'
save ``i'_`x''
}
}
*
use `2006_desp'
merge 1:1 codmun using `hogar', nogen
merge 1:1 codmun using `2006_sisb', nogen
egen fa_2006_tot=rowtotal(fa*2006)
gen fa_2006=100*fa_2006_tot/hogar_2006
forvalues i=2007/2011{
foreach x in desp sisb{
merge 1:1 codmun using ``i'_`x'', nogen keep(1 3)
}
egen fa_`i'_tot=rowtotal(fa*`i')
gen fa_`i'=100*fa_`i'_tot/hogar_`i'
}
*
save "${B}FA", replace



*********************************************************************
*******COBERTURA NBI,ACUEDUCTO, ALCANTARILLADO***********************
*********************************************************************
*********************************************************************

foreach x in nbi acue alcan{
import excel "${B}nbi_acue_alcan.xls", first sheet(`x') clear
forvalues i=2006/2011{
gen `x'_`i'=`x'
}
tempfile `x'
save ``x''
}
*
merge 1:1 codmun using `nbi', nogen keep(3)
merge 1:1 codmun using `acue', nogen keep(3)
destring codmun, replace
drop nbi acue alcan

save "${B}nbi_acue_alcan", replace

**********************************************************************
******** INVERSIÓN EN SALUD*******************************************
**********************************************************************
use codmpio ano inv_aguasani inv_en_salud inv_total using "${P}panel_fiscal", clear
rename ano year
rename codmpio codmun
reshape wide inv_aguasani inv_en_salud inv_total, i(codmun) j(year)

merge 1:1 codmun using "${B}poblacion_colombia", keepusing(total_2006 total_2007 total_2008 total_2009 total_2010)

forvalues i=2006/2010{
gen invsalud_pc_`i'=inv_en_salud`i'/total_`i'
gen invsalud_pr_`i'=100*inv_en_salud`i'/inv_total`i'
gen invaguasani_pr_`i'=100*inv_aguasani`i'/inv_total`i'
}
*
keep codmun invsalud* invaguasani* 
save "${B}inversion", replace



********************************************************************
************ PRESTADORES********************************************
********************************************************************
import excel "${B}prestadores_salud", first clear
keep if clpr_codigo==1
gen codmun=substr(codigo_habilitacion,1,5)
tostring fecha_apertura, replace
gen year=substr(fecha_apertura,1,4)
egen tipo=group(naturaleza), label
gen ips=0
keep codmun year tipo ips
collapse (count) ips, by(codmun year tipo)
destring year codmun, replace
reshape wide ips, i(codmun year) j(tipo)
reshape wide ips1 ips2 ips3, i(codmun) j(year)

egen ips_pub_2007=rowtotal(ips12002 ips12003 ips12004 ips12005 ips12006 ips12007 ips32002 ips32003 ips32004 ips32005 ips32006 ips32007)
egen ips_pri_2007=rowtotal(ips22002 ips22003 ips22004 ips22005 ips22006 ips22007)
egen ips_tot_2007=rowtotal(ips_pub_2007 ips_pri_2007)

local j=2007
local h=2007
forvalues i=2008/2011{
egen ips_pub_`i'=rowtotal(ips_pub_`j++' ips1`i' ips3`i')
egen ips_pri_`i'=rowtotal(ips_pri_`h++' ips2`i')
egen ips_tot_`i'=rowtotal(ips_pub_`i' ips_pri_`i')
}
*
keep codmun ips_* 
merge 1:1 codmun using "${B}poblacion_colombia", nogen keep(3) keepusing(total_2007 total_2008 total_2009 total_2010 total_2011)
forvalues i=2007/2011{
foreach x in pub pri tot{
replace ips_`x'_`i'=1000*ips_`x'_`i'/total_`i'
}
}
* posiblemente haya que corregir y agregar ceros a los que se agregaron
save "${B}prestadores_salud", replace

*********************************************************************
*** INDICE DE DESARROLLO MUNICIPAL***********************************
*********************************************************************
import excel "${B}idm.xls", first clear
destring codmun, replace
save "${B}idm", replace

********************************************************************
*** INGRESOS TRIBUTARIOS, SGP SALUD y AGUA**************************
********************************************************************
*Ingresos tributarios
import excel "${B}ingresos.xls", first clear
keep if cod_cue=="A1000"
drop cod_cue CUENTA2
destring, force replace
drop if ing_2011==.
tempfile ingresos
save `ingresos'
* SGP salud
import excel "${B}sgp_salud.xls", first clear
destring codmun, force replace
drop if codmun==.
tempfile sgp_salud
save `sgp_salud'
* SGP agua
import excel "${B}sgp_agua.xls", first clear
destring codmun, force replace
drop if codmun==.
tempfile sgp_agua
save `sgp_agua'
* 
use codmun total_2006-total_2011 using "${B}poblacion_colombia", clear
drop if codmun==0
merge 1:1 codmun using `ingresos', nogen keep(3)
merge 1:1 codmun using `sgp_salud', nogen keep(3)
merge 1:1 codmun using `sgp_agua', nogen keep(3)

foreach x in ing sgp_salud sgp_agua{
forvalues i=2006/2011{
replace `x'_`i'=`x'_`i'/total_`i'
}
}
*
keep codmun ing* sgp*

save "${B}ing_sgp", replace

*********************************************************************
**** INDICE DE DESEMPEÑO INTEGRAL************************************
*********************************************************************
import excel "${B}idi.xls", first clear
destring codmun idi, replace force
reshape wide idi_, i(codmun) j(year)
keep codmun idi_2007-idi_2011
save "${B}idi", replace
*********************************************************************
*** Indice de ruralidad y región*************************************
*********************************************************************
use "${P}panel_general", clear
use codmpio ano gandina gcaribe gpacifica gorinoquia gamazonia indrural using "${P}panel_general", clear
rename ano year
rename codmpio codmun
gen rural=indrural if year==2005
egen mean_rural=mean(rural), by(codmun)
keep if year<=2011 & year>=2007
gen g_rural=(mean_rural>0.5)
drop rural mean_rural
save "${B}rural_region", replace

*********************************************************************
********** Todas las variables***************************************
*********************************************************************

use codmun fa_2006 fa_2007 fa_2008 fa_2009 fa_2010 fa_2011 using "${B}FA", clear

merge 1:1 codmun using "${B}tmi_dane", nogen keep(3)
merge 1:1 codmun using "${B}tmi_causas", nogen keep(3)
merge 1:1 codmun using "${B}edu_madre", nogen keepusing(edu_2006 edu_2007 edu_2008 edu_2009 edu_2010 edu_2011) keep(3)
merge 1:1 codmun using "${B}cons_madre", nogen keepusing(cons_2006 cons_2007 cons_2008 cons_2009 cons_2010 cons_2011) keep(3)
merge 1:1 codmun using "${B}vacunacion", nogen keep(3)
merge 1:1 codmun using "${B}cobertura_salud", nogen keepusing(cob*) keep(3)
merge 1:1 codmun using "${B}nbi_acue_alcan", nogen keep(3)
merge 1:1 codmun using "${B}inversion", nogen keep(3)
merge 1:1 codmun using "${B}prestadores_salud", nogen keep(3)
merge 1:1 codmun using "${B}idm", nogen keep(3)
merge 1:1 codmun using "${B}ing_sgp", nogen keep(3)
merge 1:1 codmun using "${B}idi", nogen keep(3)

reshape long fa tmi neo_tot inf_intes inf_preven inf_perin inf_exter ///
inf_nutri inf_resp inf_tot inf_suav uf_intes uf_preven uf_perin uf_exter ///
uf_nutri uf_resp uf_tot nac edu cons vac_pol vac_dpt vac_bcg vac_hb vac_pro ///
cob_sub cob_cont cob_tot nbi acue alcan invsalud_pc invsalud_pr invaguasani_pr ips_pub ips_pri ips_tot ///
idm ing sgp_salud sgp_agua idi, i(codmun) j(year) string

destring year, i("_") replace
drop if year==2006
drop if codmun==0 | codmun==23670

merge 1:1 year codmun using "${B}rural_region", nogen keep(3)
merge m:1 codmun using "${B}tmi_dane", keep(3) keepusing(tmi_2006) nogen
merge m:1 codmun using "${B}nbi_acue_alcan", keep(3) keepusing(nbi_2006 acue_2006 alcan_2006) nogen

* Creando variable de niveles previos
* TMI
qui: summ tmi_2006, detail
gen g_tmi=(tmi_2006>=r(p50))

* Nbi
qui: summ nbi_2006, detail
gen g_nbi=(nbi_2006>=r(p50))
*
qui: summ acue_2006, detail
gen g_acue=(acue_2006>=r(p50))
*
qui: summ alcan_2006, detail
gen g_alcan=(alcan_2006>=r(p50))


xtset codmun year
label var tmi "Tasa de Mortalidad Infantil"
label var fa "Porcentaje de hogares en Familias en Acción"
label var edu "Porcentaje de madres con educación primaria o menos"
label var edu "Porcentaje de madres con menos de 4 controles prenatales"

save "${B}panel_tmi_fa", replace


