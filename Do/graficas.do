clear all
set pagesize 1000
set more off
global CL "E:\Dropbox\CLEAR\"
global B "${CL}datos\bases\"
global G "${CL}graficas\"
global T "${CL}tablas\"
cd "$CL"

***
use "${B}panel_tmi_fa", clear

**********************************
** Estadísticas descriptivas******
**********************************
estpost sum tmi inf_tot fa vac_pro edu cons ips_pub ips_pri idm idi ing sgp_salud, detail

esttab . using "${T}estadisticas_descriptivas", cells("count(label(Obs.)) mean(fmt(2) label(Media)) p50(fmt(2) label(Mediana)) sd(fmt(2) label(Desv. estándar)) min(fmt(2) label(Min)) max(fmt(2) label(Max))") nonum  replace booktabs type width(\textwidth) noobs

*************************************************************
preserve
collapse (mean) tmi (mean) fa, by(year)
label var tmi "Tasa de mortalidad infantil promedio"
label var fa "Porcentaje de hogares en Familias en Acción"
line tmi year,  graphregion(fcolor(white))  ///
xtitle("Año") ytitle("por mil nacidos vivos" " ", axis(1)) lcolor("red") lwidth("medthick")  yaxis(1) ///
|| line fa year, lcolor("midblue") lwidth("medthick") ytitle(" " "Porcentaje", axis(2)) yaxis(2) legend( label(1 "Tasa de mortalidad Infantil (eje izquierdo)") label(2 "Hogares en Familias en Accion (eje derecho)") cols(1)) ///
name("line_tmi_fa", replace) saving("${G}line_tmi_fa", replace)
graph export "${G}line_tmi_fa.png", name(line_tmi_fa) width(1200) height(800) replace	
restore
****************************************************************

scatter tmi fa || lfit tmi fa , ytitle("Tasa de mortalidad infantil") graphregion(fcolor(white)) legend(off) ///
name("scat_tmi_fa", replace) saving("${G}scat_tmi_fa", replace)
graph export "${G}scat_tmi_fa.png", name(scat_tmi_fa) width(1200) height(800) replace	

****************************************************************

scatter tmi fa if codmun==5001, ytitle("Tasa de mortalidad infantil") graphregion(fcolor(white)) legend(off) ///
name("med_tmi_fa", replace) saving("${G}med_tmi_fa", replace)
graph export "${G}med_tmi_fa.png", name(med_tmi_fa) width(1200) height(800) replace	

*****************************************************************
preserve
xtdata, fe
scatter tmi fa || lfit tmi fa , ytitle("Tasa de mortalidad infantil") graphregion(fcolor(white)) legend(off) ///
name("fe_tmi_fa", replace) saving("${G}fe_tmi_fa", replace)
graph export "${G}fe_tmi_fa.png", name(fe_tmi_fa) width(1200) height(800) replace	
restore

*******************************************************************





