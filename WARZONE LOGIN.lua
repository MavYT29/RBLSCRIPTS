local v0=tonumber;local v1=string.byte;local v2=string.char;local v3=string.sub;local v4=string.gsub;local v5=string.rep;local v6=table.concat;local v7=table.insert;local v8=math.ldexp;local v9=getfenv or function() return _ENV;end ;local v10=setmetatable;local v11=pcall;local v12=select;local v13=unpack or table.unpack ;local v14=tonumber;local function v15(v16,v17,...) local v18=1;local v19;v16=v4(v3(v16,5),"..",function(v30) if (v1(v30,2)==81) then v19=v0(v3(v30,1,1));return "";else local v82=0;local v83;while true do if (v82==0) then v83=v2(v0(v30,16));if v19 then local v107=0;local v108;while true do if (v107==0) then v108=v5(v83,v19);v19=nil;v107=1;end if (v107==1) then return v108;end end else return v83;end break;end end end end);local function v20(v31,v32,v33) if v33 then local v84=0;local v85;while true do if (v84==(877 -(282 + 595))) then v85=(v31/((5 -3)^(v32-1)))%(((1642 -(1523 + 114)) -3)^(((v33-1) -(v32-(1 -0))) + 1)) ;return v85-(v85%(2 -(1 + 0))) ;end end else local v86=619 -(555 + 64) ;local v87;while true do if (v86==(931 -(857 + 74))) then v87=(570 -(367 + 201))^(v32-((1322 -394) -(214 + 713))) ;return (((v31%(v87 + v87))>=v87) and (1 + 0)) or (0 + 0) ;end end end end local function v21() local v34=0;local v35;while true do if (v34==(1066 -(68 + 997))) then return v35;end if (v34==(1270 -(226 + 1044))) then v35=v1(v16,v18,v18);v18=v18 + (4 -3) ;v34=118 -(32 + 84 + 1) ;end end end local function v22() local v36,v37=v1(v16,v18,v18 + 1 + 1 );v18=v18 + (959 -(892 + 65)) ;return (v37 * (610 -354)) + v36 ;end local function v23() local v38=0 -0 ;local v39;local v40;local v41;local v42;while true do if (v38==(1 -0)) then return (v42 * (16777566 -(87 + 263))) + (v41 * ((261187 -195471) -(67 + 113))) + (v40 * 256) + v39 ;end if (v38==0) then v39,v40,v41,v42=v1(v16,v18,v18 + 3 + 0 );v18=v18 + (9 -5) ;v38=1 + 0 ;end end end local function v24() local v43=(1382 -(44 + 386)) -(802 + 150) ;local v44;local v45;local v46;local v47;local v48;local v49;while true do if (v43==(1487 -(998 + 488))) then v46=2 -1 ;v47=(v20(v45,1 -(0 + 0) ,15 + 5 ) * (2^(1029 -(915 + 82)))) + v44 ;v43=2;end if (v43==(2 + 0)) then v48=v20(v45,(831 -(201 + 571)) -(1176 -(116 + 1022)) ,31);v49=((v20(v45,32)==(1 + 0)) and  -(1 -(0 -0))) or (1188 -(1069 + 118)) ;v43=3;end if (v43==0) then v44=v23();v45=v23();v43=2 -1 ;end if (v43==(6 -3)) then if (v48==(0 + 0)) then if (v47==(0 -0)) then return v49 * (0 + 0) ;else v48=792 -(368 + 423) ;v46=0 -0 ;end elseif (v48==(2065 -(10 + 8))) then return ((v47==(0 -0)) and (v49 * ((443 -(416 + 26))/(0 -0)))) or (v49 * NaN) ;end return v8(v49,v48-(440 + 583) ) * (v46 + (v47/((3 -1)^(490 -(145 + 293))))) ;end end end local function v25(v50) local v51;if  not v50 then v50=v23();if (v50==(0 + 0)) then return "";end end v51=v3(v16,v18,(v18 + v50) -(3 -2) );v18=v18 + v50 ;local v52={};for v66=1, #v51 do v52[v66]=v2(v1(v3(v51,v66,v66)));end return v6(v52);end local v26=v23;local function v27(...) return {...},v12("#",...);end local function v28() local v53=(function() return 0;end)();local v54=(function() return;end)();local v55=(function() return;end)();local v56=(function() return;end)();local v57=(function() return;end)();local v58=(function() return;end)();local v59=(function() return;end)();while true do if (v53~= #"{") then else local v91=(function() return 0;end)();local v92=(function() return;end)();while true do if (v91==(0 -0)) then v92=(function() return 0;end)();while true do if (v92~=(0 -0)) then else v58=(function() return v23();end)();v59=(function() return {};end)();v92=(function() return 1519 -(1191 + 327) ;end)();end if (v92==(1 + 0)) then for v112= #"\\",v58 do local v113=(function() return 0;end)();local v114=(function() return;end)();local v115=(function() return;end)();local v116=(function() return;end)();while true do if (v113~=1) then else v116=(function() return nil;end)();while true do if (v114~=(698 -(208 + 490))) then else local v240=(function() return 0 + 0 ;end)();local v241=(function() return;end)();while true do if (v240==(0 + 0)) then v241=(function() return 836 -(660 + 176) ;end)();while true do if (v241~=(1 + 0)) then else v114=(function() return  #"~";end)();break;end if ((202 -(14 + 188))==v241) then v115=(function() return v21();end)();v116=(function() return nil;end)();v241=(function() return 676 -(534 + 141) ;end)();end end break;end end end if (v114~= #"{") then else if (v115== #"~") then v116=(function() return v21()~=0 ;end)();elseif (v115==(1 + 1)) then v116=(function() return v24();end)();elseif (v115== #"xxx") then v116=(function() return v25();end)();end v59[v112]=(function() return v116;end)();break;end end break;end if (v113~=(0 + 0)) then else v114=(function() return 0 + 0 ;end)();v115=(function() return nil;end)();v113=(function() return 1;end)();end end end v57[ #"-19"]=(function() return v21();end)();v92=(function() return 3 -1 ;end)();end if (v92==2) then v53=(function() return 2;end)();break;end end break;end end end if (v53==2) then for v95= #"[",v23() do local v96=(function() return v21();end)();if (v20(v96, #"!", #"[")~=0) then else local v103=(function() return 0 -0 ;end)();local v104=(function() return;end)();local v105=(function() return;end)();local v106=(function() return;end)();while true do if (v103==0) then v104=(function() return v20(v96,2, #"91(");end)();v105=(function() return v20(v96, #"?id=",6);end)();v103=(function() return 1;end)();end if (2==v103) then if (v20(v105, #">", #"|")~= #"~") then else v106[5 -3 ]=(function() return v59[v106[2 + 0 ]];end)();end if (v20(v105,2 + 0 ,2)~= #"[") then else v106[ #"xxx"]=(function() return v59[v106[ #"91("]];end)();end v103=(function() return 3;end)();end if (v103==3) then if (v20(v105, #"19(", #"xxx")== #">") then v106[ #"0313"]=(function() return v59[v106[ #"0836"]];end)();end v54[v95]=(function() return v106;end)();break;end if ((397 -(115 + 281))==v103) then local v111=(function() return 0 -0 ;end)();while true do if (v111==1) then v103=(function() return 2 + 0 ;end)();break;end if ((0 -0)==v111) then v106=(function() return {v22(),v22(),nil,nil};end)();if (v104==(867 -(550 + 317))) then local v120=(function() return 0;end)();local v121=(function() return;end)();while true do if (v120~=0) then else v121=(function() return 0;end)();while true do if (v121==(0 -0)) then v106[ #"asd"]=(function() return v22();end)();v106[ #"?id="]=(function() return v22();end)();break;end end break;end end elseif (v104== #"~") then v106[ #"-19"]=(function() return v23();end)();elseif (v104==2) then v106[ #"asd"]=(function() return v23() -(2^16) ;end)();elseif (v104~= #"gha") then else local v317=(function() return 0 -0 ;end)();local v318=(function() return;end)();while true do if (0~=v317) then else v318=(function() return 0;end)();while true do if (v318==(0 -0)) then v106[ #"asd"]=(function() return v23() -((287 -(134 + 151))^16) ;end)();v106[ #".dev"]=(function() return v22();end)();break;end end break;end end end v111=(function() return 1666 -(970 + 695) ;end)();end end end end end end for v97= #"{",v23() do v55[v97-#"}" ]=(function() return v28();end)();end return v57;end if (v53==(0 -0)) then local v93=(function() return 1990 -(582 + 1408) ;end)();local v94=(function() return;end)();while true do if (v93==(0 -0)) then v94=(function() return 0 -0 ;end)();while true do if (1~=v94) then else v56=(function() return {};end)();v57=(function() return {v54,v55,nil,v56};end)();v94=(function() return 7 -5 ;end)();end if ((1826 -(1195 + 629))==v94) then v53=(function() return  #"]";end)();break;end if (v94==(0 -0)) then v54=(function() return {};end)();v55=(function() return {};end)();v94=(function() return 1;end)();end end break;end end end end end local function v29(v60,v61,v62) local v63=v60[1];local v64=v60[243 -(187 + (266 -212)) ];local v65=v60[(765 + 18) -(162 + 618) ];return function(...) local v68=v63;local v69=v64;local v70=v65;local v71=v27;local v72=1 + 0 ;local v73= -(1 + 0);local v74={};local v75={...};local v76=v12("#",...) -(1 -0) ;local v77={};local v78={};for v88=0 + 0 ,v76 do if (v88>=v70) then v74[v88-v70 ]=v75[v88 + (1637 -(1373 + 263)) ];else v78[v88]=v75[v88 + (1001 -((616 -165) + 549)) ];end end local v79=(v76-v70) + (1494 -(711 + 782)) ;local v80;local v81;while true do v80=v68[v72];v81=v80[1 -0 ];if (v81<=((28 -17) + 21)) then if ((v81<=(23 -8)) or (1390>3778)) then if (v81<=(11 -4)) then if (v81<=((6183 -4361) -(580 + 1239))) then if (v81<=(1074 -(1036 + 37))) then if ((v81>(1384 -(746 + 638))) or (2339<2003)) then local v122=v69[v80[2 + 1 ]];local v123;local v124={};v123=v10({},{__index=function(v224,v225) local v226=0 -0 ;local v227;while true do if (v226==(341 -(218 + 123))) then v227=v124[v225];return v227[1582 -(1535 + 46) ][v227[1 + 1 ]];end end end,__newindex=function(v228,v229,v230) local v231=0 + 0 ;local v232;while true do if ((432==432) and ((0 + 0)==v231)) then v232=v124[v229];v232[561 -(306 + 254) ][v232[1 + 1 ]]=v230;break;end end end});for v233=1 -0 ,v80[1794 -(1010 + 780) ] do v72=v72 + ((1689 -(55 + 166)) -(899 + 568)) ;local v234=v68[v72];if ((v234[1 + 0 ]==(130 -76)) or (1145>=1253)) then v124[v233-(604 -(268 + 335)) ]={v78,v234[1 + 2 ]};else v124[v233-(506 -(351 + (1634 -(641 + 839)))) ]={v61,v234[1459 -(282 + 1174) ]};end v77[ #v77 + (267 -(28 + 238)) ]=v124;end v78[v80[813 -(569 + 242) ]]=v29(v122,v123,v62);else local v126=1559 -(1381 + 178) ;local v127;while true do if (v126==((0 -0) -0)) then v127=v80[1 + 1 ];v78[v127]=v78[v127](v78[v127 + (1025 -((1003 -(36 + 261)) + 318)) ]);break;end end end elseif ((3418>2118) and (v81==(1253 -(721 + 530)))) then local v128=(2222 -951) -((1858 -(910 + 3)) + 326) ;local v129;local v130;local v131;local v132;while true do if (v128==(0 -(1368 -(34 + 1334)))) then v129=v80[2 + 0 ];v130,v131=v71(v78[v129](v13(v78,v129 + 1 + 0 ,v80[(271 + 432) -(271 + 429) ])));v128=(2 -1) + 0 ;end if (v128==(1501 -(1408 + 92))) then v73=(v131 + v129) -((845 + 242) -(461 + 625)) ;v132=1288 -(993 + (1979 -(1466 + 218))) ;v128=1 + 1 ;end if ((3066<=3890) and (v128==(1173 -(418 + 753)))) then for v287=v129,v73 do local v288=0 + 0 ;while true do if (v288==0) then v132=v132 + 1 + 0 ;v78[v287]=v130[v132];break;end end end break;end end else v78[v80[(1284 -(1035 + 248)) + 1 ]]=v62[v80[1 + 1 + 1 ]];end elseif (v81<=(3 + 2)) then if (v81==(2 + 2)) then for v236=v80[531 -(406 + 123) ],v80[1772 -(1749 + 20) ] do v78[v236]=nil;end else for v238=v80[628 -(512 + 114) ],v80[1 + 2 ] do v78[v238]=nil;end end elseif (v81==(1328 -(1249 + 73))) then do return;end elseif ((v78[v80[1 + 1 ]]~=v78[v80[1149 -(466 + 679) ]]) or (2998>=3281)) then v72=v72 + ((1150 -(556 + 592)) -1) ;else v72=v80[8 -5 ];end elseif ((v81<=((1932 -(20 + 1)) -(106 + 1794))) or (4649<=2632)) then if ((v81<=(3 + 6)) or (3860>4872)) then if (v81>(3 + 5)) then local v135=v80[1996 -(109 + 1885) ];v78[v135]=v78[v135](v13(v78,v135 + (2 -1) ,v80[(4 + 3) -4 ]));else do return v78[v80[817 -(35 + 63 + (1036 -(134 + 185))) ]];end end elseif (v81==(836 -((1935 -(549 + 584)) + (709 -(314 + 371))))) then local v137=114 -((812 -(329 + 479)) + 110) ;local v138;local v139;while true do if ((v137==((1552 -(478 + 490)) -(57 + 527))) or (3998==2298)) then v138=v80[1 + 1 ];v139={};v137=1428 -(41 + 1386) ;end if (v137==(1 + 0)) then for v289=104 -(17 + 86) , #v77 do local v290=0 -0 ;local v291;while true do if (v290==(0 + 0)) then v291=v77[v289];for v336=0 -0 , #v291 do local v337=0 -0 ;local v338;local v339;local v340;while true do if (v337==(166 -(122 + 44))) then v338=v291[v336];v339=v338[1 -0 ];v337=3 -2 ;end if (v337==(1 + (854 -(174 + 680)))) then v340=v338[2 + 0 ];if (((v339==v78) and (v340>=v138)) or (8>=2739)) then local v354=0 -0 ;while true do if ((0 + (1172 -(786 + 386)))==v354) then v139[v340]=v339[v340];v338[1 + 0 ]=v139;break;end end end break;end end end break;end end end break;end end else v72=v80[5 -2 ];end elseif (v81<=(78 -(30 + 35))) then if (v81==(9 + 3)) then local v141=0;local v142;local v143;local v144;while true do if (v141==(1257 -((3378 -2335) + 214))) then v142=v80[7 -5 ];v143={v78[v142](v78[v142 + (2 -1) ])};v141=2 -1 ;end if (v141==(581 -(361 + 219))) then v144=(1059 -(396 + 343)) -(53 + 267) ;for v292=v142,v80[1 + 1 + 2 ] do local v293=413 -((1492 -(29 + 1448)) + (1787 -(135 + 1254))) ;while true do if (v293==(982 -(18 + 964))) then v144=v144 + (3 -(1342 -(1093 + 247))) ;v78[v292]=v143[v144];break;end end end break;end end else local v145=0 + 0 ;local v146;while true do if (v145==(0 -0)) then v146=v80[7 -5 ];v78[v146](v78[v146 + 1 + 0 ]);break;end end end elseif (v81>(864 -((93 -73) + 830))) then v78[v80[2 + 0 ]]();else v78[v80[128 -(116 + 10) ]][v80[1 + 2 ]]=v80[(495 + 247) -(542 + 196) ];end elseif (v81<=(49 -26)) then if ((2590==2590) and (v81<=((1558 -(389 + 1138)) -12))) then if (v81<=(5 + 12)) then if (v81>((583 -(102 + 472)) + 7)) then local v149=0 + 0 ;local v150;while true do if ((v149==(0 -0)) or (82>=1870)) then v150=v80[4 -2 ];v78[v150](v13(v78,v150 + 1 + 0 ,v80[1554 -(1126 + 45 + 380) ]));break;end end else local v151=405 -(118 + (1139 -852)) ;local v152;while true do if (((0 -0) + 0)==v151) then v152=v80[7 -5 ];v78[v152]=v78[v152](v13(v78,v152 + (1122 -(118 + 1003)) ,v80[8 -5 ]));break;end end end elseif ((2624<4557) and (v81>(395 -(142 + 235)))) then v78[v80[9 -7 ]][v80[1 + 2 ]]=v78[v80[981 -(553 + 401 + 23) ]];else v78[v80[3 -1 ]]={};end elseif (v81<=21) then if (v81>20) then local v156=v80[2 + 0 ];local v157=v78[v80[3 + 0 ]];v78[v156 + 1 + 0 + 0 ]=v157;v78[v156]=v157[v80[2 + 2 ]];else v78[v80[2 + 0 ]]=v80[6 -3 ]~=0 ;end elseif (v81>(60 -38)) then v78[v80[4 -2 ]][v80[1 + 0 + 2 ]]=v78[v80[19 -(1560 -(320 + 1225)) ]];else v72=v80[756 -(239 + 514) ];end elseif ((v81<=(753 -(228 + (886 -388)))) or (3131>3542)) then if ((2577>=1578) and (v81<=(6 + 19))) then if (v81==(9 + (42 -27))) then if (v78[v80[1331 -(797 + 532) ]]==v80[3 + 1 ]) then v72=v72 + (2 -1) ;else v72=v80[1908 -(830 + (2701 -1626)) ];end else local v165=0 + 0 + 0 ;local v166;while true do if ((4103<=4571) and ((1269 -(231 + 1038))==v165)) then v166=v80[(3 + 1) -2 ];v78[v166](v78[v166 + (1203 -(373 + 829)) ]);break;end end end elseif (v81==((75 -53) + 4)) then if (v78[v80[733 -(476 + 255) ]]==v80[1134 -(369 + 761) ]) then v72=v72 + 1 + (1464 -(157 + 1307)) ;else v72=v80[5 -2 ];end else local v167=v80[3 -1 ];do return v78[v167](v13(v78,v167 + (239 -(64 + 174)) ,v80[1 + 2 ]));end end elseif (v81<=(42 -13)) then if (v81>(364 -(144 + 192))) then if (v78[v80[218 -(42 + 174) ]] or (1495==4787)) then v72=v72 + 1 + 0 + 0 ;else v72=v80[(1862 -(821 + 1038)) + 0 ];end else v78[v80[160 -(91 + 67) ]]={};end elseif (v81<=(13 + 17)) then local v169=1504 -((927 -564) + 1141) ;local v170;local v171;local v172;local v173;while true do if (v169==(1582 -(1183 + 397))) then for v294=v170,v73 do v173=v173 + (2 -(689 -(364 + 324))) ;v78[v294]=v171[v173];end break;end if (v169==(0 + (0 -0))) then v170=v80[2 + (0 -0) ];v171,v172=v71(v78[v170](v13(v78,v170 + (2 -(1 + 0)) ,v80[2 + 1 ])));v169=(1852 -1080) -((578 -252) + 445) ;end if ((v169==(1 + 0)) or (310>4434)) then v73=(v172 + v170) -(1976 -((4741 -2828) + (1088 -(834 + 192)))) ;v173=0 + 0 + 0 ;v169=5 -3 ;end end elseif (v81==(1964 -(565 + 1368))) then local v248=0 -0 ;local v249;local v250;while true do if (v248==(1661 -(1477 + 184))) then v249=v80[2 -(0 + 0) ];v250={};v248=1 -(0 + 0) ;end if (v248==1) then for v319=2 -1 , #v77 do local v320=v77[v319];for v326=0 + 0 , #v320 do local v327=0 + 0 ;local v328;local v329;local v330;while true do if ((2168<=4360) and (v327==(1 -0))) then v330=v328[(1373 -515) -(564 + 7 + 285) ];if ((v329==v78) and (v330>=v249)) then v250[v330]=v329[v330];v328[1813 -(1293 + 519) ]=v250;end break;end if (v327==((0 -0) -0)) then v328=v320[v326];v329=v328[1 -0 ];v327=2 -1 ;end end end end break;end end else v78[v80[306 -(244 + (182 -122)) ]]=v29(v69[v80[(1280 -(1249 + 19)) -9 ]],nil,v62);end elseif (v81<=((342 -(300 + 4)) + 11)) then if ((994==994) and (v81<=(516 -(11 + 30 + 435)))) then if ((1655>401) and (v81<=36)) then if (v81<=(1035 -(938 + 63))) then if ((3063<=3426) and (v81>(7 + (67 -41)))) then if (v80[2 + 0 ]==v78[v80[(1020 + 109) -((3643 -2707) + 189) ]]) then v72=v72 + (1087 -(686 + 400)) + 0 ;else v72=v80[1 + (364 -(112 + 250)) ];end else v78[v80[1615 -(1565 + 38 + 10) ]]=v61[v80[2 + (230 -(73 + 156)) ]];end elseif (v81>(1173 -(782 + 356))) then local v176=267 -(176 + 37 + 54) ;local v177;while true do if (v176==0) then v177=v80[4 -2 ];v78[v177](v13(v78,v177 + (1 -(0 + 0)) ,v80[1095 -(975 + (292 -175)) ]));break;end end elseif ((1459>764) and (v78[v80[(813 -(721 + 90)) + 0 ]]~=v78[v80[1879 -(157 + 1718) ]])) then v72=v72 + 1 + 0 ;else v72=v80[10 -7 ];end elseif (v81<=((74 + 55) -91)) then if (v81>(1055 -(697 + 321))) then local v178=v80[5 -3 ];local v179=v78[v80[5 -2 ]];v78[v178 + 1 + 0 ]=v179;v78[v178]=v179[v80[8 -4 ]];else local v183=0 + 0 + 0 ;local v184;local v185;local v186;while true do if (v183==2) then for v297=1 -0 ,v80[10 -(5 + 1) ] do local v298=1227 -(322 + 905) ;local v299;while true do if (v298==((1986 -1374) -(299 + 303 + 9))) then if ((v299[(885 + 305) -(449 + 740) ]==((2455 -(224 + 246)) -(609 + 1322))) or (641>4334)) then v186[v297-((1413 -540) -(826 + 46)) ]={v78,v299[1 + 2 ]};else v186[v297-(4 -3) ]={v61,v299[443 -(382 + 58) ]};end v77[ #v77 + (3 -2) ]=v186;break;end if (v298==(0 + 0)) then v72=v72 + (1 -(1414 -(1001 + 413))) ;v299=v68[v72];v298=2 -1 ;end end end v78[v80[1207 -(902 + 303) ]]=v29(v184,v185,v62);break;end if (v183==(1 + (0 -0))) then v186={};v185=v10({},{__index=function(v300,v301) local v302=0 -0 ;local v303;while true do if (v302==(0 -0)) then v303=v186[v301];return v303[1 + 0 ][v303[1692 -(1121 + 569) ]];end end end,__newindex=function(v304,v305,v306) local v307=214 -(22 + 192) ;local v308;while true do if (v307==(683 -(483 + 200))) then v308=v186[v305];v308[1][v308[1465 -(1404 + 59) ]]=v306;break;end end end});v183=2 + 0 + 0 ;end if (v183==(0 -0)) then v184=v69[v80[3 -0 ]];v185=nil;v183=766 -(468 + 297) ;end end end elseif ((3399>=2260) and (v81>(601 -(334 + 228)))) then do return v78[v80[(1 -0) + 1 ]];end else v78[v80[6 -(12 -8) ]]=v61[v80[6 -3 ]];end elseif ((v81<=(79 -35)) or (393>=4242)) then if (v81<=(12 + 30)) then if ((989<4859) and (v81>(277 -(141 + 95)))) then v78[v80[2 + 0 ]]=v29(v69[v80[670 -(89 + 578) ]],nil,v62);elseif (v78[v80[4 -2 ]] or (4795<949)) then v72=v72 + ((515 -(203 + 310)) -(2 -1)) ;else v72=v80[3];end elseif (v81>(11 + 32)) then do return;end else local v190=0 -0 ;local v191;while true do if ((3842==3842) and ((0 -0)==v190)) then v191=v80[2 + 0 ];v78[v191]=v78[v191](v13(v78,v191 + 1 + 0 ,v73));break;end end end elseif ((1747<=3601) and (v81<=(64 -18))) then if (v81>(27 + 18)) then v78[v80[(2158 -(1238 + 755)) -(92 + 5 + 66) ]]=v80[89 -(84 + 2) ];else v78[v80[(603 -(512 + 90)) + 1 ]][v80[(1910 -(1665 + 241)) -1 ]]=v80[4];end elseif (v81<=(812 -((2108 -(709 + 825)) + 191))) then v78[v80[2 + 0 ]]();elseif (v81>(9 + 39)) then local v255=0 -0 ;while true do if (v255==0) then v78[v80[2 + 0 ]]=v80[852 -(254 + 595) ]~=(126 -(55 + 71)) ;v72=v72 + (1 -0) ;break;end end elseif (v80[1792 -(573 + 1217) ]==v78[v80[10 -6 ]]) then v72=v72 + 1 + 0 ;else v72=v80[492 -((842 -385) + 32) ];end elseif ((v81<=((132 -41) -34)) or (804>4359)) then if (v81<=(992 -(714 + (942 -(373 + 344))))) then if (v81<=((1012 -(196 + 668)) -97)) then if (v81==(69 -19)) then v78[v80[1 + 1 ]]=v62[v80[3 -0 ]];else local v198=v80[808 -(118 + 688) ];v78[v198]=v78[v198](v13(v78,v198 + (49 -(25 + (90 -67))) ,v73));end elseif (v81>(26 + 26)) then local v200=(1648 -852) -(588 + 94 + 114) ;local v201;local v202;local v203;while true do if (v200==(1 + 0 + 0)) then v203=1886 -((2445 -1518) + 959) ;for v310=v201,v80[(841 -(171 + 662)) -4 ] do v203=v203 + (3 -2) ;v78[v310]=v202[v203];end break;end if (v200==((825 -(4 + 89)) -(16 + 716))) then v201=v80[2];v202={v78[v201](v78[v201 + (98 -(11 + 86)) ])};v200=2 -1 ;end end else local v204=0 + 0 ;local v205;while true do if (v204==(0 -0)) then v205=v80[607 -((1107 -791) + (1388 -(35 + 1064))) ];v78[v205]=v78[v205](v78[v205 + (286 -((768 -593) + 44 + 66)) ]);break;end end end elseif ((4670>=3623) and (v81<=(138 -83))) then if ((2065<2544) and (v81==(266 -(155 + 57)))) then v78[v80[(3284 -(35 + 1451)) -(503 + 1293) ]]=v78[v80[8 -(1458 -(28 + 1425)) ]];else v61[v80[(1996 -(941 + 1052)) + 0 ]]=v78[v80[2]];end elseif ((1311<=3359) and (v81==(310 -(79 + 168 + 7)))) then v78[v80[1063 -(810 + 251) ]]=v80[3 + (0 -0) ];else local v212=v80[2 + 0 ];do return v78[v212](v13(v78,v212 + 1 + 0 + (0 -0) ,v80[3 + 0 ]));end end elseif (v81<=(594 -(43 + 490))) then if ((2717<=3156) and (v81<=(792 -((1947 -(298 + 938)) + 22)))) then if (v81>(224 -166)) then v78[v80[861 -(240 + 619) ]]=v80[1 + 2 ]~=(0 -0) ;v72=v72 + 1 + 0 ;else local v214=1744 -(1344 + 189 + 211) ;local v215;while true do if (v214==(0 -(297 -(45 + 252)))) then v215=v80[(1261 -(233 + 1026)) + (1666 -(636 + 1030)) ];do return v13(v78,v215,v73);end break;end end end elseif (v81>(29 + 31)) then v78[v80[2 + 0 ]]=v80[3]~=(0 -0) ;else local v217=v80[1 + 1 ];v78[v217]=v78[v217]();end elseif (v81<=63) then if ((1081<4524) and (v81==((1136 -669) -(255 + 150)))) then local v219=0 -0 ;local v220;while true do if (v219==(0 + 0)) then v220=v80[2 + 0 ];do return v13(v78,v220,v73);end break;end end else v61[v80[12 -(442 -(114 + 319)) ]]=v78[v80[6 -4 ]];end elseif (v81<=(1803 -(404 + (1916 -581)))) then local v223=v80[408 -(183 + (285 -62)) ];do return v13(v78,v223,v223 + v80[3] );end elseif (v81==(1011 -(88 + 858))) then local v256=v80[1 + 1 ];v78[v256]=v78[v256]();else v78[v80[2 + 0 ]]=v78[v80[3 -0 ]];end v72=v72 + (790 -(392 + 374 + 23)) ;end end;end return v29(v28(),{},v17)(...);end return v15("LOL!2C3Q00028Q00026Q00F03F027Q004003073Q004D616B6554616203043Q004E616D6503053Q004C6F67696E03043Q0049636F6E03173Q00726278612Q73657469643A2Q2F2Q34382Q3334352Q3938030B3Q005072656D69756D4F6E6C790100030A3Q00412Q6453656374696F6E030D3Q004C6F67696E2053656374696F6E026Q000840030A3Q006C6F6164737472696E6703043Q0067616D6503073Q00482Q747047657403513Q00682Q7470733A2Q2F7261772E67697468756275736572636F6E74656E742E636F6D2F4D6176595432392F52424C534352495054532F726566732F68656164732F6D61696E2F6F72696F6E4755492E747874030A3Q004D616B6557696E646F7703193Q004B454E4A494520485542202D205741525A4F4E455B4650535D030B3Q00486964655072656D69756D030A3Q0053617665436F6E6669672Q01030C3Q00436F6E666967466F6C64657203093Q004F72696F6E5465737403103Q004D616B654E6F74696669636174696F6E030B3Q004B454E4A4945204855422103073Q00436F6E74656E7403253Q005741525A4F4E455B4650535D2053637269707473206D616465206279206B656E6A6965504803053Q00496D61676503043Q0054696D65026Q001440030C3Q00412Q6450617261677261706803073Q005761726E696E67038C3Q00416E7920612Q74656D70747320746F20637261636B206F72206D69737573652074686973204855422077692Q6C20726573756C7420696E2061207065726D616E656E742062616E2E20412Q6C206163746976697469657320617265206D6F6E69746F7265642C20616E642076696F6C61746F72732077692Q6C206661636520636F6E73657175656E6365732E03083Q005365637572697479037D3Q00546869732073797374656D20686173206275696C742D696E20736563757269747920666561747572657320746F2064657465637420756E617574686F72697A656420612Q63652Q732E204265207375726520746F20666F2Q6C6F77207468652072756C657320746F2061766F696420616E792070656E616C746965732E030A3Q00412Q6454657874626F7803093Q00456E746572204B657903073Q0044656661756C74030D3Q0054657874446973612Q7065617203083Q0043612Q6C6261636B026Q00104003093Q00412Q6442752Q746F6E030F3Q00496D706F7274616E74204E6F74657300633Q00122E3Q00014Q0004000100093Q00261A3Q00080001000200040B3Q000800012Q0004000300033Q00022A00036Q0004000400043Q00122E3Q00033Q00261A3Q00180001000300040B3Q0018000100022A000400013Q002026000A000200042Q001C000C3Q000300300E000C0005000600300E000C0007000800300E000C0009000A2Q0010000A000C00022Q00420005000A3Q002026000A0005000B2Q001C000C3Q000100300E000C0005000C2Q0010000A000C00022Q00420006000A3Q00122E3Q000D3Q000E300001003200013Q00040B3Q00320001001203000A000E3Q001203000B000F3Q002026000B000B001000122E000D00114Q001E000B000D4Q002B000A3Q00022Q0041000A000100022Q00420001000A3Q002026000A000100122Q001C000C3Q000400300E000C0005001300300E000C0014000A00300E000C0015001600300E000C001700182Q0010000A000C00022Q00420002000A3Q002026000A000100192Q001C000C3Q000400300E000C0005001A00300E000C001B001C00300E000C001D000800300E000C001E001F2Q0011000A000C000100122E3Q00023Q00261A3Q003D0001001F00040B3Q003D0001002026000A0009002000122E000C00213Q00122E000D00224Q0011000A000D0001002026000A0009002000122E000C00233Q00122E000D00244Q0011000A000D000100040B3Q0061000100261A3Q004D0001000D00040B3Q004D00012Q0042000A00034Q0041000A000100022Q00420007000A3Q002026000A000600252Q001C000C3Q000400300E000C00050026001013000C0027000700300E000C00280016000625000D0002000100012Q00363Q00073Q001013000C0029000D2Q0011000A000C00012Q0004000800083Q00122E3Q002A3Q00261A3Q00020001002A00040B3Q0002000100022A000800033Q002026000A0006002B2Q001C000C3Q000200300E000C00050006000625000D0004000100042Q00363Q00084Q00363Q00074Q00363Q00044Q00363Q00013Q001013000C0029000D2Q0011000A000C0001002026000A0005000B2Q001C000C3Q000100300E000C0005002C2Q0010000A000C00022Q00420009000A3Q00122E3Q001F3Q00040B3Q000200012Q001F8Q002C3Q00013Q00053Q00043Q00028Q00026Q00F03F03053Q007063612Q6C035Q001E3Q00122E3Q00014Q0004000100033Q00261A3Q00070001000100040B3Q0007000100122E000100014Q0004000200023Q00122E3Q00023Q00261A3Q00020001000200040B3Q000200012Q0004000300033Q00261A0001000A0001000100040B3Q000A0001001203000400033Q00022A00056Q000C0004000200052Q0042000300054Q0042000200043Q0006290002001700013Q00040B3Q001700010006290003001700013Q00040B3Q001700012Q0008000300023Q00040B3Q001D000100122E000400044Q0008000400023Q00040B3Q001D000100040B3Q000A000100040B3Q001D000100040B3Q000200012Q002C3Q00013Q00013Q00023Q0003083Q007265616466696C65030A3Q006B656E6A69652E6B657900053Q0012033Q00013Q00122E000100024Q001B3Q00014Q003A8Q002C3Q00017Q00013Q0003053Q007063612Q6C01053Q001203000100013Q00062500023Q000100012Q00368Q000D0001000200012Q002C3Q00013Q00013Q00023Q0003093Q00777269746566696C65030A3Q006B656E6A69652E6B657900053Q0012033Q00013Q00122E000100024Q002100026Q00113Q000200012Q002C3Q00019Q002Q0001024Q003F8Q002C3Q00017Q00043Q00028Q0003043Q0067616D6503073Q00482Q747047657403213Q00682Q7470733A2Q2F706173746562696E2E636F6D2F7261772F785746324B51374D01143Q00122E000100014Q0004000200023Q00261A000100020001000100040B3Q0002000100122E000300013Q00261A000300050001000100040B3Q00050001001203000400023Q00202600040004000300122E000600044Q00100004000600022Q0042000200043Q0006073Q000F0001000200040B3Q000F00012Q003B00046Q0014000400014Q0008000400023Q00040B3Q0005000100040B3Q000200012Q002C3Q00017Q00113Q00028Q00026Q00F03F030A3Q006C6F6164737472696E6703043Q0067616D6503073Q00482Q7470476574035D3Q00682Q7470733A2Q2F7261772E67697468756275736572636F6E74656E742E636F6D2F4D6176595432392F52424C534352495054532F726566732F68656164732F6D61696E2F54657374253230536372697074732532304755492E74787403103Q004D616B654E6F74696669636174696F6E03043Q004E616D6503073Q0053752Q63652Q7303073Q00436F6E74656E7403213Q004B65792069732076616C69642120457865637574696E67207363726970743Q2E03053Q00496D61676503173Q00726278612Q73657469643A2Q2F2Q34382Q3334352Q393803043Q0054696D65026Q00144003053Q00452Q726F7203173Q00496E76616C6964204B65792E2054727920616761696E2E002F4Q00218Q0021000100014Q00343Q000200020006293Q002600013Q00040B3Q0026000100122E3Q00014Q0004000100013Q00261A3Q00070001000100040B3Q0007000100122E000100013Q00261A000100140001000200040B3Q00140001001203000200033Q001203000300043Q00202600030003000500122E000500064Q001E000300054Q002B00023Q00022Q000F00020001000100040B3Q002E000100261A0001000A0001000100040B3Q000A00012Q0021000200024Q0021000300014Q000D0002000200012Q0021000200033Q0020260002000200072Q001C00043Q000400300E00040008000900300E0004000A000B00300E0004000C000D00300E0004000E000F2Q001100020004000100122E000100023Q00040B3Q000A000100040B3Q002E000100040B3Q0007000100040B3Q002E00012Q00213Q00033Q0020265Q00072Q001C00023Q000400300E00020008001000300E0002000A001100300E0002000C000D00300E0002000E000F2Q00113Q000200012Q002C3Q00017Q00",v9(),...);
