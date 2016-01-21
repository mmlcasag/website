CREATE OR REPLACE PACKAGE BODY TEMPLATE is

  -- 11/11/2003 - Lucas - Rotinas padrao para montar as paginas
  -- 18/06/2004 - Lucas - Novas funcoes javascript no scripttests
  -- 19/11/2004 - Lucas - Funcao clearValue alterada - problema quando o valor era em branco em campos hidden

  /*********************************************************************************************************************/
  /* Variaveis globais internas do pacote */
  g_scriptrowcolors boolean := false;
  g_scripttests     boolean := false;
  g_scripttree      boolean := false;
  g_scripthtmledit  boolean := false;
  g_scriptcalendar  boolean := false;
  g_scriptsorttable boolean := false;
  g_tableID         varchar2(50) := null;

  /*********************************************************************************************************************/

  function c_tablerowcolor return varchar2 is
  begin
    return util.test(g_linhaimpar = 0,c_tableline01,c_tableline02);
  end;

  function c_tablerowclass return varchar2 is
  begin
    return util.test(g_linhaimpar = 0,'tdPar','tdImpar');
  end;

  /*********************************************************************************************************************/

  procedure style is
  begin
    owa_util.mime_header('text/css');
    htp.p('
body {
  font: 8pt arial;
  color: ' || c_fontallok || ';
  text-align: center;
  background-color: ' || c_bgcolor || ';
}
h1 {
  font: 12pt arial;
  font-weight: bold;
  color: ' || c_fontcolor || ';
  text-align: left;
}
p {
  font: 8pt arial;
  font-weight: normal;
  color: ' || c_fontallok || ';
}
td {
  font: 8pt arial;
  font-weight: normal;
  color: ' || c_fontcolor || ';
}
th {
  font: 8pt arial;
  font-weight: bold;
  color: ' || c_fontcolor || ';
}
.th {
  font: 8pt arial;
  font-weight: bold;
  color: ' || c_fontcolor || ';
}
a {
  font: 8pt arial;
  color:' || c_fontcolor || ';
  font-weight: normal;
  text-decoration: underline;
}
a:hover {
  font: 8pt arial;
  color:' || c_fontcolor || ';
  font-weight: normal;
  text-decoration: none;
}
.erro {
  font: 12pt arial;
  font-weight: bold;
  color: ' || c_fonterror || ';
  text-align: center;
}
.titulo {
  font: 12pt arial;
  font-weight: bold;
  color: ' || c_fontallok || ';
  text-align: center;
}
.formnumber {
  border-color: ' || c_inputborder || ';
  border-style: solid;
  border-width: 1px;
  text-align: right;
}
input, textarea, select{
  font: 8pt arial;
  font-weight: normal;
  color: ' || c_fontallok || ';

  border-color: ' || c_inputborder || ';
  border-style: solid;
  border-width: 1px;
}
.input_disabled{
  border-color: ' || c_inputborder || ';
  border-style: solid;
  border-width: 1px;
  background-color: #666666;
}
.buttons {
  background-image: url(/autocom/imagens/bgform.jpg);

  font-family: verdana, arial;
  font-size: 9;
  font-weight: bold;
  font-style: normal;
  border-width: 1px;
  border-color: #003399;

  cursor:pointer;
  color: #003399;
  margin: 0px;
  padding: 0px;
}
.tdImpar {
  background-color: '||c_tableline02||';
}
.tdPar {
  background-color: '||c_tableline01||';
}
');
  end;

  /*********************************************************************************************************************/

  procedure styles is
  begin
    htp.p('<link rel="stylesheet" href="template.style" type="text/css">');
  end;

  /*********************************************************************************************************************/

  function url_encode(data in varchar2) return varchar2 is
    v_data varchar2(32767);
  begin
    v_data := utl_url.escape(trim(data), TRUE, 'UTF-8'); -- note the use of TRUE
    v_data := replace(v_data, '%3A', ':');
    v_data := replace(v_data, '%2F', '/');
    v_data := replace(v_data, '%24', '$');
    v_data := replace(v_data, '%3F', '?');
    v_data := replace(v_data, '%3D', '=');
    v_data := replace(v_data, '%26', '&');
  v_data := replace(v_data, '%40', '@');
    return v_data;
  end;

  function url_decode(data in varchar2) return varchar2 is
  begin
    return utl_url.unescape(replace(data, '+', ' '), 'UTF-8');
  end;

  procedure redirect(p_page varchar2) is
    v_page varchar2(32767);
  begin
    --htp.meta('Refresh', null, '0;URL=' || p_page);
    v_page := url_encode(p_page);
    htp.p('<meta http-equiv="refresh" content="0;URL=' || v_page || '">');
    pageopen;
    htp.anchor(v_page,'[Continuar]');
    --pageend;
  end;

  /*********************************************************************************************************************/

  function scriptopen return varchar2 is
  begin
    return '<script language="javascript">';
  end;

  procedure scriptopen is
  begin
    htp.p(scriptopen);
  end;

  /*********************************************************************************************************************/

  function scriptclose return varchar2 is
  begin
    return '</script>';
  end;

  procedure scriptclose is
  begin
    htp.p(scriptclose);
  end;

  /*********************************************************************************************************************/

  function script(p_script varchar2) return varchar2 is
  begin
    return scriptopen||p_script||scriptclose;
  end;

  procedure script(p_script varchar2) is
  begin
    htp.p(script(p_script));
  end;

  /*********************************************************************************************************************/

  procedure scriptrowcolors is
  begin
    g_scriptrowcolors := true;
    htp.p('
var linhaover = "' || c_tablelnover || '";
var linhaclick = "' || c_tablelnclik || '";
function setcolor(obj, method){
  if (method=="over"){
    if(obj.style.backgroundColor.toUpperCase()!=linhaclick){
      cor_linha=obj.style.backgroundColor;
      obj.style.backgroundColor=linhaover;
    }
  }else if (method=="out"){
    if(obj.style.backgroundColor.toUpperCase()!=linhaclick){
      obj.style.backgroundColor=cor_linha;
    }
  }else if (method=="click"){
    if(obj.style.backgroundColor.toUpperCase()!=linhaclick){
      obj.style.backgroundColor=linhaclick;
    }else{
      obj.style.backgroundColor=obj.bgColor;
    }
  }
};
');
  end;

  /*********************************************************************************************************************/

  procedure show_scripttests is
  begin
    if not g_scripttests then
      g_scripttests := true;
      htp.p('<script language="JavaScript" src="template.scripttests"></script>');
    end if;
  end;

  /*********************************************************************************************************************/

  procedure scripttests is
  begin
    htp.p('
//CARACTERES DIVERSOS
var letrasmai = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
var letrasmin = "abcdefghijklmnopqrstuvwxyz";
var numeros   = "0123456789";
var emails    = letrasmin+"_."+numeros;
var telefones = "()-x "+numeros;
//CARACTERES ÚNICOS
var emailsc   = "@";
var moeda     = ",";
//MÁSCARAS
var datas     = "  /  /    ";
var horas     = "  :  ";

agt = navigator.userAgent.toLowerCase();
is_ie     = ((agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1));
is_opera  = (agt.indexOf("opera") != -1);
is_mac    = (agt.indexOf("mac") != -1);
is_mac_ie = (is_ie && is_mac);
is_win_ie = (is_ie && !is_mac);
is_gecko  = (navigator.product == "Gecko");

//VERIFICA SE A TECLA INFORMADA PODE SER INSERIDA NO OBJETO
function verifica_mascara(obj,str,strone,mask,mykey){
  //SE O CAMPO EH READONLY CAI FORA
  if (obj.readOnly) return false;

  if (document.selection){
      document.selection.createRange().text = "";
  }else if (obj.selectionStart || obj.selectionStart == "0"){
    var selectionStart = obj.selectionStart;
    var selectionEnd = obj.selectionEnd;
    obj.value = obj.value.substring(0, selectionStart) + obj.value.substring(selectionEnd);
    obj.setSelectionRange(selectionStart, selectionStart);
  }

  //VERIFICA TECLA EH IGUAL A MASCARA OU VALIDA EM "str" E "strone"
  if (mykey == mask.charAt(obj.value.length) && mykey != " " && mykey != "%") return true;
  if ((str+strone)!="" && (str+strone).indexOf(mykey) ==-1) return false;
  if (strone!="" && obj.value.indexOf(mykey)!=-1 && strone.indexOf(mykey)!=-1) return false;

  //VERIFICA MASCARA
  if(mask.charAt(0)=="%"){
    var mylength=0;
    var i=mask.length;
    while(i>0 && mylength==0){
      i--;
      if(obj.value.lastIndexOf(mask.charAt(i))!=-1) mylength=i;
    }
    obj.value=obj.value.substr(0,obj.value.length-mylength)+mykey+mask.substr(1,mask.length);
    return false;
  }

  if(mask.charAt(mask.length-1)=="%"){
    if(obj.value=="") obj.value=mask.substr(0,mask.indexOf("%"));
    return true;
  }

  var tam=obj.value.length;
  while (mask.charAt(tam) && mask.charAt(tam)!=" " && tam<=mask.length){
    if(mask.charAt(tam)!=" ") obj.value+=mask.charAt(tam);
    tam++;
  }
  if(mask.substr(tam+1,mask.length-tam).indexOf(" ")==-1 && tam<mask.length && mask.length-tam!=1){
    obj.value+=mykey+mask.substr(tam+1,mask.length-tam);
    return false;
  }

  if(obj.value.length<mask.length || mask.length==0) return true;
  if(obj.value.length>mask.length) obj.value=obj.value.substr(0,mask.length);
  return false;
}

//VERIFICA A MASCARA E RETORNA SE A TECLA PRESSIONADA PODE OU NÃO SER INCLUIDA NO OBJETO
function valida_tecla(obj,str,strone,mask) {
  eve = window.event;
  var code = eve.keyCode ? eve.keyCode : eve.charCode ? eve.charCode : eve.which ? event.which : void 0;
  if(code==8 || code==9 || code==13) return true;
  return verifica_mascara(obj,str,strone,mask,String.fromCharCode(code));
}

//VERIFICA A MASCARA E RETORNA SE A TECLA PRESSIONADA PODE OU NÃO SER INCLUIDA NO OBJETO
function maskedit(eve,obj,str,strone,mask) {
  var codesIE = new Array(8,9,13);
  var codesMZ = new Array(8,9,13,33,35,36,37,38,39,40,46,112,113,114,115,116,117,118,119,120,121,122,123);
  if (!eve) eve = window.event;
  var code;
  if (is_gecko){
    code = eve.keyCode;
    for (var li=0; li<codesMZ.length; li++) if(code == codesMZ[li]) return true;
    code = eve.charCode;
  }else{
    code = eve.keyCode ? eve.keyCode : eve.which ? eve.which : void 0;
    for (var li=0; li<codesIE.length; li++) if(code == codesIE[li]) return true;
  }
  return verifica_mascara(obj,str,strone,mask,String.fromCharCode(code));
}

//REMOVE A MASCARA DO CAMPO E RETORNA APENAS OS CARACTERES DIGITADOS
function remove_mascara(obj,str,strone,mask){
  if(mask.charAt(0)=="%"){
    var mylength=0;
    var i=mask.length;
    while(i>0 && mylength==0){
      i--;
      if(obj.value.lastIndexOf(mask.charAt(i))!=-1) mylength=i;
    }
    return obj.value.substr(0,obj.value.length-mylength);
  }

  if(mask.charAt(mask.length-1)=="%"){
    return obj.value.substr(mask.indexOf("%")+1,obj.value.length-mask.indexOf("%"));
  }

  var str="";
  for(var i=0;i<obj.value.length;i++) if(mask.charAt(i)==" ") str+=obj.value.charAt(i);
  if(str>mask.length) str=str.substr(0,mask.length);
  return str;
}

//RETIRA OS CARACTERES INFORMADOS DE UM CAMPO E INCLUI-OS EM OUTRO COM SUA RESPECTIVA MASCARA
function adiciona_mascara(obj,str,strone,mask,obj2,str2,strtone2,mask2) {
  var string=remove_mascara(obj2,str2,strtone2,mask2);
  obj.value="";
  var atual=0;
  var tamanho=string.length;
  while(atual<tamanho){
    if(verifica_mascara(obj,str,strone,mask,string.charAt(atual))) obj.value+=string.charAt(atual);
    atual++;
  }
  return true;
}

//FORMATA UM VALOR COM FORMATO "." PARA FORMATO ","
function emValor(valor, depois){
  if(!valor) valor = "0,00";
  if(""+depois=="undefined") depois = 2;
  valor = "" + valor;
  try{
    valor = valor.replace(".",",");
    if(valor.indexOf(",")==-1) valor = valor + ",0";

    var aux = valor.substring(valor.lastIndexOf(","),valor.lastIndexOf(",")+depois+1);
    valor = valor.substring(0,valor.lastIndexOf(","));
    while(valor.length>3){
      aux = "." + valor.substring(valor.length-3,valor.length) + aux;
      valor = valor.substring(0,valor.length-3);
    }
    valor = valor + aux;
  }catch(e){
    valor = "0,00";
  }
  if(depois==0) valor = valor.substring(0,valor.indexOf(","));
  else while(valor.indexOf(",")>=valor.length-depois) valor = valor + "0";
  return valor;
}
function formata_moeda(valor,antes,depois){
  var valor = emValor(valor,depois);
  while (valor.indexOf(",")<antes) valor="0"+valor;
  return valor;
}
function to_curr(valor,antes,depois){
  return formata_moeda(valor,antes,depois);
}


//FORMATA UM VALOR COM FORMATO "," PARA FORMATO "."
function emNumero(valor,depois){
  if(!valor) valor = "0,00";
  if(""+depois=="undefined") depois = 2;
  valor = "" + valor;
  try{
    while(valor.indexOf(".")>-1) valor = valor.replace(".","");
    valor = valor.replace(",",".");
    if(valor.indexOf(".")<0) valor += ".0";
    valor = valor.substring(0,valor.indexOf(".")+depois+1);
    if(valor=="") valor = 0.0;
    return eval("1*"+valor);
    //return Math.round(valor*Math.pow(10,depois))/Math.pow(10,depois);
  }catch(e){
    return "isNaN";
  }
}
function formata_valor(valor,depois){
  return emNumero(valor,depois);
}
function to_number(valor,depois){
  return emNumero(valor,depois);
}

//REDIRECIONA PARA O ENDERECO
function redirect(url){
  location.href = url;
  return true;
}

//ABRE UMA NOVA TELA E POE O FOCO NELA
function WindowOpen(url, name, values){
  obj = window.open(url, name, values);
  obj.focus();
  return obj;
}

//FECHA UMA JANELA
function WindowClose(obj){
  if(!isnull(obj))
    if(!obj.closed)
      obj.close();
  return true;
}

//RETORNA OS VALORES DA LOV(LIST OF VALUES)
function ReturnLOV(obj,lov,index){
  if(obj[0].name){
    for(var li=0;li<lov.length;li++){
      eval("opener.document.forms[0]."+obj[li].value+(isundef(index)?"":"["+index+"]")+".value=lov[li];");
    }
  }else{
    for(var li=0;li<lov.length;li++){
      eval("opener.document.forms[0]."+obj[li]+(isundef(index)?"":"["+index+"]")+".value=lov[li];");
    }
  }
  window.close();
  return false;
}

//SELECIONA TODOS OS CHECKBOX DA LISTA
function checkAll(obj, checked, grupo){
  if (isundef(obj)) return false;
  else{
    if (isundef(obj.length)) {
      obj.nodeName;
      if (isundef(grupo) || obj.grupo == grupo) obj.checked = checked;
    }else{
      for(var c=0;c<obj.length;c++){
        obj[c].nodeName;
        if (isundef(grupo) || obj[c].grupo == grupo) obj[c].checked = checked;
      }
    }
    return true;
  }
}

//RETORNA UMA STRING SEPARADA POR DEM COM OS VALORES DO ARRAY OBJ
function checkRespostas(obj,dem){
  if (isundef(obj))  return "";
  else{
    var st = "";
    if (isundef(obj.length)) st+=(obj.checked?obj.value:"");
    else for(var li=0;li<obj.length;li++) st+=(obj[li].checked?obj[li].value+dem:"");
    return st;
  }
}

//VERIFICA SE O CAMPO TEXT ESTÁ EM BRANCO
function isnull(str){ return (str+"" == "null"); }
function isundef(str){ return (str+"" == "undefined"); }
function isblank(str){
  return (str+"" == "") || (str+"" == ".") || (str+"" == " ");
/*
  var invalid = " .\n\t";
  for(var li=0;li<str.length;li++) {
    if(invalid.indexOf(str.charAt(li)) != -1) return false;
  }
  return true;
*/
}

//VERIFICA SE O CAMPO TEXT ESTÁ EM BRANCO
function verifica_obj_text(obj,desc){
  if (isnull(obj.value) || isundef(obj.value) || ""+obj.value == "") {
    alert("Preencha o campo "+desc+"!");
    obj.focus();
    return false;
  }
  if (isblank(obj.value)) {
    alert("Preencha corretamente o campo "+desc+"!");
    obj.focus();
    return false;
  }
  return true;
}

//VERIFICA SE O NUMERO DE CARACTERES DO CAMPO NAO EXCEDE O LIMITE
function verifica_obj_leng(obj,desc,tam){
  if (obj.value.length>tam) {
    alert("O número de caracteres excedeu o limite no campo "+desc+"!");
    obj.focus();
    return false;
  } else return true;
}

//VERIFICA SE O CAMPO LIST ESTÁ EM BRANCO
function verifica_obj_list(obj,desc){
  if (isblank(obj.value)) {
    alert("Selecione o campo "+desc+"!");
    obj.focus();
    return false;
  } else return true;
}

//VERIFICA SE O CAMPO RADIO ESTÁ MARCADO
function verifica_obj_lrad(obj,desc){
  for(var li=0;li<obj.length;li++){
    if(obj[li].checked) return true;
  }
  alert("Selecione o campo "+desc+"!");
  obj[0].focus();
  return false;
}

//VERIFICA SE A LISTA DE CHECKBOX TEM X MARCACOES MINIMAS OU EXATAS
function verifica_obj_lchk(obj,desc,test){
  var count = 0;
  var flag = false;
  for(var li=0;li<obj.length;li++)
    if(obj[li].checked) count++;
  if(!test) test="count>0";
  eval("flag="+test+";");
  if(!flag){
    alert("Marque corretamente o campo "+desc+"!");
    obj[0].focus();
  }
  return flag;
}

//VERIFICA SE O CAMPO EMAIL FOI PREENCHIDO CORRETAMENTE
function verifica_obj_email(obj,desc) {
  if (!verifica_obj_text(obj,desc)) {
    return false;
  } else
  if((obj.value.indexOf("@")<2)||(obj.value.substring(obj.value.indexOf("@")+1,obj.value.length).indexOf(".")<2) ||
     (obj.value.indexOf("@") != obj.value.lastIndexOf("@"))||(obj.value.lastIndexOf(".")>=obj.value.length-2)){
       alert("Preencha corretamente o campo "+desc+"!");
       obj.focus();
       return false;
  } else return true;
}

//VERIFICA SE O CAMPO DATA FOI PREENCHIDO CORRETAMENTE
function verifica_obj_data(obj,desc) {
  if (obj.value.length != 0){
    var meses = new Array(31,29,31,30,31,30,31,31,30,31,30,31);
    if (!verifica_obj_text(obj,desc)) {
      return false;
    };

    if (obj.value.length==5) obj.value = obj.value + "/2004";
    if (obj.value.length<10 && obj.value.substr(1,1)=="/") obj.value = "0"+obj.value;
    if (obj.value.length<10 && obj.value.substr(4,1)=="/") obj.value = obj.value.substr(0,3)+"0"+obj.value.substr(3);
    if (obj.value.length==8 && obj.value.substr(2,1)=="/" && obj.value.substr(5,1)=="/") obj.value = obj.value.substr(0,6)+"20"+obj.value.substr(6);

    if (obj.value.substr(2,1)!="/" || obj.value.substr(5,1)!="/" || isNaN(obj.value.substr(0,2)) || isNaN(obj.value.substr(3,2)) || isNaN(obj.value.substr(6,4))){
      alert("Preencha corretamente o campo "+desc+"!");
      obj.focus();
      return false;
    };
    if (0+obj.value.substr(6,4)<1900 || 0+obj.value.substr(6,4)>2015){
      alert("Ano inválido no campo "+desc+"!");
      obj.focus();
      return false;
    };
    if (0+obj.value.substr(3,2)<1 || 0+obj.value.substr(3,2)>12){
      alert("Mês inválido no campo "+desc+"!");
      obj.focus();
      return false;
    };
    if (0+obj.value.substr(0,2)<1 || 0+obj.value.substr(0,2)>31 || 0+obj.value.substr(0,2) > meses[obj.value.substr(3,2)-1]){
      alert("Dia inválido para o mês especificado no campo "+desc+"!");
      obj.focus();
      return false;
    };
  }
  return true;
}

//VERIFICA SE O CAMPO HORA FOI PREENCHIDO CORRETAMENTE
function verifica_obj_hora(obj,desc) {
  if (!verifica_obj_text(obj,desc)) {
    return false;
  };

  if (obj.value.length<=2) obj.value = obj.value + ":00";
  if (obj.value.length<5 && obj.value.substr(1,1)==":") obj.value = "0"+obj.value;
  if (obj.value.length<5 && obj.value.substr(2,1)==":") obj.value = obj.value.substr(0,3)+"0"+obj.value.substr(3);

  if (obj.value.substr(2,1)!=":" || isNaN(obj.value.substr(0,2)) || isNaN(obj.value.substr(3,2)) ||
      0+obj.value.substr(0,2)<0 || 0+obj.value.substr(0,2)>23 || 0+obj.value.substr(3,2)<0 || 0+obj.value.substr(3,2)>59) {
    alert("Preencha corretamente o campo "+desc+"!");
    obj.focus();
    return false;
  };
  return true;
}

//TRANSFORMA STRING EM DATA
function parseDate(_str){
   var br1 = _str.indexOf("/");
   var br2 = _str.indexOf("/",br1+1);
   var dia = _str.substring(0,br1);
   var mes = _str.substring(br1+1,br2);
   var ano = _str.substring(br2+1);
   return (new Date(parseFloat(ano),parseFloat(mes)-1,parseFloat(dia)));
}

//DIFERENCA ENTRE A DATA1(MENOR) PARA A DATA2(MAIOR)
function y2k(number){
   return (number < 1000) ? number + 1900 : number;
}
function diffDate(date1,date2){
   var difference =
      Date.UTC(y2k(date2.getYear()),date2.getMonth(),date2.getDate(),0,0,0) -
      Date.UTC(y2k(date1.getYear()),date1.getMonth(),date1.getDate(),0,0,0);
   return difference/1000/60/60/24;
}

//VERIFICA SE OS CAMPOS DATA ESTÃO CORRETOS
function verifica_obj_dates(date1,date2) {
  if(diffDate(parseDate(date1.value),parseDate(date2.value))<0){
    alert("A data de término não podem ser menor que a data de início!");
    date2.focus();
    return false;
  }
  return true;
}
function verifica_obj_times(time1,time2) {
  if (time1.value>time2.value){
    alert("A hora de término não podem ser menor que a hora de início!");
    time2.focus();
    return false;
  }
  return true;
}

function cut(p_string, p_delimit, p_posicao){
  if(!p_posicao) p_posicao=0;
  var v_index = p_string.toUpperCase().indexOf(p_delimit.toUpperCase());
  if(v_index<0){
    if(p_posicao == 0){
      return p_string;
    }else{
      return "";
    }
  }else
  if(p_posicao<0){
    return p_string.substring(0,p_string.toUpperCase().indexOf(p_delimit.toUpperCase(),p_posicao));
  }else
  if(p_posicao==0){
    return p_string.substring(0,v_index);
  }else{
    return cut(p_string.substring(v_index+p_delimit.length),p_delimit,p_posicao-1);
  }
}

function clearValue(v){
  var i = v.indexOf("<");
  if (i < 0) return v;

  var r = v.substring(0,i);
  var p = v.substring(i);
  var s = "";
  while(i >= 0){
    i = p.indexOf("<",1);
    if(i>-1){
      s = p.substring(0,i);
      p = p.substring(i);
    }else{
      s = p;
      p = "";
    }
    var u = s.toUpperCase();
    //OPTION DO SELECT
    if(u.indexOf("<OPTION ") >= 0){
      ind = u.indexOf(" SELECTED");
      if (ind < 0) r += s;
      else r += s.substring(0,ind) + s.substring(ind+9);
    }else
    //CHECKBOX
    if(u.indexOf(" TYPE=\"CHECKBOX\"") >= 0 || u.indexOf(" TYPE=CHECKBOX") >= 0){
      ind = u.indexOf(" CHECKED");
      if (ind < 0) r += s;
      else r += s.substring(0,ind) + s.substring(ind+8);
    }else
    //TEXT
    if(u.indexOf(" TYPE=\"TEXT\"")   >= 0 || u.indexOf(" TYPE=TEXT")   >= 0 ||
       u.indexOf(" TYPE=\"HIDDEN\"") >= 0 || u.indexOf(" TYPE=HIDDEN") >= 0 ||
       u.indexOf(" TYPE=")           == -1){
      ind = u.indexOf(" VALUE=");
      if (ind >= 0) {
        r += s.substring(0, ind);
        s = s.substring(ind+7);
        if (s.substring(0,1) == "''"){
          s = s.substring(s.indexOf("''",1)+1);
        }else
        if (s.substring(0,1) == "\""){
          s = s.substring(s.indexOf("\"",1)+1);
        }else
        if(s.indexOf(">") < s.indexOf(" ")){
          s = s.substring(s.indexOf(">"));
        }else{
          s = s.substring(s.indexOf(" "));
        }
      }
      r += s;
    }else{
    //OUTROS (select,button,radio,etc)
      r += s;
    }
  }
  return r;
}



function copyLine(ptable){
  var g_linhas=ptable.rows.length-1;
  ptable.insertRow(g_linhas);
  ptable.rows[g_linhas].bgColor=ptable.rows[g_linhas-1].bgColor;
  for(var li=0;li<ptable.rows[g_linhas-1].cells.length;li++){
    ptable.rows[g_linhas].insertCell(li);
    ptable.rows[g_linhas].cells[li].className=ptable.rows[g_linhas-1].cells[li].className;
    ptable.rows[g_linhas].cells[li].align    =ptable.rows[g_linhas-1].cells[li].align;
    ptable.rows[g_linhas].cells[li].innerHTML=clearValue(ptable.rows[g_linhas-1].cells[li].innerHTML);
  }
  return ptable.rows[g_linhas];
}

function copyCols(ptable){
  var v_linhas=ptable.rows.length-1;
  var v_colunas=ptable.rows[1].cells.length;
  ptable.rows[0].cells[ptable.rows[0].cells.length-1].colSpan++;
  ptable.rows[v_linhas].cells[ptable.rows[v_linhas].cells.length-1].colSpan++;
  for(var li=1;li<=v_linhas-1;li++){
    ptable.rows[li].insertCell(v_colunas);
    ptable.rows[li].cells[v_colunas].className=ptable.rows[li].cells[v_colunas-1].className;
    ptable.rows[li].cells[v_colunas].align    =ptable.rows[li].cells[v_colunas-1].align;
    ptable.rows[li].cells[v_colunas].innerHTML=clearValue(ptable.rows[li].cells[v_colunas-1].innerHTML);
  }
}

function delLine(eve,pmin){
  if(!pmin) pmin = 3;
  if(is_ie){
    var vrow=window.event.srcElement;
    while ((vrow=vrow.parentElement)&&vrow.tagName!="TR");
    var vtable = vrow;
    while ((vtable=vtable.parentElement)&&vtable.tagName!="TABLE");
    if(vtable.rows.length>pmin) vrow.parentElement.removeChild(vrow);
  }else{
    var vrow=eve.target;
    while ((vrow=vrow.parentNode)&&vrow.tagName!="TR");
    var vtable = vrow;
    while ((vtable=vtable.parentNode)&&vtable.tagName!="TABLE");
    if(vtable.rows.length>pmin) vrow.parentNode.removeChild(vrow);
  }
}

function removeHTML(st){
  return st.replace(/(\< *[^\>]*\>|\&nbsp\;)/g, "");
}

function trim(st){
  return st.replace(/^\s*|\s*$/g, "");
}
');
  end;

  /*********************************************************************************************************************/

  procedure heading(p_title varchar2) is
  begin
    htp.header(1,p_title || '<hr>');
  end;

  /*********************************************************************************************************************/

  procedure pageopen(p_title varchar2 default null,p_transacao number default null) is
  begin
    if p_transacao is not null and not util.val_acesso_user(p_transacao) then
      raise login_denied;
    end if;
    htp.p('<meta http-equiv="Pragma" content="no-cache">');
    htp.p('<meta http-equiv="expires" content="0">');
    htp.htmlopen;
    htp.headopen;
    if p_title is not null then
      htp.title(p_title);
    end if;
    styles;
    htp.headclose;
    --htp.bodyopen(cattributes=>'onload="setInputStyles();"');
    htp.bodyopen;
    if p_title is not null then
      heading(p_title);
      htp.para;
    end if;
  end;

  /*********************************************************************************************************************/

  procedure pageend is
  begin
  scriptinputstyle;
    htp.bodyclose;
    htp.htmlclose;
  end;

  /*********************************************************************************************************************/

  procedure pageclose(p_links util.tarray default null) is
  begin
    htp.br;
    if p_links is not null then
      for li in p_links.first .. p_links.last loop
        htp.p(p_links(li) || ' ');
      end loop;
    end if;
    script('if (opener) document.write(''' || htf.anchor('javascript:this.close();','[Fechar]') || '''); else document.write(''' || htf.anchor('javascript:history.go(-1);','[Retornar]') || ''');');
    pageend;
  end;

  /*********************************************************************************************************************/

  procedure centermsg(p_message varchar2) is
  begin
    htp.p(htf.centeropen || '<b>' || p_message || '</b>' || htf.centerclose);
  end;

  /*********************************************************************************************************************/

  procedure errormsg(p_message varchar2) is
  begin
    htp.p(htf.centeropen || '<font color="' || c_fonterror || '"><b>' || p_message || '</b></font>' || htf.centerclose);
  end;

  /*********************************************************************************************************************/

  procedure coluns(p_type char,p_array util.tarray,p_others varchar2 default null) is
  begin
    g_numcols := p_array.count;
    for li in p_array.first .. p_array.last loop
      if p_type = 'T' or (p_type = 'F' and li mod 2 = 1) then
        if lower(nvl(util.cut(p_array(li),'||',1),'')) in ('right','left','center') then
          tableheader(util.cut(p_array(li),'||',0),util.cut(p_array(li),'||',1),null,null,null,null,p_others || ' ' || util.cut(p_array(li),'||',2));
        else
          tableheader(util.cut(p_array(li),'||',0),util.test(p_type='F','right'),null,null,null,null,p_others || ' ' || util.cut(p_array(li),'||',1));
        end if;
      elsif p_type = 'D' or (p_type = 'F' and li mod 2 = 0) then
        if lower(nvl(util.cut(p_array(li),'||',1),'')) in ('right','left','center') then
          htp.tabledata(util.cut(p_array(li),'||',0),util.cut(p_array(li),'||',1),null,null,null,null,p_others || ' ' || util.cut(p_array(li),'||',2));
        else
          htp.tabledata(util.cut(p_array(li),'||',0),null,null,null,null,null,p_others || ' ' || util.cut(p_array(li),'||',1));
        end if;
      end if;
    end loop;
  end;

  /*********************************************************************************************************************/

  procedure tablestart(p_others varchar2 default null) is
    strpos number := nvl(instr(p_others,'align='),0);
  begin
    htp.tableopen(null,util.test(strpos = 0,'center'),null,null,
                   'bgcolor="' || c_tableborder || '" cellpadding="2" cellspacing="1" ' || p_others);
  end;

  /*********************************************************************************************************************/

  procedure tableopen(p_attributes varchar2 default null) is
  begin
    if not g_scriptrowcolors then
      g_scriptrowcolors := true;
      htp.p('<script language="JavaScript" src="template.scriptrowcolors"></script>');
    end if;
    tablestart(p_attributes);
  end;

  /*********************************************************************************************************************/

  procedure tableopen(p_array util.tarray,
                      p_attributes varchar2 default null,
                      p_tableID varchar2 default null,
                      p_nullParam varchar2 default null --não usado, declarado apenas para não invalidar packages antigas
                      ) is
  begin
    if p_tableID is not null then
      if not g_scriptsorttable then
        show_scripttests;
        g_scriptsorttable := true;
        htp.p('<script language="JavaScript" src="/autocom/scripts/sortTable.js"></script>');
      end if;
      g_tableID := p_tableID;
    end if;
    tableopen(p_attributes||util.test(p_tableID is not null, ' id="'||p_tableID||'"'));
    if p_tableID is not null then
      htp.p('<THEAD>');
    end if;
    htp.tablerowopen('center','middle',null,null,'bgcolor="' || c_tableheader || '"');
    coluns('T',p_array);
    htp.tableRowClose;
    if p_tableID is not null then
      htp.p('</THEAD>');
    end if;
  end;

  /*********************************************************************************************************************/

  procedure tableclose(p_numcols number default null) is
  begin
    if p_numcols is null or p_numcols > 0 then
      tabletitle(p_numcols);
    end if;
    htp.tableclose;
    if g_tableID is not null then
      script('initTable('''||g_tableID||''')');
      g_tableID := null;
    end if;
  end;

  /*********************************************************************************************************************/

  procedure tabletitleopen(p_others varchar2 default null) is
  begin
    htp.tablerowopen('center','middle',null,null,'bgcolor="' || c_tableheader || '" ' || p_others);
  end;

  /*********************************************************************************************************************/

  procedure tabletitle(p_numcols number default null,p_others varchar2 default null) is
  begin
    tabletitleopen;
    tableheader(null,'center',null,null,null,nvl(p_numcols,g_numcols),p_others);
    htp.tablerowclose;
  end;

  /*********************************************************************************************************************/

  procedure tabletitle(p_array util.tarray,p_others varchar2 default null) is
  begin
    tabletitleopen;
    coluns('T',p_array,p_others);
    htp.tablerowclose;
  end;

  /*********************************************************************************************************************/

  procedure tablesubopen is
  begin
    htp.tablerowopen('center','middle',null,null,'bgcolor="' || c_tablesubtit || '"');
  end;

  /*********************************************************************************************************************/

  procedure tablesub(p_numcols number default null,p_others varchar2 default null) is
  begin
    tablesubopen;
    tableheader(null,'center',null,null,null,nvl(p_numcols,g_numcols),p_others);
    htp.tablerowclose;
  end;

  /*********************************************************************************************************************/

  procedure tablesub(p_array util.tarray,p_others varchar2 default null) is
  begin
    tablesubopen;
    coluns('T',p_array,p_others);
    htp.tablerowclose;
  end;

  /*********************************************************************************************************************/

  procedure tableheader(cvalue in varchar2 default null,calign in varchar2 default null,cdp in varchar2 default null,
                        cnowrap in varchar2 default null,crowspan in varchar2 default null,ccolspan in varchar2 default null,
                        cattributes in varchar2 default null) is
  begin
    htp.tableheader(util.test(nvl(instr(upper(cvalue), 'TYPE='),0) = 0, '&nbsp;') || cvalue || util.test(nvl(instr(upper(cvalue), 'TYPE='),0) = 0, '&nbsp;'),calign,cdp,cnowrap,crowspan,ccolspan,cattributes||' class="th"');
  end;

  /*********************************************************************************************************************/

  procedure tableheader2(cvalue in varchar2 default null,calign in varchar2 default null,cdp in varchar2 default null,
                         cnowrap in varchar2 default null,crowspan in varchar2 default null,ccolspan in varchar2 default null,
                         cattributes in varchar2 default null) is
  begin
    tableheader(cvalue,calign,cdp,cnowrap,crowspan,ccolspan,'bgcolor="' || c_tableheader || '" ' || cattributes);
  end;

  /*********************************************************************************************************************/

  procedure row(p_others varchar2 default null) is
  begin
    htp.tablerowopen(null,'middle',null,'',
                      'bgcolor="' || c_tablerowcolor ||
                      '" onmouseover="setcolor(this,''over'')" onmouseout="setcolor(this,''out'')" onclick="setcolor(this,''click'')" ' ||
                      p_others);
  end;

  /*********************************************************************************************************************/

  procedure row(p_array util.tarray,p_others varchar2 default null) is
  begin
    row(p_others);
    coluns('D',p_array);
    rowclose;
  end;

  /*********************************************************************************************************************/

  procedure rowopen(p_others varchar2 default null) is
  begin
    g_linhaimpar := (g_linhaimpar + 1) mod 2;
    row(p_others);
  end;

  /*********************************************************************************************************************/

  procedure rowopen(p_array util.tarray,p_others varchar2 default null) is
  begin
    rowopen(p_others);
    coluns('D',p_array);
    rowclose;
  end;

  /*********************************************************************************************************************/

  procedure row2(p_others varchar2 default null) is
  begin
    htp.tablerowopen(null,'middle',null,null,'bgcolor="' || c_tablerowcolor || '" ' || p_others);
  end;

  /*********************************************************************************************************************/

  procedure row2(p_array util.tarray,p_others varchar2 default null) is
  begin
    row2(p_others);
    coluns('D',p_array);
    rowclose;
  end;

  /*********************************************************************************************************************/

  procedure rowopen2(p_others varchar2 default null) is
  begin
    g_linhaimpar := (g_linhaimpar + 1) mod 2;
    row2(p_others);
  end;

  /*********************************************************************************************************************/

  procedure rowopen2(p_array util.tarray,p_others varchar2 default null) is
  begin
    rowopen2(p_others);
    coluns('D',p_array);
    rowclose;
  end;

  /*********************************************************************************************************************/

  procedure rowclose is
  begin
    htp.tablerowclose;
  end;

  /*********************************************************************************************************************/

  procedure filtrostart(p_message varchar2,p_action varchar2,p_other varchar2 default null) is
  begin
    show_scripttests;
    if p_message is not null then
      centermsg(p_message);
      htp.br;
    end if;
    htp.formopen(p_action,'post',cattributes => /*'autocomplete="off" ' || */ p_other);
  end;

  /*********************************************************************************************************************/

  procedure filtrotitle(p_title varchar2,p_numrows number default 2) is
  begin
    g_numcols := p_numrows;
    htp.tablerowopen('center','middle',null,null,'bgcolor="' || c_tableheader || '"');
    tableheader(p_title,'center',null,null,null,p_numrows,'');
    htp.tablerowclose;
  end;

  /*********************************************************************************************************************/

  procedure filtroopen(p_title varchar2,p_message varchar2,p_action varchar2,p_other varchar2 default null) is
  begin
    filtrostart(p_message,p_action,p_other);
    tablestart;
    filtrotitle(p_title,2);
  end;

  /*********************************************************************************************************************/

  procedure filtroclose is
  begin
    htp.formclose;
  end;

  /*********************************************************************************************************************/

  procedure filtrorow is
  begin
    htp.tablerowopen(null,null,null,null,'valign="middle" bgcolor="' || c_tablefiltro || '"');
  end;

  /*********************************************************************************************************************/

  procedure filtrorow(p_array util.tarray,p_others varchar2 default null) is
  begin
    filtrorow;
    coluns('F',p_array,p_others);
    rowclose;
  end;

  /*********************************************************************************************************************/

  procedure filtroheader(p_field varchar2) is
  begin
    tableheader(p_field,'right',null,null,null,null,'');
  end;

  /*********************************************************************************************************************/

  procedure filtrodata(p_field varchar2) is
  begin
    htp.tabledata(p_field,'left',null,null,null,null,'valign="center"');
  end;

  /*********************************************************************************************************************/

  procedure filtrorow(p_field1 varchar2,p_field2 varchar2) is
  begin
    filtrorow;
    filtroheader(p_field1);
    filtrodata(p_field2);
    rowclose;
  end;

  /*********************************************************************************************************************/

  function botao(p_tipo number, p_others varchar2 default null)return varchar2 is
  begin
    if p_tipo = 1 then
      return htf.formSubmit(null, 'Pesquisar', p_others);
    elsif p_tipo = 2 then
      return htf.formReset('Limpar', p_others);
    elsif p_tipo = 3 then
      return htf.formSubmit(null, 'Cadastrar', p_others);
    else
      return '';
    end if;
  end;

  /*********************************************************************************************************************/

  procedure filtrobotoes(p_array util.tarray) is
    aux varchar2(500);
  begin
    tableclose;
    aux := '';
    for li in p_array.first .. p_array.last loop
      aux := aux || ' ' || p_array(li);
    end loop;
    htp.br;
    htp.p(aux);
    htp.br;
  end;

  /*********************************************************************************************************************/

  function formbutton(p_value varchar2,p_name varchar2 default null,p_others varchar2 default null) return varchar2 is
  begin
    if p_name is not null then
      return '<input type="button" name="' || p_name || '" value="' || p_value || '" ' || p_others || '>';
    else
      return '<input type="button" value="' || p_value || '" ' || p_others || '>';
    end if;
  end;

  /*********************************************************************************************************************/

  procedure scriptcalendar is
  begin
    if not g_scriptcalendar then
      g_scriptcalendar := true;
      htp.p('<link rel="stylesheet" type="text/css" href="/calendar/calendar-system.css">');
      htp.p('<script type="text/javascript" src="/calendar/calendar.js"></script>');
      htp.p('<script type="text/javascript" src="/calendar/lang/calendar-pt_br.js"></script>');
      htp.p('<script type="text/javascript" src="/calendar/calendar-setup.js"></script>');
    end if;
  end;

  /*********************************************************************************************************************/

  function formdate(p_name varchar2,p_value varchar2 default null,p_tipo char default 'A',p_calendario boolean default true, p_attr varchar2 default null) return varchar2 is
  begin
    show_scripttests;
    if p_tipo <> 'M' and p_calendario then
      scriptcalendar;
    end if;

    return htf.formtext(p_name,util.test(p_tipo='D',4,util.test(p_tipo='M',5,8)),util.test(p_tipo='D',5,util.test(p_tipo='M',7,10)),p_value,'id="'||p_name||'"'||util.test(p_tipo = 'A', ' onblur="return verifica_obj_data(this,''Data'');"')||' onkeypress="return maskedit(event,this,numeros,'''','||util.test(p_tipo='D','''  /  ''',util.test(p_tipo='M','''  /    ''','datas'))||')" '|| p_attr) || util.test(p_tipo <> 'M' and p_calendario, '<img src="/calendar/img.gif" id="img_'||p_name||'" style="cursor: pointer;" title="Selecionar a Data" align="middle">'||template.script('Calendar.setup({inputField:"'||p_name||'", ifFormat:"'||util.test(p_tipo='D','%d/%m',util.test(p_tipo='M','%m/%Y','%d/%m/%Y'))||'", button:"img_'||p_name||'",align:"Bl",singleClick:true,showsTime:false});'));
  end;

  /*********************************************************************************************************************/

  function formtime(p_name varchar2,p_value varchar2 default null,p_atrib varchar2 default null) return varchar2 is
  begin
    show_scripttests;
    return htf.formtext(p_name,'2','5',p_value,'id="'||p_name||'" onchange="return verifica_obj_hora(this,''Hora'');" onkeypress="return maskedit(event,this,numeros,'''',horas)" ' || p_atrib);
  end;

  /*********************************************************************************************************************/

  function formnumber(p_name varchar2,p_size number,p_float boolean default null,p_value varchar2 default null,
                      p_atrib varchar2 default null) return varchar2 is
  begin
    show_scripttests;
    return htf.formtext(p_name,
                        p_size-util.test(p_size>2,trunc(3-p_size/5),trunc(p_size/2)),
                        p_size+util.test(p_float,1,0),
                        p_value,
                        'class="formnumber" onkeypress="return maskedit(event,this,numeros,' || util.test(p_float,'moeda','''''') || ','''')" ' || p_atrib);
  end;

  /*********************************************************************************************************************/

  function formcolor(p_name varchar2, p_size number, p_value varchar2, p_edit boolean default false) return varchar2 is
  begin
    return '<input type="text" '||util.test(p_edit, 'id="v_cor"')||' size="'||p_size||'" readonly class="input_text" style="background-color:'||p_value||'">';
  end;

  /*********************************************************************************************************************/

  function formcombo(p_name varchar2,p_array util.tarray,p_value varchar2 default null,p_others varchar2 default null, p_script boolean default null) return varchar2 is
    aux varchar2(32767);
  begin
    aux := util.test(p_script,'''')||htf.formselectopen(p_name,null,null,p_others)||util.test(p_script,'''+');
    if p_array.count > 0 then
      for li in p_array.first .. p_array.last loop
        if util.cut(p_array(li),'||',1) is null then
          aux := aux || util.test(p_script, '''')||htf.formselectoption(p_array(li),util.test(p_array(li) = p_value,1),'value="' || p_array(li) || '" '  || util.cut(p_array(li),'||',2)) || '</option>'||util.test(p_script,'''+');
        else
          aux := aux || util.test(p_script, '''')||htf.formselectoption(util.cut(p_array(li),'||',1), util.test(util.cut(p_array(li),'||') = p_value,1), 'value="' || util.cut(p_array(li),'||') || '" '  || util.cut(p_array(li),'||',2)) || '</option>'||util.test(p_script,'''+');
        end if;
        aux := aux || chr(13);
      end loop;
    end if;
    return aux || util.test(p_script,'''')||htf.formselectclose||util.test(p_script,''';');
  end;

  /*********************************************************************************************************************/

  procedure formcombo(p_name varchar2,p_array util.tarray,p_value varchar2 default null,p_others varchar2 default null,p_script boolean default false) is
  begin
    htp.p(util.test(p_script,'''')||htf.formselectopen(p_name,null,null,p_others)||util.test(p_script,'''+'));
    if p_array.count > 0 then
      for li in p_array.first .. p_array.last loop
        if util.cut(p_array(li),'||',1) is null then
          htp.p(util.test(p_script, '''')||htf.formselectoption(p_array(li),util.test(p_array(li) = p_value,1),'value="' || p_array(li) || '"') || '</option>'||util.test(p_script,'''+'));
        else
          htp.p(util.test(p_script, '''')||htf.formselectoption(util.cut(p_array(li),'||',1), util.test(util.cut(p_array(li),'||') = p_value,1), 'value="' || util.cut(p_array(li),'||') || '"') || '</option>'||util.test(p_script,'''+'));
        end if;
      end loop;
    end if;
    htp.p(util.test(p_script,'''')||htf.formselectclose||util.test(p_script,''';'));
  end;

  /*********************************************************************************************************************/

  procedure formhtmleditstart is
  begin
    if not g_scripthtmledit then
      g_scripthtmledit := true;
      htp.p('<script type="text/javascript" src="/autocom/FCKeditor/fckeditor.js"></script>');
    end if;
  end;

  /*********************************************************************************************************************/

  function formhtmledit(p_name varchar2,p_rows number,p_cols number,p_value varchar2 default null) return varchar2 is
  begin
    formhtmleditstart;
    return template.script('var oFCKeditor = new FCKeditor("'||p_name||'") ;
oFCKeditor.Height = "'||(60+p_rows*16)||'";
oFCKeditor.Width  = "720";
oFCKeditor.Value  = "'||replace(replace(p_value,chr(13)||chr(10),''),'"','\"')||'";
oFCKeditor.Create();');
  end;

  /*********************************************************************************************************************/

  function formtextarea(p_name varchar2,p_rows number,p_cols number,p_value varchar2 default null) return varchar2 is
  begin
    return htf.formtextareaopen(p_name,p_rows,p_cols)||p_value||htf.formtextareaclose;
  end;

  /*********************************************************************************************************************/

  function alteracao(p_action varchar2) return varchar2 is
  begin
    return htf.anchor(p_action,'Alterar');
  end;

  /*********************************************************************************************************************/

  procedure exclusaoopen(p_action varchar2,p_others varchar2 default null) is
  begin
    show_scripttests;
    htp.formopen(p_action,'post',cattributes => p_others);
    htp.formhidden('p_codigo');
  end;

  /*********************************************************************************************************************/

  function exclusao(p_value varchar2 default null,p_grupo varchar2 default null) return varchar2 is
  begin
    if p_value is null then
      if p_grupo is null then
        return '<INPUT TYPE="checkbox" onclick="checkAll(p_codigo,this.checked)">';
        --htf.formcheckbox(null,null,null,'onclick="checkAll(p_codigo,this.checked)"');
      else
        return '<INPUT TYPE="checkbox" onclick="checkAll(p_codigo,this.checked,''' || p_grupo || ''')">';
        --htf.formcheckbox(null,null,null,'onclick="checkAll(p_codigo,this.checked,''' || p_grupo || ''')"');
      end if;
    else
      return htf.formcheckbox('p_codigo',p_value, null, util.test(p_grupo is not null, ' grupo="'||p_grupo||'"'));
    end if;
  end;

  /*********************************************************************************************************************/

  function exclusaobotao return varchar2 is
  begin
    return formbutton('Excluir Selecionados',null,'onclick="if(confirm(''Confirma Exclusão?'')) this.form.submit();"');
  end;

  /*********************************************************************************************************************/

  procedure erro(p_message varchar2 default null) is
  begin
    htp.p('</p></table>');
    template.pageopen('Erro - ' || owa_util.get_procedure);
    htp.p('<p class="titulo">O erro ocorreu no módulo ' || owa_util.get_procedure || '</p>');
    htp.p('<p class="erro">');
    if p_message is null then
      if sqlcode = -1 then
        htp.p('Problema com a chave primária "'||util.cut(util.cut(sqlerrm,')',0),'(',1)||'".<br>O registro já existe na tabela.');
      elsif sqlcode = -1839 then
        htp.p('Data inválida para o mês especificado.');
      elsif sqlcode = -1843 then
        htp.p('Mês inválido.');
      elsif sqlcode = -1847 then
        htp.p('O dia do mês deve estar entre 1 e o último dia do mês.');
      elsif sqlcode = -1017 then
        htp.p('Acesso negado.<br>Você não tem permissão para visualizar esta página.');
      elsif sqlcode = -6502 then
        htp.p('Erro no tamanho de Variável ou na conversão de String para Numérico.');
      elsif sqlcode = -996 then
        htp.p('A concatenação é feita com "||", não "|".');
      elsif sqlcode = -1745 then
        htp.p('Nome de variável host / máscara inválida.');
      elsif sqlcode = -2291 then
        htp.p('Problema com a chave estrangeira "'||util.cut(util.cut(sqlerrm,')',0),'(',1)||'".<br>Registro-pai não encontrado.');
      elsif sqlcode = -6532 then
        htp.p('Estouro no tamanho do Array.');
      elsif sqlcode = -1830 then
        htp.p('Problema na conversão da String para data. O valor é maior que a máscara.');
      elsif sqlcode = -904 then
        htp.p('Nome de coluna inválida no select.');
      elsif sqlcode = -936 then
        htp.p('Expressão desconhecida no select.');
      elsif sqlcode = -1001 then
        htp.p('Cursor inválido.');
      elsif sqlcode = -933 then
        htp.p('Comando SQL não finalizado corretamente.');
      elsif sqlcode = -1417 then
        htp.p('As tabelas com "OUTER JOIN" devem ser relacionadas com pelo menos 1(uma) outra tabela.');
      elsif sqlcode = -6533 then
        htp.p('Índice maior que o tamanho da variável.');
      elsif sqlcode = -1722 then
        htp.p('Número inválido.');
      elsif sqlcode = 100 then
        htp.p('Nenhum registro encontrado.');
      elsif sqlcode = -1756 then
        htp.p('Problemas com as aspas em uma String do SQL.');
      elsif sqlcode = -1476 then
        htp.p('O divisor é igual a zero.');
      elsif sqlcode = -942 then
        htp.p('Tabela ou View inexistente.');
      elsif sqlcode = -1422 then
        htp.p('A consulta retornou mais do que 1 linha de registro.');
      elsif sqlcode = -29540 then
        htp.p('A classe "'||util.cut(sqlerrm,' ',2)||'" não existe.');
      elsif sqlcode = -911 then
        htp.p('Caracter inválido.');
      elsif sqlcode = -917 then
        htp.p('Vírgula esperada.');
      elsif sqlcode = -920 then
        htp.p('Operador relacional inválido.');
      elsif sqlcode = -6511 then
        htp.p('O cursor já está aberto.');
      elsif sqlcode = -937 then
        htp.p('Group-by inválido no select.');
      elsif sqlcode = -1007 then
        htp.p('A variável da ROW não está no SELECT do cursor.');
      elsif sqlcode = -918 then
        htp.p('Coluna ambígua definida no select.');
      elsif sqlcode = -6553 then
        htp.p('"'||util.cut(sqlerrm,'''',1)||'" não é um procedimento ou não está definido.');
      elsif sqlcode = -1438 then
        htp.p('O valor informado é maior do que o suportado pelo campo.');
      elsif sqlcode = -6531 then
        htp.p('Referencia inválida para uma coleção não inicializada.');
      elsif sqlcode = -2292 then
        htp.p('Problema com a chave estrangeira "'||util.cut(util.cut(sqlerrm,')',0),'(',1)||'".<br>Registro-filho encontrado.');
      elsif sqlcode = -1400 then
        htp.p('Não é possível inserir um valor nulo na coluna "'||util.cut(sqlerrm,'"',1)||'.'||util.cut(sqlerrm,'"',3)||'.'||util.cut(sqlerrm,'"',5)||'".');
      elsif sqlcode = -921 then
        htp.p('Fim inesperado do comando SQL. Verifique os parênteses!');
      elsif sqlcode = -2290 then
        htp.p('Chave de integridade "'||util.cut(util.cut(sqlerrm,')',0),'(',1)||'" violada.');
      else
        htp.p(util.nl2br(sqlcode||': '||sqlerrm));
        htp.p('</p><br><p class="titulo">Contate o administrador.');
      end if;
    else
      htp.p(p_message);
    end if;
    htp.p('</p>');
    pageclose;
  end;

/*********************************************************************************************************************/

procedure scriptinputstyle is
begin
  script('
function setInputStyles(){
  var i  = 0;
  var oInput = null;
  var aInputs = document.body.getElementsByTagName("INPUT");
  if(!aInputs) aInputs = new Array();
  for(i = 0; i < aInputs.length; i++){
    oInput = aInputs[ i ];
    if(!oInput) break;
    if(oInput.type == "text"){
      if((oInput.readOnly) && oInput.style["backgroundColor"]=="") oInput.style["backgroundColor"] = "'||c_fontdisab||'";
    }else
    if(oInput.type == "button" || oInput.type == "submit" || oInput.type == "reset"){
      if(oInput.className=="") oInput.className = "buttons";
    }
  }
}
setInputStyles();');
end;

/*********************************************************************************************************************/

function get_parametro (p_nome in varchar2) return varchar2 is
begin
  return null;
end;

/*********************************************************************************************************************/

function c_tableheader return varchar2 is
begin
  return get_parametro('c_tableheader');
end;

/*********************************************************************************************************************/

function c_tablesubtit return varchar2 is
begin
  return get_parametro('c_tablesubtit');
end;

/*********************************************************************************************************************/

function c_tableline01  return varchar2 is
begin
  return get_parametro('c_tableline01');
end;

/*********************************************************************************************************************/

function c_tableline02 return varchar2 is
begin
  return get_parametro('c_tableline02');
end;

/*********************************************************************************************************************/

function c_tablelnover return varchar2 is
begin
  return get_parametro('c_tablelnover');
end;

/*********************************************************************************************************************/

function c_tablelnclik return varchar2 is
begin
  return get_parametro('c_tablelnclik');
end;

/*********************************************************************************************************************/

function c_tablefiltro return varchar2 is
begin
  return get_parametro('c_tablefiltro');
end;

/*********************************************************************************************************************/

function c_tableborder return varchar2 is
begin
  return get_parametro('c_tableborder');
end;

/*********************************************************************************************************************/

function c_fontallok return varchar2 is
begin
  return get_parametro('c_fontallok');
end;

/*********************************************************************************************************************/

function c_fontcolor return varchar2 is
begin
  return get_parametro('c_fontcolor');
end;

/*********************************************************************************************************************/

function c_fonterror return varchar2 is
begin
  return get_parametro('c_fonterror');
end;

/*********************************************************************************************************************/

function c_fontdisab return varchar2 is
begin
  return get_parametro('c_fontdisab');
end;

/*********************************************************************************************************************/

function c_bgcolor return varchar2 is
begin
  return get_parametro('c_bgcolor');
end;

/*********************************************************************************************************************/

function c_inputborder return varchar2 is
begin
  return get_parametro('c_inputborder');
end;

/*********************************************************************************************************************/



end template;
/
