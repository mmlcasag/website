create or replace package body template_site as
  
  /*********************************************************************************************************************/
  /* Variaveis globais internas do pacote */
  g_scriptrowcolors     boolean := false;
  g_scripttests         boolean := false;
  g_scripttree          boolean := false;
  g_scripthtmledit      boolean := false;
  g_scripthtmledittext  boolean := false;
  g_scriptcalendar      boolean := false;
  g_scriptsorttable     boolean := false;
  g_tableID         varchar2(50) := null;

  --on line
  path             varchar(300) := '/lvirtual/imagens/';
  
  --local
  --path             varchar(300) := 'http://172.16.23.108:8080/Site/imagens/';

  /*********************************************************************************************************************/

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
      *{
          margin:0;
      }

      body {
  font-family: Tahoma;
  font-size: 11px;
  color: #666666;
  text-decoration: none;
        text-align: center;

        background-image: url('||path||'bg.gif);
        background-repeat: repeat-x;
        background-position: top;

      }

      a {
              color: #666666;
              text-decoration: none;
      }

      a:Visited {
              color: #666666;
              text-decoration: none;
      }

      a:Hover {
              color: #555555;
              text-decoration: underline;
      }

      Table,Tr,Td {
  font-family: Tahoma;
  font-size: 11px;
  color: #666666;
  text-decoration: none;
      }

      h1 {
        font-family: Tahoma;
  font-size: 14px;
  color: #888888;
  text-align: left;
      }

      h2 {
        font-family: Tahoma;
        font-size: 18px;
  color: #2B7AB5;
  text-align: left;
      }

      h6 {
        font-family: Tahoma;
        font-size: 11px;
  color: #2B7AB5;
  text-align: left;
      }

      p {
  font-family: Tahoma;
  font-size: 11px;
  color: #888888;
      }

      th {
  font-family: Tahoma;
  font-size: 11px;
  color: #888888;
      }

      .th {
  font-family: Tahoma;
  font-size: 11px;
  color: #ffffff;
        font-weight: bold;
        height: 20px;
      }

      .TR_listas{
        height: 22px;
      }

      .CorTitFiltro{
        color:#888888;
      }

      .erro {
  font-family: Tahoma;
  font-size: 12px;
        font-weight: bold;
        color: ' || c_fonterror || ';
        text-align: center;
      }
      .titulo {
  font-family: Tahoma;
  font-size: 12px;
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
  font-family: Tahoma;
  font-size: 11px;
        color: #666666;
        /*
        height:18px;
        */
        background-color: #F9F9F9;
        -moz-border-radius: 2px;

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
      .tdImpar {
        background-color: '||c_tableline02||';
      }
      .tdPar {
        background-color: '||c_tableline01||';
      }
      #Menu{
  position:absolute;
  width:211px;
  z-index:1;
  left: 10px;
  top: 15px;
      }


      /*FORMULARIOS *-------------------------------------------------------------------------------*/
        Fieldset{
              padding: 20px;
              border: 1px solid #cccccc;
              width: 500;
              -moz-border-radius: 8px;
         }

        Legend
        {
           padding: 6px;
           border: solid #cccccc 1px;
           font-size: 90%;
           font-weight: bold;
           background-color: #ffffff;
           -moz-border-radius: 6px;
        }

        .buttons {
          font-family: Tahoma;
          font-size: 11px;
          font-weight:bold;
          color: #FFFFFF;

          border: 1px solid #FFFFFF;
          background-color: #2F81CE;
          background-image: url('||path||'bg_botao.gif);

          cursor: hand;
          height: 25px;
          margin: 0px;
          padding: 0px;
        }


  #Mensagens{
    z-index:999;
    position:absolute;

    border:0px solid #000000;

    background-color:#000000;
    opacity: .50;               /*Firefox/Opera */
    filter: alpha(Opacity=50); /*IE era 20*/

    width:100%;
    height:100%;
  }

  #Caixa{
    position:absolute;
    z-index:999;
    width:260px;
    height:100px;
    top: 50%;
    left: 50%;
    margin-top: -95px;
    margin-left: -110px;
    position: absolute;
    background-color:#FFFFFF;

    border: 1px solid #f5f5f5;

                -moz-border-radius: 10px;
  }

      /*FIM FORMULARIOS *---------------------------------------------------------------------------*/

      .Paginacao{
              font-family:"Trebuchet MS";
              font-size:12px;
              color:#7B7B7B;
              font-weight:bold;
      }
      .PaginacaoSelect{
              color:#5389B3;
              font-size:18px;
      }

      ');
  end;

  /*********************************************************************************************************************/

  procedure styles is
  begin
    htp.p('<link rel="stylesheet" href="template_site.style" type="text/css">');
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
    htp.anchor(v_page,'<img src="'||path||'bt_continuar.gif" border=0 onfocus=this.blur();>');
    pageend;
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
      htp.p('<script language="JavaScript" src="template_site.scripttests"></script>');
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
//CARACTERES UNICOS
var emailsc   = "@";
var moeda     = ",";
//MASCARAS
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

//VERIFICA A MASCARA E RETORNA SE A TECLA PRESSIONADA PODE OU N?O SER INCLUIDA NO OBJETO
function valida_tecla(obj,str,strone,mask) {
  eve = window.event;
  var code = eve.keyCode ? eve.keyCode : eve.charCode ? eve.charCode : eve.which ? event.which : void 0;
  if(code==8 || code==9 || code==13) return true;
  return verifica_mascara(obj,str,strone,mask,String.fromCharCode(code));
}

//VERIFICA A MASCARA E RETORNA SE A TECLA PRESSIONADA PODE OU N?O SER INCLUIDA NO OBJETO
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

//VERIFICA SE O CAMPO TEXT ESTA EM BRANCO
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

//VERIFICA SE O CAMPO TEXT ESTA EM BRANCO
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
    alert("O numero de caracteres excedeu o limite no campo "+desc+"!");
    obj.focus();
    return false;
  } else return true;
}

//VERIFICA SE O CAMPO LIST ESTA EM BRANCO
function verifica_obj_list(obj,desc){
  if (isblank(obj.value)) {
    alert("Selecione o campo "+desc+"!");
    obj.focus();
    return false;
  } else return true;
}

//VERIFICA SE O CAMPO RADIO ESTA MARCADO
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
      alert("Ano invalido no campo "+desc+"!");
      obj.focus();
      return false;
    };
    if (0+obj.value.substr(3,2)<1 || 0+obj.value.substr(3,2)>12){
      alert("Mes invalido no campo "+desc+"!");
      obj.focus();
      return false;
    };
    if (0+obj.value.substr(0,2)<1 || 0+obj.value.substr(0,2)>31 || 0+obj.value.substr(0,2) > meses[obj.value.substr(3,2)-1]){
      alert("Dia invalido para o mes especificado no campo "+desc+"!");
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

//VERIFICA SE OS CAMPOS DATA EST?O CORRETOS
function verifica_obj_dates(date1,date2) {
  if(diffDate(parseDate(date1.value),parseDate(date2.value))<0){
    alert("A data de termino n?o podem ser menor que a data de inicio!");
    date2.focus();
    return false;
  }
  return true;
}
function verifica_obj_times(time1,time2) {
  if (time1.value>time2.value){
    alert("A hora de termino n?o podem ser menor que a hora de inicio!");
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

/*MarcaraCampos para campos generica -------------------------------------------------------------*/
/*Exemplo chamada  para digitar celular: onKeypress="return MascaraCampos(this,''99.999999'', event);"*/
function MascaraCampos(campo, sMask, evtKeyPress) {
  var i, nCount, sValue, fldLen, mskLen,bolMask, sCod, nTecla;


  if(document.all) { // Internet Explorer
    nTecla = evtKeyPress.keyCode;
  } else if(document.layers) { // Nestcape
    nTecla = evtKeyPress.which;
  } else {
    nTecla = evtKeyPress.which;
  if ((nTecla == 8) || (nTecla == 99) || (nTecla == 118) || (nTecla == 120)) {
    return true;
                //8 backspace  99 tecla c   118 tecla v     120 tecla x
  }
  }

  sValue = campo.value;
  // Limpa todos os caracteres de formataÁ„o que
  // j· estiverem no campo.
  sValue = sValue.toString().replace( "-", "" );
  sValue = sValue.toString().replace( "-", "" );
  sValue = sValue.toString().replace( ".", "" );
  sValue = sValue.toString().replace( ".", "" );
  sValue = sValue.toString().replace( "/", "" );
  sValue = sValue.toString().replace( "/", "" );
  sValue = sValue.toString().replace( "(", "" );
  sValue = sValue.toString().replace( "(", "" );
  sValue = sValue.toString().replace( ")", "" );
  sValue = sValue.toString().replace( ")", "" );
  sValue = sValue.toString().replace( ":", "" );
  sValue = sValue.toString().replace( ":", "" );
  fldLen = sValue.length;
  mskLen = sMask.length;

  i = 0;
  nCount = 0;
  sCod = "";
  mskLen = fldLen;

  while (i <= mskLen) {
    bolMask = ((sMask.charAt(i) == "-") || (sMask.charAt(i) == ":") || (sMask.charAt(i) == ".") || (sMask.charAt(i) == "/"))
    bolMask = bolMask || ((sMask.charAt(i) == "(") || (sMask.charAt(i) == ")") || (sMask.charAt(i) == " "))

    if (bolMask) {
      sCod += sMask.charAt(i);
      mskLen++;
    } else {
      sCod += sValue.charAt(nCount);
      nCount++;
    }
    i++;
  }

  campo.value = sCod;
  if (nTecla != 8) { // backspace
    if (sMask.charAt(i-1) == "9") { // apenas n˙meros...
      return ((nTecla > 47) && (nTecla < 58)); } // n˙meros de 0 a 9
    else { // qualquer caracter...
      return true;
    }
  } else {
    return true;
  }
}
/*Fim MarcaraCampos para campos generica ----------------------------------------------------------*/


/*Funcao para Mostrar ou Ocultar Div*/
  function MostraOcultaDiv(id_do_baguio){
      //var d = document.getElementById(id_do_baguio);
      if(document.getElementById(id_do_baguio).style.display == "none"){
         document.getElementById(id_do_baguio).style.display = "table";
         //document.getElementById(id_do_baguio).style.display = "block";
      }else{
         document.getElementById(id_do_baguio).style.display = "none";
      }
  }
/*Fim Funcao para Mostrar ou Ocultar Div*/

');
  end;

  /*********************************************************************************************************************/

-- FUNCAO AJAX ---------------------------------------------------------------------------------------------------------
  procedure ajax_funcao is
  begin
    htp.p('
      <script>
        // a funcao abaixo funciona em qualquer
         // browser ou vers„o.
         function createXMLHTTP()
         {
          var ajax;
          try
          {
           ajax = new ActiveXObject("Microsoft.XMLHTTP");
          }
          catch(e)
          {
           try
           {
            ajax = new ActiveXObject("Msxml2.XMLHTTP");
            alert(ajax);
           }
           catch(ex)
           {
            try
            {
             ajax = new XMLHttpRequest();
            }
            catch(exc)
            {
              alert("Esse browser n„o tem recursos para uso do Ajax");
              ajax = null;
            }
           }
           return ajax;
          }
             var arrSignatures = ["MSXML2.XMLHTTP.5.0", "MSXML2.XMLHTTP.4.0",
                   "MSXML2.XMLHTTP.3.0", "MSXML2.XMLHTTP",
                   "Microsoft.XMLHTTP"];
             for (var i=0; i < arrSignatures.length; i++)
             {
            try
            {
             var oRequest = new ActiveXObject(arrSignatures[i]);
             return oRequest;
            }
            catch (oError)
            {
               }
             }

              throw new Error("MSXML is not installed on your system.");
         }
      </script>
    ');
  end;

 /*********************************************************************************************************************/

  procedure heading(p_title varchar2) is
  begin
    --htp.header(1,p_title || '<hr>');
    htp.header(1,p_title);
  end;

  /*********************************************************************************************************************/

  procedure menu_lateral(p_menu in util.tarray default null,
                         p_link in util.tarray default null,
                         p_destino in util.tarray default null) is

  destino      varchar2(30);

  begin

  --para dar espaÁamento lateral
  if p_menu is not null then
    htp.p('
      <style>
        .Espaco{
           padding-left:225px;
        }
        </style>
    ');
  end if;

     htp.p('<div id="Menu">

        <table width="220" height="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="10" valign="top"><img src="'||path||'sombra_left.png" width="10"></td>
            <td valign="top" bgcolor="#FFFFFF" class="bg_sombra"><table width="100%" border="0" cellspacing="0" cellpadding="20">
              <tr>
                <td height="120">

                         <!--MENU LATERAL ---------------------------------------------------------------->
                              <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                      <tr>
                                            <td height="56" align="center" colspan="2"><img src="'||path||'logo.gif"></td>
                                      </tr>
                                      <tr>
                                            <td height="10" colspan="2"></td>
                                      </tr>');

                                  --LaÁo de itens de menu-------------------------------------------------------------------------------------
                                  if p_menu is not null then
                                    htp.p('
                                                  <tr>
                                                      <td width="15"><img src="'||path||'ico_package.gif" border=0></td>
                                                      <td height="25" colspan="2">&nbsp;<strong>Menu</strong> </td>
                                                  </tr>
                                                  <tr>
                                                        <td background="'||path||'bg_pontilhado.gif" bgcolor="#999999" height="1" colspan="2"></td>
                                                  </tr>');

                                      for i in p_menu.first..p_menu.last loop
                                      begin

                                        if p_destino(i) is not null then
                                          destino := ' target="' || p_destino(i) || '"';
                                        end if;

                                         htp.p('
                                            <tr>
                                                  <td width="15" style="padding-left:8px">
                                                    <a href="'||p_link(i)||'"'||destino||' onFocus="this.blur();">
                                                      <img src="'||path||'ico_seta.gif" border=0>
                                                    </a>
                                                  </td>
                                                  <td height="25" onMouseover="Move(this, ''#F5F5F5'');" onMouseOut="Mout(this, ''#FFFFFF'');">
                                                    &nbsp;<a href="'||p_link(i)||'"'||destino||' onFocus="this.blur();">'||p_menu(i)||'</a>
                                                  </td>
                                            </tr>
                                            <tr>
                                                  <td background="'||path||'bg_pontilhado.gif" bgcolor="#999999" height="1" colspan="2"></td>
                                            </tr>
                                            ');

                                        end;
                                        end loop;


                                        htp.p('
                                                <tr>
                                                  <td height="20" colspan="2">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                  <td height="25" colspan="2"><table border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                  <td><a href="javascript:history.go(-1);" onfocus=this.blur();><img src="'||path||'ico_bola_voltar.gif" width="24" height="23" border="0"></a></td>
                                                  <td><a href="javascript:history.go(-1);" onfocus=this.blur();>&nbsp;Voltar</a></td>
                                                </tr>
                                                </table>
                                              </td>
                                          </tr>
                                          ');
                              end if;


                htp.p('</table>
                      <!--FIM MENU LATERAL --------------------------------------------------------------->

                </td>
                      </tr>
                </table></td>
              <td width="10" valign="top"><img src="'||path||'sombra_right.png" width="10"></td>
            </tr>
          </table>

        </div>
       ');
  end;



  procedure pageopen(p_title varchar2 default null,
                     p_transacao number default null,
                     p_menu in util.tarray default null,
                     p_link in util.tarray default null,
                     p_destino in util.tarray default null,
                     p_mensagem varchar2 default null,
                     p_icone varchar2 default 'ok') is

    v_style          varchar2(30);

  begin



  -- MENSAGENS APOS OPERA«OES COM O BANCO DE DADOS---------------------------------------------------------------------------------------------------------------
    if p_mensagem is not null then

        htp.p('
          <style>
              body{
                      overflow:hidden;
              }
          </style>
          <script>
              function AtivaScroll(){
                      document.body.style.overflow=''auto'';
              }
          </script>

          <div id="Mensagens"></div>

          <div id="Caixa">
            &nbsp;
            <table width="258" height="70" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#ffffff">
              <tr>
                <td height="10" colspan="2"  align="center" valign="top"></td>
              </tr>
              <tr>
                <td width="50"  align="center">
                  <img src="'||path||'ico_'||p_icone||'.gif">
                </td>
                <td style=padding-right:4px;>'||p_mensagem||'<br><br></td>
              </tr>
              <tr>
                <td height="30" colspan="2"  align="center" valign="bottom">
                  <A href="javascript:;" onFocus="this.blur();">
                    <img src="'||path||'bt_okfechar.gif" border=0 onClick="MM_showHideLayers(''Caixa'','''',''hide'',''Mensagens'','''',''hide'');AtivaScroll();">
                  </A>
                </td>
              </tr>
            </table>
          </div>
        ');

    end if;
  -- MENSAGENS APOS OPERA«OES COM O BANCO DE DADOS---------------------------------------------------------------------------------------------------------------



    if p_transacao is not null and not util.val_acesso_user(p_transacao) then
      raise login_denied;
    end if;
    htp.p('<html xmlns="http://www.w3.org/1999/xhtml">');
    htp.headopen;
    htp.p('<meta http-equiv="Pragma" content="no-cache">');
    htp.p('<meta http-equiv="expires" content="0">');
    htp.p('<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>');


    if p_title is not null then
      htp.title(p_title);
    end if;
    styles;
    htp.p('<link rel="shortcut icon" href="'||path||'favicon.ico" type="image/x-icon" />');

    htp.headclose;
    htp.bodyopen(cattributes=>'onload="correctPNG();"');
    --htp.bodyopen;

    htp.p('<script type="text/javascript">
          //Cores TR
              function Move(obj, cor){
                      obj.style.backgroundColor = cor;
              }
              function Mout(obj, cor){
                      obj.style.backgroundColor = cor;
              }

              function correctPNG() // correctly handle PNG transparency in Win IE 5.5 & 6.
              {
                 var arVersion = navigator.appVersion.split("MSIE")
                 var version = parseFloat(arVersion[1])
                 if ((version >= 5.5) && (document.body.filters))
                 {
                    for(var i=0; i<document.images.length; i++)
                    {
                       var img = document.images[i]
                       var imgName = img.src.toUpperCase()
                       if (imgName.substring(imgName.length-3, imgName.length) == "PNG")
                       {

                          var imgID = (img.id) ? "id=''" + img.id + "'' " : ""
                          var imgClass = (img.className) ? "class=''" + img.className + "'' " : ""
                          var imgTitle = (img.title) ? "title=''" + img.title + "'' " : "title=''" + img.alt + "'' "
                          var imgStyle = "display:inline-block;" + img.style.cssText
                          if (img.align == "left") imgStyle = "float:left;" + imgStyle
                          if (img.align == "right") imgStyle = "float:right;" + imgStyle
                          if (img.parentElement.href) imgStyle = "cursor:hand;" + imgStyle
                          var strNewHTML = "<span " + imgID + imgClass + imgTitle
                          + " style=\"" + "width:" + img.width + "px; height:" + img.height + "px;" + imgStyle + ";"
                          + "filter:progid:DXImageTransform.Microsoft.AlphaImageLoader"
                          + "(src=\''" + img.src + "\'', sizingMethod=''scale'');\"></span>"
                          img.outerHTML = strNewHTML
                          i = i-1
                       }
                    }
                 }
              }
              //window.attachEvent("onload", correctPNG);


              function MM_showHideLayers() { //v9.0
                var i,p,v,obj,args=MM_showHideLayers.arguments;
                for (i=0; i<(args.length-2); i+=3)
                with (document) if (getElementById && ((obj=getElementById(args[i]))!=null)) { v=args[i+2];
                  if (obj.style) { obj=obj.style; v=(v==''show'')?''visible'':(v==''hide'')?''hidden'':v; }
                  obj.visibility=v; }
              }
        </script>');


    --CHAMA O CONSTRUTOR DO MENU-------------------------------------------------------------------------------------------
    template_site.menu_lateral(p_menu,p_link,p_destino);


    -- INICIO TABELAS DO PAGEOPEN ESTRUTURA EM GERAL-------------------------------------------------------------------------------------------------------
    htp.p('<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td align="center" valign="top"><table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td valign="top"><table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="left" valign="top">

                    <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                      <tr>
                            <td valign="top" style="padding-top:80px;">

                              <div id="TituloPagina">
                                      <table width="76%" border="0" style="margin-left:230px" cellspacing="0" cellpadding="0">
                                        <tr>
                                          <td height="30">
                                        ');
                                            -- TITULO DA P¡GINA --------------------------------------------------------------
                                            if p_title is not null then
                                              heading(p_title);
                                              htp.para;
                                            end if;

      htp.p('                            </td>

                                        </tr>
                                        <tr>
                                              <td background="'||path||'bg_pontilhado.gif" bgcolor="#999999" height="1"></td>
                                        </tr>
                                      </table>
                               </div>


                                <table width="98%" height="100%" border="0" cellspacing="0" cellpadding="0">
                                  <tr>
                                        <td style="padding-top:28px;'||v_style||'" class="Espaco" valign="top" align="center">');

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
      htp.p('<script language="JavaScript" src="template_site.scriptrowcolors"></script>');
    end if;
    tablestart(p_attributes);
  end;

  /*********************************************************************************************************************/

  procedure tableopen(p_array util.tarray,
                      p_attributes varchar2 default null,
                      p_tableID varchar2 default null,
                      p_nullParam varchar2 default null --n?o usado, declarado apenas para n?o invalidar packages antigas
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
                      '" onmouseover="setcolor(this,''over'')" onmouseout="setcolor(this,''out'')" onclick="setcolor(this,''click'')" class="TR_listas"' ||
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
    tableheader(p_field,'right',null,null,null,null,' class="CorTitFiltro"');
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

    return htf.formtext(p_name,util.test(p_tipo='D',4,util.test(p_tipo='M',5,8)),util.test(p_tipo='D',5,util.test(p_tipo='M',7,10)),p_value,'id="'||p_name||'"'||util.test(p_tipo = 'A', ' onblur="return verifica_obj_data(this,''Data'');"')||' onkeypress="return maskedit(event,this,numeros,'''','||util.test(p_tipo='D','''  /  ''',util.test(p_tipo='M','''  /    ''','datas'))||')" '|| p_attr) || util.test(p_tipo <> 'M' and p_calendario, '<img src="'||path||'calendario.gif" id="img_'||p_name||'" style="cursor: pointer;" title="Selecionar a Data" align="middle">'||template_site.script('Calendar.setup({inputField:"'||p_name||'", ifFormat:"'||util.test(p_tipo='D','%d/%m',util.test(p_tipo='M','%m/%Y','%d/%m/%Y'))||'", button:"img_'||p_name||'",align:"Bl",singleClick:true,showsTime:false});'));
  end;

  /*********************************************************************************************************************/

  function formtime(p_name varchar2,p_value varchar2 default null,p_atrib varchar2 default null) return varchar2 is
  begin
    show_scripttests;
    return htf.formtext(p_name,'2','5',p_value,'id="'||p_name||'" onchange="return verifica_obj_hora(this,''Hora'');" onkeypress="return maskedit(event,this,numeros,'''',horas)" ' || p_atrib);
  end;

  /*********************************************************************************************************************/

  function formnumber(p_name varchar2,p_size number,p_float boolean default null,p_value varchar2 default null,
                      p_atrib varchar2 default null, p_class varchar2 default null) return varchar2 is
  begin
    show_scripttests;
    return htf.formtext(p_name,
                        p_size-util.test(p_size>2,trunc(3-p_size/5),trunc(p_size/2)),
                        p_size+util.test(p_float,1,0),
                        p_value,
                        'class="formnumber ' || p_class || '" onkeypress="return maskedit(event,this,numeros,' || util.test(p_float,'moeda','''''') || ','''')" ' || p_atrib);
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
      htp.p('<script type="text/javascript" src="' || path || 'fckeditor_2.6.2/fckeditor.js"></script>');
    end if;
  end;

  /*********************************************************************************************************************/

  function formhtmledit(p_name varchar2,p_rows number,p_cols number,p_value varchar2 default null) return varchar2 is
  begin
    formhtmleditstart;
    return template_site.script('var oFCKeditor = new FCKeditor("'||p_name||'") ;
oFCKeditor.Height = "'||(60+p_rows*16)||'";
oFCKeditor.Width  = "720";
oFCKeditor.Value  = "'||replace(replace(p_value,chr(13)||chr(10),''),'"','\"')||'";
oFCKeditor.BasePath   = "' || path || 'fckeditor_2.6.2/";
oFCKeditor.Create();');
  end;

/*********************************************************************************************************************/

  function formtextarea(p_name varchar2,p_rows number,p_cols number,p_value varchar2 default null) return varchar2 is
  begin
    return htf.formtextareaopen(p_name,p_rows,p_cols)||p_value||htf.formtextareaclose;
  end;


  /*********************************************************************************************************************/

  function form_select(p_name varchar2, p_valor varchar2, p_valores util.tarray, p_attr varchar2 default null, p_sep varchar2 default '||') return varchar2
  as
    saida varchar2(20000);
    pos number;
    v_val varchar2(500);
    v_opt varchar2(500);
  begin
    saida := '<select name="' || p_name || '" ' || p_attr || '>';
    for idx in p_valores.first .. p_valores.last loop
      pos := instr(p_valores(idx), p_sep);
      if pos < 0 then
        v_val := idx;
        v_opt := p_valores(idx);
      else
        v_val := substr(p_valores(idx), 1, pos - 1);
        v_opt := substr(p_valores(idx), pos + length(p_sep));
      end if;
      saida := saida || '<option value="' || v_val || '"'
      || util.test(p_valor = v_val, ' selected="selected"', '')
      || '>' || replace(v_opt, '<', '&lt;') || '</option>';
    end loop;
    saida := saida || '</select>';
    return saida;
  end;

  /*********************************************************************************************************************/
   
  function html_img_prod(cod_prod number, cod_itprod number default null, add_title_desc boolean default true) return varchar2
  as
  v_title varchar2(1000) := '';
  v_img varchar2(1000) := null;
  begin
  if cod_prod is not null then
    if add_title_desc then
      v_title := 'title="' || replace(util.get_prod_desc(cod_prod, cod_itprod), '"', '\"') || '"';
    end if;
    v_img := '<img src="http://www.colombo.com.br/produtos/' || cod_prod || '/' || cod_prod || 'p0.jpg"
      border="0" ' || v_title || '"
      onerror="this.src=''http://www.colombo.com.br/imagens/selo.gif'';"/>';
  end if;
  return v_img;
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
    return formbutton('Excluir Selecionados',null,'onclick="if(confirm(''Confirma Exclus?o?'')) this.form.submit();"');
  end;

  /*********************************************************************************************************************/

  procedure erro(p_message varchar2 default null) is
  begin
    htp.p('</p></table>');
    template_site.pageopen('Erro - ' || owa_util.get_procedure);
    htp.p('<p class="titulo">O erro ocorreu no modulo ' || owa_util.get_procedure || '</p>');
    htp.p('<p class="erro">');
    if p_message is null then
      if sqlcode = -1 then
        htp.p('Problema com a chave primaria "'||util.cut(util.cut(sqlerrm,')',0),'(',1)||'".<br>O registro ja existe na tabela.');
      elsif sqlcode = -1839 then
        htp.p('Data invalida para o mes especificado.');
      elsif sqlcode = -1843 then
        htp.p('Mes invalido.');
      elsif sqlcode = -1847 then
        htp.p('O dia do mes deve estar entre 1 e o ultimo dia do mes.');
      elsif sqlcode = -1017 then
        htp.p('Acesso negado.<br>Voce n?o tem permiss?o para visualizar esta pagina.');
      elsif sqlcode = -6502 then
        htp.p('Erro no tamanho de Variavel ou na convers?o de String para Numerico.');
      elsif sqlcode = -996 then
        htp.p('A concatenac?o e feita com "||", n?o "|".');
      elsif sqlcode = -1745 then
        htp.p('Nome de variavel host / mascara invalida.');
      elsif sqlcode = -2291 then
        htp.p('Problema com a chave estrangeira "'||util.cut(util.cut(sqlerrm,')',0),'(',1)||'".<br>Registro-pai n?o encontrado.');
      elsif sqlcode = -6532 then
        htp.p('Estouro no tamanho do Array.');
      elsif sqlcode = -1830 then
        htp.p('Problema na convers?o da String para data. O valor e maior que a mascara.');
      elsif sqlcode = -904 then
        htp.p('Nome de coluna invalida no select.');
      elsif sqlcode = -936 then
        htp.p('Express?o desconhecida no select.');
      elsif sqlcode = -1001 then
        htp.p('Cursor invalido.');
      elsif sqlcode = -933 then
        htp.p('Comando SQL n?o finalizado corretamente.');
      elsif sqlcode = -1417 then
        htp.p('As tabelas com "OUTER JOIN" devem ser relacionadas com pelo menos 1(uma) outra tabela.');
      elsif sqlcode = -6533 then
        htp.p('Indice maior que o tamanho da variavel.');
      elsif sqlcode = -1722 then
        htp.p('Numero invalido.');
      elsif sqlcode = 100 then
        htp.p('Nenhum registro encontrado.');
      elsif sqlcode = -1756 then
        htp.p('Problemas com as aspas em uma String do SQL.');
      elsif sqlcode = -1476 then
        htp.p('O divisor e igual a zero.');
      elsif sqlcode = -942 then
        htp.p('Tabela ou View inexistente.');
      elsif sqlcode = -1422 then
        htp.p('A consulta retornou mais do que 1 linha de registro.');
      elsif sqlcode = -29540 then
        htp.p('A classe "'||util.cut(sqlerrm,' ',2)||'" n?o existe.');
      elsif sqlcode = -911 then
        htp.p('Caracter invalido.');
      elsif sqlcode = -917 then
        htp.p('Virgula esperada.');
      elsif sqlcode = -920 then
        htp.p('Operador relacional invalido.');
      elsif sqlcode = -6511 then
        htp.p('O cursor ja esta aberto.');
      elsif sqlcode = -937 then
        htp.p('Group-by invalido no select.');
      elsif sqlcode = -1007 then
        htp.p('A variavel da ROW n?o esta no SELECT do cursor.');
      elsif sqlcode = -918 then
        htp.p('Coluna ambigua definida no select.');
      elsif sqlcode = -6553 then
        htp.p('"'||util.cut(sqlerrm,'''',1)||'" n?o e um procedimento ou n?o esta definido.');
      elsif sqlcode = -1438 then
        htp.p('O valor informado e maior do que o suportado pelo campo.');
      elsif sqlcode = -6531 then
        htp.p('Referencia invalida para uma colec?o n?o inicializada.');
      elsif sqlcode = -2292 then
        htp.p('Problema com a chave estrangeira "'||util.cut(util.cut(sqlerrm,')',0),'(',1)||'".<br>Registro-filho encontrado.');
      elsif sqlcode = -1400 then
        htp.p('N?o e possivel inserir um valor nulo na coluna "'||util.cut(sqlerrm,'"',1)||'.'||util.cut(sqlerrm,'"',3)||'.'||util.cut(sqlerrm,'"',5)||'".');
      elsif sqlcode = -921 then
        htp.p('Fim inesperado do comando SQL. Verifique os parenteses!');
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
  
  v_valor parametros_template.valor%type;
  
begin
  
  select valor
  into   v_valor
  from   parametros_template
  where  owner = 'website_lv'
  and    nome = p_nome;
  
  return v_valor;
  
exception
  when others then
    select valor
    into   v_valor
    from   parametros_template
    where  owner = 'autocom'
    and    nome = p_nome;
    
    return v_valor;
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

function retorna_path return varchar2 is
begin
  return path;
end;

/*********************************************************************************************************************/

  /*03 combos para trazer dados de linha - familia - grupo*/
  procedure filtro_linha_familia(p_param_linha in varchar2 default null,
                                 p_param_familia in varchar2 default null,
                                 p_param_grupo in varchar2 default null) is

      cr     util.ref_cursor;
      v_select     varchar2(4000);
      v_select1    varchar2(4000);
      v_select2    varchar2(4000);
      --
      v_codlinha   web_linha.codlinha%type;
      v_codfam     web_familia.codfam%type;
      v_codgrupo   web_grupo.codgrupo%type;
      v_descricao  varchar2(2000);

  begin

      v_select := 'select codlinha codigo, descricao
                   from web_linha order by descricao';

      v_select1 := 'select codlinha, codfam, descricao
                    from web_familia
                    where flativo = ''S''
                    order by descricao';

      v_select2 := 'select f.codlinha, g.codfam, g.codgrupo codgrupo, g.descricao
                    from web_grupo g, web_familia f
                    where g.flativo = ''S''
                    and f.flativo = ''S''
                    and g.codfam = f.codfam
                    order by descricao';

      if p_param_linha is not null then
          htp.tablerowopen;
              htp.tableheader('Linha:','left');
              htp.p('<td align=left>');
                  htp.formselectopen(p_param_linha,cattributes=>'onchange="pop(this);" style=width:300px;');
                  htp.formselectclose;
              htp.p('</td>');
          htp.tablerowclose;
      end if;

      if p_param_familia is not null then
          htp.tablerowopen;
              htp.tableheader('FamÌlia','left');
              htp.p('<td align=left>');
                  htp.formselectopen(p_param_familia,cattributes=>'onchange="pop(this);" style=width:300px;');
                  htp.formselectclose;
              htp.p('</td>');
          htp.tablerowclose;
      end if;

      if p_param_grupo is not null then
          htp.tablerowopen;
              htp.tableheader('Grupo:','left');
              htp.p('<td align=left>');
                  htp.formselectopen(p_param_grupo,cattributes=>'style=width:300px;');
                  htp.formselectclose;
              htp.p('</td>');
          htp.tablerowclose;
      end if;

      htp.p('
      <script>

      vet_linha = new Array();
      vet_familia = new Array();
      vet_grupo = new Array();
      ');

      open cr for v_select;
      loop
          fetch cr into v_codlinha, v_descricao;
          exit when cr%notfound;

          htp.p('
          linha = new Object();
          linha.codlinha = "'||v_codlinha||'";
          linha.descricao = "'||replace(v_descricao,'''','-')||'";
          vet_linha[vet_linha.length] = linha;
          ');
      end loop;

      open cr for v_select1;
      loop
          fetch cr into v_codlinha, v_codfam, v_descricao;
          exit when cr%notfound;

          htp.p('
          familia = new Object();
          familia.codlinha = "'||v_codlinha||'";
          familia.codfam = "'||v_codfam||'";
          familia.descricao = "'||replace(v_descricao,'''','-')||'";
          vet_familia[vet_familia.length] = familia;
          ');
      end loop;

      open cr for v_select2;
      loop
          fetch cr into v_codlinha, v_codfam, v_codgrupo, v_descricao;
          exit when cr%notfound;

          htp.p('
          grupo = new Object();
          grupo.codlinha = "'||v_codlinha||'";
          grupo.codfam = "'||v_codfam||'";
          grupo.codgrupo = "'||v_codgrupo||'";
          grupo.descricao = '''||replace(v_descricao,'''','-')||''';
          vet_grupo[vet_grupo.length] = grupo;
          ');
      end loop;

      if p_param_linha is not null then
          htp.p('
          var p1 = document.forms[0].'||p_param_linha||';
          p1.options[p1.options.length] = new Option("Selecione","");
          for (i = 0; i<vet_linha.length; i++) {
              linha = vet_linha[i];
              p1.options[p1.options.length] = new Option(linha.descricao,linha.codlinha);
          }');
      end if;

      if p_param_familia is not null then
          htp.p('
          var p2 = document.forms[0].'||p_param_familia||';
          p2.options[p2.options.length] = new Option("Todas","");
          for (i = 0; i<vet_familia.length; i++) {
                  familia = vet_familia[i];
                  p2.options[p2.options.length] = new Option(familia.descricao,familia.codfam);
          }');
      end if;

      if p_param_grupo is not null then
          htp.p('
          var p3 = document.forms[0].'||p_param_grupo||';
          p3.options[p3.options.length] = new Option("Todas","");
          for (i = 0; i<vet_grupo.length; i++) {
                  grupo = vet_grupo[i];
                  p3.options[p3.options.length] = new Option(grupo.descricao,grupo.codgrupo);
          }');
      end if;

      htp.p('function pop(obj) {');

      if p_param_linha is not null then
          htp.p('
          if (obj.name == p1.name) {');
              if p_param_familia is not null then
                 htp.p('
                 for (i=p2.options.length-1; i>=0; i--)
                    p2.options[i]=null;

                 p2.options[p2.options.length] = new Option("Todas","");

                 for (i=0; i<vet_familia.length; i++) {
                    familia = vet_familia[i];
                    if (familia.codlinha == obj.value || obj.value == "")
                        p2.options[p2.options.length] = new Option(familia.descricao,familia.codfam);
                 }');
              end if;
              if p_param_grupo is not null then
                 htp.p('
                 for (i=p3.options.length-1; i>=0; i--)
                    p3.options[i]=null;

                 p3.options[p3.options.length] = new Option("Todas","");

                 for (i=0; i<vet_grupo.length; i++) {
                    grupo = vet_grupo[i];
                    if (grupo.codlinha == obj.value || obj.value == "")
                        p3.options[p3.options.length] = new Option(grupo.descricao,grupo.codgrupo);
                 }');
              end if;
          htp.p('}');
      end if;

      if p_param_familia is not null and p_param_grupo is not null then
          htp.p('
          if (obj.name == p2.name)
          {
              for (i=p3.options.length-1; i>=0; i--)
                  p3.options[i]=null;

              p3.options[p3.options.length] = new Option("Todas","");

              for (i=0; i<vet_grupo.length; i++) {
                  grupo = vet_grupo[i];
                  if (grupo.codfam == obj.value || obj.value == "")
                          p3.options[p3.options.length] = new Option(grupo.descricao,grupo.codgrupo);
              }
          }');
      end if;
      htp.p('}');
      htp.p('</script>');

  exception
      when others then template_site.erro;
  end;

/*********************************************************************************************************************/

  /*Script para incorporar flash dos graficos*/
  procedure grafico_flash_script is
    begin
        htp.p('
          <script>
            if(typeof deconcept=="undefined"){var deconcept=new Object();}if(typeof deconcept.util=="undefined"){deconcept.util=new Object();}if(typeof deconcept.SWFObjectUtil=="undefined"){deconcept.SWFObjectUtil=new Object();}deconcept.SWFObject=function(_1,id,w,h,_5,c,_7,_8,_9,_a){if(!document.getElementById){return;}this.DETECT_KEY=_a?_a:"detectflash";this.skipDetect=deconcept.util.getRequestParameter(this.DETECT_KEY);this.params=new Object();
            this.variables=new Object();this.attributes=new Array();if(_1){this.setAttribute("swf",_1);}if(id){this.setAttribute("id",id);}if(w){this.setAttribute("width",w);}if(h){this.setAttribute("height",h);}if(_5){this.setAttribute("version",new deconcept.PlayerVersion(_5.toString().split(".")));}this.installedVer=deconcept.SWFObjectUtil.getPlayerVersion();if(!window.opera&&document.all&&this.installedVer.major>7){deconcept.SWFObject.doPrepUnload=true;
            }if(c){this.addParam("bgcolor",c);}var q=_7?_7:"high";this.addParam("quality",q);this.setAttribute("useExpressInstall",false);this.setAttribute("doExpressInstall",false);var _c=(_8)?_8:window.location;this.setAttribute("xiRedirectUrl",_c);this.setAttribute("redirectUrl","");if(_9){this.setAttribute("redirectUrl",_9);}};deconcept.SWFObject.prototype={useExpressInstall:function(_d){this.xiSWFPath=!_d?"expressinstall.swf":_d;this.setAttribute("useExpressInstall",true);
            },setAttribute:function(_e,_f){this.attributes[_e]=_f;},getAttribute:function(_10){return this.attributes[_10];},addParam:function(_11,_12){this.params[_11]=_12;},getParams:function(){return this.params;
            },addVariable:function(_13,_14){this.variables[_13]=_14;},getVariable:function(_15){return this.variables[_15];},getVariables:function(){return this.variables;},getVariablePairs:function(){var _16=new Array();var key;var _18=this.getVariables();for(key in _18){_16[_16.length]=key+"="+_18[key];}return _16;},getSWFHTML:function(){var _19="";if(navigator.plugins&&navigator.mimeTypes&&navigator.mimeTypes.length){if(this.getAttribute("doExpressInstall")){this.addVariable("MMplayerType","PlugIn");
            this.setAttribute("swf",this.xiSWFPath);}_19="<embed type=\"application/x-shockwave-flash\" src=\""+this.getAttribute("swf")+"\" width=\""+this.getAttribute("width")+"\" height=\""+this.getAttribute("height")+"\" style=\""+this.getAttribute("style")+"\"";_19+=" id=\""+this.getAttribute("id")+"\" name=\""+this.getAttribute("id")+"\" ";var _1a=this.getParams();for(var key in _1a){_19+=[key]+"=\""+_1a[key]+"\" ";}var _1c=this.getVariablePairs().join("&");if(_1c.length>0){_19+="flashvars=\""+_1c+"\"";
            }_19+="/>";}else{if(this.getAttribute("doExpressInstall")){this.addVariable("MMplayerType","ActiveX");this.setAttribute("swf",this.xiSWFPath);}_19="<object id=\""+this.getAttribute("id")+"\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" width=\""+this.getAttribute("width")+"\" height=\""+this.getAttribute("height")+"\" style=\""+this.getAttribute("style")+"\">";_19+="<param name=\"movie\" value=\""+this.getAttribute("swf")+"\" />";var _1d=this.getParams();for(var key in _1d){_19+="<param name=\""+key+"\" value=\""+_1d[key]+"\" />";
            }var _1f=this.getVariablePairs().join("&");if(_1f.length>0){_19+="<param name=\"flashvars\" value=\""+_1f+"\" />";}_19+="</object>";}return _19;},write:function(_20){if(this.getAttribute("useExpressInstall")){var _21=new deconcept.PlayerVersion([6,0,65]);if(this.installedVer.versionIsValid(_21)&&!this.installedVer.versionIsValid(this.getAttribute("version"))){this.setAttribute("doExpressInstall",true);this.addVariable("MMredirectURL",escape(this.getAttribute("xiRedirectUrl")));document.title=document.title.slice(0,47)+" - Flash Player Installation";this.addVariable("MMdoctitle",document.title);
            }}if(this.skipDetect||this.getAttribute("doExpressInstall")||this.installedVer.versionIsValid(this.getAttribute("version"))){var n=(typeof _20=="string")?document.getElementById(_20):_20;n.innerHTML=this.getSWFHTML();if(!(navigator.plugins && navigator.mimeTypes.length)) window[this.getAttribute(''id'')] = document.getElementById(this.getAttribute(''id''));return true;}else{if(this.getAttribute("redirectUrl")!=""){document.location.replace(this.getAttribute("redirectUrl"));}}return false;}};deconcept.SWFObjectUtil.getPlayerVersion=function(){var _23=new deconcept.PlayerVersion([0,0,0]);
            if(navigator.plugins&&navigator.mimeTypes.length){var x=navigator.plugins["Shockwave Flash"];
            if(x&&x.description){_23=new deconcept.PlayerVersion(x.description.replace(/([a-zA-Z]|\s)+/,"").replace(/(\s+r|\s+b[0-9]+)/,".").split("."));}}else{if(navigator.userAgent&&navigator.userAgent.indexOf("Windows CE")>=0){var axo=1;var _26=3;
            while(axo){try{_26++;axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash."+_26);_23=new deconcept.PlayerVersion([_26,0,0]);}catch(e){axo=null;}}}else{try{var axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");}catch(e){try{var axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.6");_23=new deconcept.PlayerVersion([6,0,21]);axo.AllowScriptAccess="always";}catch(e){if(_23.major==6){return _23;}}try{axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash");}catch(e){}}if(axo!=null){_23=new deconcept.PlayerVersion(axo.GetVariable("$version").split(" ")[1].split(","));
            }}}return _23;};deconcept.PlayerVersion=function(_29){this.major=_29[0]!=null?parseInt(_29[0]):0;this.minor=_29[1]!=null?parseInt(_29[1]):0;this.rev=_29[2]!=null?parseInt(_29[2]):0;};deconcept.PlayerVersion.prototype.versionIsValid=function(fv){if(this.major<fv.major){return false;}if(this.major>fv.major){return true;}if(this.minor<fv.minor){return false;}if(this.minor>fv.minor){return true;}if(this.rev<fv.rev){return false;}return true;};deconcept.util={getRequestParameter:function(_2b){var q=document.location.search||document.location.hash;if(_2b==null){return q;}if(q){var _2d=q.substring(1).split("&");
            for(var i=0;i<_2d.length;i++){if(_2d[i].substring(0,_2d[i].indexOf("="))==_2b){return _2d[i].substring((_2d[i].indexOf("=")+1));}}}return "";}};deconcept.SWFObjectUtil.cleanupSWFs=function(){var _2f=document.getElementsByTagName("OBJECT");for(var i=_2f.length-1;i>=0;i--){_2f[i].style.display="none";for(var x in _2f[i]){if(typeof _2f[i][x]=="function"){_2f[i][x]=function(){};
            }}}};if(deconcept.SWFObject.doPrepUnload){if(!deconcept.unloadSet){deconcept.SWFObjectUtil.prepUnload=function(){__flash_unloadHandler=function(){};__flash_savedUnloadHandler=function(){};window.attachEvent("onunload",deconcept.SWFObjectUtil.cleanupSWFs);};window.attachEvent("onbeforeunload",deconcept.SWFObjectUtil.prepUnload);deconcept.unloadSet=true;}}if(!document.getElementById&&document.all){document.getElementById=function(id){return document.all[id];};}var getQueryParamValue=deconcept.util.getRequestParameter;var FlashObject=deconcept.SWFObject;var SWFObject=deconcept.SWFObject;
         </script>
         ');
    end;

/*********************************************************************************************************************/

  /*Grafico em forma de pizza*/
  procedure grafico_pizza(p_nome_box in varchar2 default null,
                          p_nome_div in varchar2 default null,
                          p_nome_parte in  util.tarray default null,
                          p_porcentagem in  util.tarray default null,
                          p_porcentagem_alt in  util.tarray default null,
                          p_info in varchar2 default null) is

      v_itens    clob;

  begin


    if p_porcentagem is not null then
        for i in p_porcentagem.first..p_porcentagem.last loop
          begin

             if v_itens is not null then
                v_itens := v_itens || '\n';
             end if;

             --ordem paramentros > [title];[value];[pull_out];[color];[url];[description];[alpha];[label_radius]
             v_itens := v_itens || replaceCharsEmail(p_nome_parte(i)) || ';' || replaceCharsEmail(p_porcentagem(i)) || ';;;;' || replaceCharsEmail(p_porcentagem_alt(i));

          end;
        end loop;

    end if;


      htp.p('
        <br>
        <fieldset style=width:700px>
          <legend>' || p_nome_box || '</legend>
          ' || p_info || '

            <div id="' || p_nome_div || '">
               <strong>AtenÁ„o! FaÁa um upgrade em seu Flash Player</strong>
            </div>

            <script type="text/javascript">
              var so = new SWFObject("' || path || 'grafico_pizza/ampie.swf", "ampie", "640", "440", "8", "#FFFFFF");
              so.addVariable("path", "' || path || 'grafico_pizza/")
              so.addVariable("settings_file", escape("' || path || 'grafico_pizza/grafico2d_pizza_settings.xml"));
              so.addVariable("chart_data", escape("' || v_itens || '"));
              so.addVariable("preloader_color", "#999999");
              so.addParam("wmode", "transparent");
              so.write("' || p_nome_div || '");
            </script>
        </fieldset>
      ');
  end;


/*********************************************************************************************************************/

  /*Grafico em forma de Coluna*/
  procedure grafico_coluna(p_nome_box in varchar2 default null,
                           p_nome_div in varchar2 default null,
                           p_legenda in varchar2 default null,
                           p_unidade_medida in varchar2 default null,
                           p_valor_partes in util.tarray default null,
                           p_valor_partes_alt in util.tarray default null,
                           p_outros in varchar2 default null) is

     v_constroi_xml        clob;
     v_itens               clob;

     --cores para as colunas conforme itens pegas as cores predefinidas, caso tenha mais ele seta a cor
     p_cores util.tarray := util.tarray('FF6600','FF9E01','FCD202','F8FF01','B0DE09','04D215','0D8ECF','8A0CCF','9447FC','EC7CC4','DAF0FD','1974AA','835B46','9E755E');

  begin

    v_constroi_xml :='<settings><data_type>csv</data_type><font>Tahoma</font><text_size>11</text_size><depth>15</depth><angle>30</angle><column><width>85</width><spacing>0</spacing><grow_time>3</grow_time><grow_effect>elastic</grow_effect><balloon_text><![CDATA[ {value} ' || replaceCharsEmail(p_unidade_medida) || ' <br> {title}]]></balloon_text></column><plot_area><margins><left>60</left><right>20</right></margins></plot_area><grid><category><alpha>10</alpha><dashed>true</dashed></category><value><alpha>10</alpha><dashed>true</dashed></value></grid><values><category><color>999999</color></category><value><min>0</min></value></values><axes><category><color>E7E7E7</color><width>1</width></category><value><color>#E7E7E7</color><width>1</width></value></axes><balloon><text_color>000000</text_color></balloon>';
    v_constroi_xml := v_constroi_xml || '<labels><label><x>0</x><y>7</y><text_color>999999</text_color><text_size>13</text_size><align>center</align><text><![CDATA[<b>' || replaceCharsEmail(p_nome_box) || '</b>]]></text></label></labels><legend><enabled>false</enabled></legend>';
    v_constroi_xml := v_constroi_xml || '<graphs>';

    --monta colunas
    if p_valor_partes is not null then
        for i in p_valor_partes.first..p_valor_partes.last loop
          begin
             if v_itens is not null then
                v_itens := v_itens || ';';
             end if;

             v_itens := v_itens || p_valor_partes(i);

             v_constroi_xml := v_constroi_xml || '<graph><type/><title><![CDATA[' || replaceCharsEmail(p_valor_partes_alt(i)) || ']]></title><color>' || p_cores(i) || '</color></graph>';
          end;
        end loop;

    end if;

   v_constroi_xml := v_constroi_xml || '</graphs></settings>';

    htp.p('
    <br>
      <fieldset style=width:700px>
        <legend>' || p_nome_box || '</legend>

        ' || p_outros || '

        <div id="' || p_nome_div || '">
           <strong>AtenÁ„o! FaÁa um upgrade em seu Flash Player</strong>
        </div>

  <script type="text/javascript">
          var so = new SWFObject("' || path || 'grafico_colunas/amcolumn.swf", "amcolumn", "400", "350", "8", "#FFFFFF");
          so.addVariable("path", "' || path || 'grafico_colunas/")
          so.addVariable("chart_settings", escape("'|| v_constroi_xml ||'"));
          so.addVariable("chart_data", escape("' || p_legenda || ';' || v_itens || '"));
          so.addVariable("preloader_color", "#999999");
          so.addParam("wmode", "transparent");
          so.write("' || p_nome_div || '");
  </script>

    </fieldset>');

  end;


/*********************************************************************************************************************/

  /*Funcao Replace Caracteres Invalidos*/
  FUNCTION replaceCharsEmail(hWord VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN translate(hword,
    '·ÈÌÛ˙„ı‡ËÏÚ˘‚ÍÓÙ˚‡ËÏÚ˘‚ÍÓÙ˚‰ÎÔˆ¸˝ˇ˝ÁÒÂ°¡…Õ”⁄√’¿»Ã“Ÿ¬ Œ‘€¿»Ã“Ÿ¬ Œ‘€ƒÀœ÷‹››«—≈°~¥`^()"*#$%[]{}/\|<>''',
    'aeiouaoaeiouaeiouaeiouaeiouaeiouyyycnaiAEIOUAOAEIOUAEIOUAEIOUAEIOUAEIOUYYCNAI                        ');
  END replaceCharsEmail;

/*********************************************************************************************************************/
procedure script_ajax_api is
begin

htp.p('

    var ajax = new obj_ajax();

    function obj_ajax(){
        this.colombo = new obj_colombo();
    }

    function obj_colombo(){

        this.idInternal = -999;
        this.ajaxRequest = false;
        this.buildRequestObject = func_buildRequestObject;
        this.getScrollXY        = func_getScrollXY;
        this.scrollingDetector  = func_scrollingDetector;
        this.activeScrolling    = func_activeScrolling;
        this.deactiveScrolling  = func_deactiveScrolling;
        this.initalizeLoadingMessage = func_initalizeLoadingMessage;
        this.displayMessage     = func_displayMessage;
        this.hiddenMessage      = func_hiddenMessage;
        this.ParamRequest       = Obj_ParamRequest;
        this.executeOnAjax      = func_executeOnAjax;
        this.executeOnAjaxMain  = func_executeOnAjax2;

    }

    ajax.colombo.buildRequestObject();

    function func_buildRequestObject(){
      if (window.XMLHttpRequest) {
         ajax.colombo.ajaxRequest = new XMLHttpRequest();
      } else if (window.ActiveXObject) {
         ajax.colombo.ajaxRequest = new ActiveXObject(''Microsoft.XMLHTTP'');
      }
    }

    function func_getScrollXY() {
      var scrOfX = 0, scrOfY = 0;
      if( typeof( window.pageYOffset ) == ''number'' ) {
        //Netscape compliant
        scrOfY = window.pageYOffset;
        scrOfX = window.pageXOffset;
      } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
        //DOM compliant
        scrOfY = document.body.scrollTop;
        scrOfX = document.body.scrollLeft;
      } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
        //IE6 standards compliant mode
        scrOfY = document.documentElement.scrollTop;
        scrOfX = document.documentElement.scrollLeft;
      }
      return [ scrOfX, scrOfY ];
    }

    function func_scrollingDetector(){
       var cordenadas = ajax.colombo.getScrollXY();

       var disabledZone = document.getElementById(''disabledZone'');
       document.getElementById(''messageZone'').style.top = ""+cordenadas[1]+"px";
    }

    function func_activeScrolling(){
        ajax.colombo.idInternal = setInterval("ajax.colombo.scrollingDetector()",250);
    }

    function func_deactiveScrolling(){
        if( ajax.colombo.idInternal != -999 )
            clearInterval(ajax.colombo.idInterval);
        ajax.colombo.idInternal = -999;
    }

    function func_initalizeLoadingMessage(message) {
      var loadingMessage;
      if (message) loadingMessage = message;
      else loadingMessage = "Loading";

      var disabledZone = document.getElementById(''disabledZone'');
      if (!disabledZone) {
        disabledZone = document.createElement(''div'');
        disabledZone.setAttribute(''id'', ''disabledZone'');
        disabledZone.style.position = "absolute";
        disabledZone.style.zIndex = "1000";
        disabledZone.style.left = "0px";
        disabledZone.style.top = "0px";
        disabledZone.style.width = "100%";
        disabledZone.style.height = "100%";
        document.body.appendChild(disabledZone);
        var messageZone = document.createElement(''div'');
        messageZone.setAttribute(''id'', ''messageZone'');
        messageZone.style.position = "absolute";
        messageZone.style.top = ""+ajax.colombo.getScrollXY()[1]+"px";
        messageZone.style.right = "0px";
        messageZone.style.background = "red";
        messageZone.style.color = "white";
        messageZone.style.fontFamily = "Arial,Helvetica,sans-serif";
        messageZone.style.padding = "4px";
        disabledZone.appendChild(messageZone);
        var text = document.createTextNode(loadingMessage);
        messageZone.appendChild(text);
      }else {
        document.getElementById(''messageZone'').innerHTML = loadingMessage;
        document.getElementById(''messageZone'').style.top = ""+ajax.colombo.getScrollXY()[1]+"px";
        disabledZone.style.visibility = ''visible'';
      }
      document.getElementById(''disabledZone'').style.visibility = ''hidden'';

    }

    function func_displayMessage(message){
       ajax.colombo.initalizeLoadingMessage(message);
       document.getElementById(''disabledZone'').style.visibility = ''visible'';
    }

    function func_hiddenMessage(){
       var disabledZone = document.getElementById(''disabledZone'');
       if( disabledZone )
         disabledZone.style.visibility = ''hidden'';
       ajax.colombo.deactiveScrolling();
    }

    function Obj_ParamRequest(){
       this.cacheDisabled = true;
       this.returnXML     = false;
       this.autoMessage   = true;
       this.message       = "Aguarde, Por Favor";
       this.method        = "GET";
       this.paramPost     = "";
       this.url           = "";
       this.beforeRequest = function(){};
       this.onFinished    = function(response){};
       this.onError       = function(statusCode){
            var urlAux = this.url;
            if( this.url.indexOf("http://") == -1 && this.url.substring(1,1) != "/" )
                urlAux = "http://intranet.colombo.com.br:7777"+"'||owa_util.get_owa_service_path||'"+this.url;
            else if( this.url.indexOf("http://") == -1 )
                urlAux = "http://intranet.colombo.com.br:7777"+this.url;
            if( this.method == "GET" ){
                document.location = urlAux;
            }else{
                document.location = urlAux+"?"+this.paramPost;
            }
       };
       this.afterFinished = function(){};
    }

    function func_executeOnAjax( param ){
        ajax.colombo.buildRequestObject();
        ajax.colombo.ajaxRequest.open(param.method, param.url );
        if( param.cacheDisabled ){
          ajax.colombo.ajaxRequest.setRequestHeader(''Cache-Control'', ''no-cache'');
          ajax.colombo.ajaxRequest.setRequestHeader(''Pragma'', ''no-cache'');
          ajax.colombo.ajaxRequest.setRequestHeader(''Expires'', ''-1'');
        }

        if( param.method == "POST" ){
            ajax.colombo.ajaxRequest.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
        }
        if( param.autoMessage ){
            ajax.colombo.displayMessage( param.message );
        }

        param.beforeRequest();

        ajax.colombo.ajaxRequest.onreadystatechange = function(){
          if (ajax.colombo.ajaxRequest.readyState == 4 ){
              if(ajax.colombo.ajaxRequest.status == 200){
                  if( !param.returnXML )
                      param.onFinished( ajax.colombo.ajaxRequest.responseText );
                  else
                      param.onFinished( ajax.colombo.ajaxRequest.responseXML );
              }else{
                  param.onError( ajax.colombo.ajaxRequest.status );
              }
              if( param.autoMessage ){
                  ajax.colombo.hiddenMessage();
              }
              param.afterFinished();
          }
        }

        if( param.method == "POST" ){
            ajax.colombo.ajaxRequest.send(param.paramPost);
        }else{
            ajax.colombo.ajaxRequest.send(null);
        }

    }


    function func_executeOnAjax2( url, obj, func_fin ){
        if( !func_fin )
            func_fin = function(){};
        var objParam = new ajax.colombo.ParamRequest();
        objParam.url = url;
        objParam.afterFinished = func_fin;
        objParam.onFinished = function(data){
            eval( "document.forms[0]."+obj+".value = data;" );
        }
        ajax.colombo.executeOnAjax( objParam );
    }


');

end script_ajax_api;

/*********************************************************************************************************************/
procedure script_ajax_include is
begin
  htp.p('<script language="JavaScript" src="'||owa_util.get_owa_service_path||'template_site.script_ajax_api"></script> ');
end script_ajax_include;


/*********************************************************************************************************************/
procedure filtro_linha_familia_ajax (p_param_linha in varchar2 default null,
                                     p_codlinha in number default null,
                                     p_param_familia in varchar2 default null,
                                     p_codfam in number default null,
                                     p_param_grupo in varchar2 default null,
                                     p_codgrupo in number default null) is

  cursor c_buscalinha(cod_linha in number) is
  select codlinha, descricao, decode(cod_linha, codlinha, 'selected="selected"', null) selected
    from web_linha
   order by descricao;

  cursor c_buscafamilia(cod_linha in number,
                        cod_familia in number) is
  select codlinha, codfam, descricao, decode(cod_familia, codfam, 'selected="selected"', null) selected
    from web_familia
   where flativo = 'S'
     and codlinha = cod_linha
   order by descricao;

  cursor c_buscagrupo(p_codlinha in number,
                      p_codfamilia in number,
                      p_codgrupo in number) is
  select f.codlinha, f.codfam,
         g.codgrupo, g.descricao descricao,
         decode(p_codgrupo, g.codgrupo, 'selected="selected"', null) selected
    from web_grupo g,
         web_familia f
   where g.flativo = 'S'
     and f.flativo = 'S'
     and g.codfam = f.codfam
     and f.codfam = p_codfamilia
     and f.codlinha = p_codlinha
   order by descricao;

begin

  htp.p('<script language="JavaScript" src="template_site.script_ajax_api"></script> ');

  if p_param_linha is not null then

    filtrorow;
    filtroheader('Linha:');

    htp.p('<td align=left>');
    htp.formselectopen(p_param_linha, cattributes=>'id="'||p_param_linha||'" onchange="populaFamilia(this.value)";');

    htp.p('  <option value="">Todas</option>');
    for x in c_buscalinha (p_codlinha) loop
      htp.p('  <option value="'||x.codlinha||'" ' || x.selected ||'>'||x.descricao||'</option>');
    end loop;

    htp.formselectclose;
    htp.p('</td>');

    rowclose;
  end if;

  if p_param_familia is not null then
    filtrorow;
    filtroheader('FamÌlia:');

    htp.p('<td align=left>');
    htp.formselectopen(p_param_familia, cattributes=>'onchange="populaGrupo(document.getElementById('''||p_param_linha||''').value, this.value);" id="'||p_param_familia||'"');
    htp.p('  <option value="">Todas</option>');
    
    for  x in c_buscafamilia(p_codlinha, p_codfam) loop
      htp.p('  <option value="'||x.codfam||'" ' || x.selected ||'>'||x.descricao||'</option>');
    end loop;

    htp.formselectclose;
    htp.p('</td>');

    rowclose;
  end if;

    if p_param_grupo is not null then
      filtrorow;
      filtroheader('Grupo:');

      htp.p('<td align=left>');
      htp.formselectopen(p_param_grupo, cattributes=>'id="'||p_param_grupo||'"');
      htp.p('  <option value="">Todos</option>');
      for  x in c_buscagrupo(p_codlinha, p_codfam, p_codgrupo ) loop
        htp.p('  <option value="'||x.codgrupo||'" ' || x.selected ||'>'||x.descricao||'</option>');
      end loop;

      htp.formselectclose;
      htp.p('</td>');

      rowclose;
    end if;

    template.script('
      function populaFamilia(cod_linha) {
        var objParam = new ajax.colombo.ParamRequest();
        var obj = "'|| p_param_familia ||'";
        var objGrupo = "'|| p_param_grupo ||'";
        
        var inst = document.getElementById(obj);
        var instGrupo = document.getElementById(objGrupo);

        for( var x=inst.options.length; x>=0; x--)
             inst.options[x] = null;

        for( var x=instGrupo.options.length; x>=0; x--)
             instGrupo.options[x] = null;

        objParam.url = "template_site.busca_familia_xml";
        objParam.returnXML = true;
        objParam.method    = "POST";
        objParam.paramPost = "p_codlinha="+cod_linha;

        objParam.onFinished = function(data){
          var options = data.getElementsByTagName("familia");

          inst.options[inst.options.length] = new Option(''Todas'','''');
          instGrupo.options[instGrupo.options.length] = new Option(''Todos'','''');

          for( var i=0; i<options.length; i++){

               var item = options[i];

               var value = item.attributes[0].nodeValue;
               var label = item.firstChild.nodeValue;

               inst.options[inst.options.length] = new Option(label,value);
          }
        }
        ajax.colombo.executeOnAjax( objParam );
      }
    ');

  template.script('
    function populaGrupo(cod_linha, cod_familia) {
    
      var obj = "'|| p_param_grupo ||'";
      var inst = document.getElementById(obj);
       var objParam = new ajax.colombo.ParamRequest();
      
      for( var x=inst.options.length; x>=0; x--)
        inst.options[x] = null;

      objParam.url = "template_site.busca_grupo_xml";
      objParam.returnXML = true;
      objParam.method    = "POST";
      objParam.paramPost = "p_codlinha="+cod_linha+"&p_codfamilia="+cod_familia;

      objParam.onFinished = function(data){      
        var options = data.getElementsByTagName("grupo");
        inst.options[inst.options.length] = new Option(''Todos'','''');
        
        for( var i=0; i<options.length; i++){
          var item = options[i];
          var value = item.attributes[0].nodeValue;
          var label = item.firstChild.nodeValue;
          inst.options[inst.options.length] = new Option(label,value);
        }
      }

      ajax.colombo.executeOnAjax( objParam );
    }');


end filtro_linha_familia_ajax;

/*********************************************************************************************************************/
procedure filtro_linha_familia_ajax (p_param_linha in varchar2 default null,
                                     p_param_familia in varchar2 default null,
                                     p_param_grupo in varchar2 default null) is
begin
  filtro_linha_familia_ajax(p_param_linha,
                            null,
                            p_param_familia,
                            null,
                            p_param_grupo,
                            null);
end;

/*********************************************************************************************************************/

procedure busca_linha_xml is

  cursor c_buscalinha is
  select codlinha, descricao
    from web_linha
   order by descricao;

begin

  owa_util.mime_header(ccontent_type => 'text/xml');
  htp.p('<?xml version="1.0" encoding="iso-8859-1"?>');
  htp.p('<linhas>');

  for  x in c_buscalinha loop
    htp.p('<linha codlinha="'||x.codlinha||'"><![CDATA['||x.descricao||']]></linha>');
  end loop;

  htp.p('</linhas>');

end busca_linha_xml;

/*********************************************************************************************************************/
procedure busca_familia_xml(p_codlinha in number) is

  cursor c_buscafamilia(cod_linha in number) is
  select codlinha, codfam, descricao
    from web_familia
   where flativo = 'S'
     and codlinha = cod_linha
   order by descricao;

begin

  owa_util.mime_header(ccontent_type => 'text/xml');
  htp.p('<?xml version="1.0" encoding="iso-8859-1"?>');
  htp.p('<familias>');

  for  x in c_buscafamilia(p_codlinha) loop
    htp.p('<familia codfam="'||x.codfam||'"><![CDATA['||x.descricao||']]></familia>');
  end loop;

  htp.p('</familias>');

end busca_familia_xml;

/*********************************************************************************************************************/
procedure busca_grupo_xml(p_codlinha in number,
                          p_codfamilia in number) is

  cursor c_buscagrupo(p_codlinha in number,
                      p_codfamilia in number) is
  select f.codlinha, f.codfam,
         g.codgrupo, g.descricao descricao
    from web_grupo g,
         web_familia f
   where g.flativo = 'S'
     and f.flativo = 'S'
     and g.codfam = f.codfam
     and f.codfam = p_codfamilia
     and f.codlinha = p_codlinha
   order by descricao;

begin

  owa_util.mime_header(ccontent_type => 'text/xml');
  htp.p('<?xml version="1.0" encoding="iso-8859-1"?>');
  htp.p('<grupos>');

  for  x in c_buscagrupo(p_codlinha, p_codfamilia ) loop
    htp.p('<grupo codgrupo="'||x.codgrupo||'"><![CDATA['||x.descricao||']]></grupo>');
  end loop;

  htp.p('</grupos>');

end busca_grupo_xml;

/*********************************************************************************************************************/
procedure busca_produto_xml(p_codlinha in number,
                            p_codfamilia in number,
                            p_codgrupo in number) is

  cursor c_buscaproduto(p_codlinha in number,
                        p_codfamilia in number,
                        p_codgrupo in number) is
  select f.codlinha, f.codfam,
         g.codgrupo, p.codprod, p.descricao descricao
    from web_grupo g,
         web_familia f,
         web_prod p
   where g.flativo = 'S'
     and f.flativo = 'S'
     and p.flativo = 'S'
     and g.codfam = f.codfam
     and g.codgrupo = p.codgrupo
     and f.codfam = p_codfamilia
     and f.codlinha = p_codlinha
     and p.codgrupo = p_codgrupo
   order by descricao;

begin

  owa_util.mime_header(ccontent_type => 'text/xml');
  htp.p('<?xml version="1.0" encoding="iso-8859-1"?>');
  htp.p('<produtos>');

  for  x in c_buscaproduto(p_codlinha, p_codfamilia, p_codgrupo ) loop
    htp.p('<produto codproduto="'||x.codprod||'"><![CDATA['||x.descricao||']]></produto>');
  end loop;

  htp.p('</produtos>');

end busca_produto_xml;


/*********************************************************************************************************************/
procedure busca_item_xml(p_codlinha in number,
                         p_codfamilia in number,
                         p_codgrupo in number,
                         p_codproduto in number) is

  cursor c_buscaitem(p_codlinha in number,
                        p_codfamilia in number,
                        p_codgrupo in number,
                        p_codproduto in number) is
  select f.codlinha, f.codfam,
         g.codgrupo, p.codprod, i.coditprod,
         i.especific || case when i.especific is not null and i.cor is not null then ' - ' else '' end || i.cor descricao
    from web_grupo g,
         web_familia f,
         web_prod p,
         web_itprod i
   where g.flativo = 'S'
     and f.flativo = 'S'
     and p.flativo = 'S'
     and i.flativo = 'S'
     and g.codfam = f.codfam
     and g.codgrupo = p.codgrupo
     and p.codprod = i.codprod
     and f.codfam = p_codfamilia
     and f.codlinha = p_codlinha
     and p.codgrupo = p_codgrupo
     and i.codprod = p_codproduto
   order by descricao;

begin

  owa_util.mime_header(ccontent_type => 'text/xml');
  htp.p('<?xml version="1.0" encoding="iso-8859-1"?>');
  htp.p('<itens>');

  for  x in c_buscaitem(p_codlinha, p_codfamilia, p_codgrupo, p_codproduto) loop
    htp.p('<item coditproduto="'||x.coditprod||'"><![CDATA['||x.descricao||']]></item>');
  end loop;

  htp.p('</itens>');

end busca_item_xml;

procedure busca_fornecedor_xml(p_linha varchar2, p_familia varchar2, p_grupo varchar2)is
  type t_crs is ref cursor;
  Cursor c_forne (p_codgrupo varchar2)is
    select codempresa,descricao
    from web_empresa
    where codempresa in (
                        select codempresa
                        from web_prod
                        where codgrupo = p_codgrupo
                        )
    order by descricao;

    v_cursor  t_crs;
    v_query varchar2(2000);
    v_descricao varchar2(300);
    v_codigo number;
  begin
    v_query := 'select
                distinct (emp.codempresa)as codigo ,
                emp.descricao
                from web_linha linha
                left join web_familia familia on linha.codlinha = familia.codlinha
                left join web_grupo grupo on familia.codfam = grupo.codfam
                left join web_prod prod on grupo.codgrupo = prod.codgrupo
                left join web_empresa emp on prod.codempresa= emp.codempresa
                where emp.codempresa is not null
                  and linha.codlinha = ' || p_linha;

      if (p_familia is not null and instr(p_familia,'Selecione') = 0) then
          v_query := v_query || ' and familia.codfam =  ' || p_familia;
      end if;

      if (p_grupo is not null and instr(p_grupo,'Selecione') = 0) then
          v_query := v_query || ' and grupo.codgrupo =  ' || p_grupo;
      end if;

      v_query := v_query || ' order by emp.descricao ';

      owa_util.mime_header(ccontent_type => 'text/xml');
      htp.p('<?xml version="1.0" encoding="iso-8859-1"?>');
      htp.p('<fornecedores>');

      open v_cursor for v_query;
        loop fetch v_cursor into v_codigo,v_descricao;
        exit when v_cursor%notfound;
          if(length(trim(v_descricao)) > 0 and  v_codigo is not null ) then
            htp.p('<fornecedor codforne="'||v_codigo||'"><![CDATA['||v_descricao||']]></fornecedor>');
          end if;

      end loop;
    htp.p('</fornecedores>');

  end busca_fornecedor_xml;
  
  /*********************************************************************************************************************/
  
  procedure pageend(scripts boolean default true) is
  begin
  if scripts then
    scriptinputstyle;
  end if;
    htp.bodyclose;
    htp.htmlclose;
  end;
  
  /*********************************************************************************************************************/

  procedure pageclose(p_links util.tarray default null, page_end boolean default true) is
  begin
    htp.br;
    if p_links is not null then
      for li in p_links.first .. p_links.last loop
        htp.p(p_links(li) || ' ');
      end loop;
    end if;
    script('if (opener) document.write(''' || htf.anchor('javascript:this.close();','<img src="'||path||'bt_fechar.gif" border=0 onfocus=this.blur();>') || '''); else document.write(''' || htf.anchor('javascript:history.go(-1);','<img src="'||path||'bt_retornar.gif" border=0 onfocus=this.blur();>', null, 'class="btnVoltar"') || ''');');


    -- FIM TABELAS DO PAGEOPEN----------------------------------------------------------------------------------------------------------------
    htp.p('
                                        <br><br>
                                        </td>
                                  </tr>
                                </table>
                            </td>
                      </tr>
                    </table>
              </td>
            </tr>
            <tr class="botton">
              <td height="4" bgcolor="D7E4EE"></td>
            </tr>
            <tr class="botton">
              <td height="30" align="center" background="'||path||'bg_rodape.gif" bgcolor="#2E81CE"><font color="#FFFFFF">&copy;
                2007 Colombo.com.br - Todos os direitos reservados.</font></td>
            </tr>
          </table></td>
      </tr>
    </table>');

  if page_end then
    pageend;
  end if;

  end;

  /*********************************************************************************************************************/

end template_site;
/
