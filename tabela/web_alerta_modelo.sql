/*
  CREATE TABLE "WEBSITE"."WEB_ALERTA_MODELO" 
   (	"CODIGO" NUMBER(10,0) NOT NULL ENABLE, 
	"HTML" CLOB, 
	"FLATIVO" VARCHAR2(1 BYTE), 
	"DESCRICAO" VARCHAR2(20 BYTE), 
	"URL" VARCHAR2(100 BYTE), 
	"CSS" CLOB, 
	"JS" CLOB, 
	 CONSTRAINT "WEB_ALERTA_MODELO_PK" PRIMARY KEY ("CODIGO") ENABLE
   );
 */

insert into web_alerta_modelo(codigo,html,flativo,descricao,url,css,js)values(seq_web_alerta_modelo.nextval,
' <div id="conteudoAlerta"></div>','S','Modelo Customizável','/informacoesAlerta',null,'$(document).ready(function(){
$("#fancybox-inner #conteudoHtmlAlerta input[type=button]").live("click",function(){
var data = $("#fancybox-inner #conteudoHtmlAlerta input,#fancybox-inner #conteudoHtmlAlerta select").not($("#fancybox-inner #conteudoHtmlAlerta input[type=button],#fancybox-inner #conteudoHtmlAlerta input[type=submit]"+
      ",#fancybox-inner #conteudoHtmlAlerta input[type=checkbox]")).serialize();
 data += "&"+$("#codigoAlerta").serialize();
      
      var checkValues = new Array();
      $("#fancybox-inner #conteudoHtmlAlerta input[type=checkbox]:checked").each(function(){
          var that = $(this);
          if(checkValues[that.attr("name")]){
              checkValues[that.attr("name")] = checkValues[that.attr("name")] + "," + that.val();
          }else{
              checkValues[that.attr("name")] = that.val();
          }        
      });
      
      for (key in checkValues) {
        data += "&" + key + "=" + checkValues[key];
      }
      
$.ajax({
url: $("#urlAlertaPost").val(),
type: "post",
data: data,
        dataType: "json",
success: function(retorno){
          if(retorno && retorno.status === "ok"){
            $("#fancybox-inner #conteudoHtmlAlerta").remove();
            $("#fancybox-inner").html("<div style=\"text-align: center;margin-top: 13%;\">"+retorno.mensagem+"</div>");
          }else if(retorno && retorno.status === "erro"){
            $("#fancybox-inner #conteudoHtmlAlerta").remove();
            $("#fancybox-inner").html("<div style=\"text-align: center;margin-top: 13%;\">"+retorno.mensagem+"</div>"+
            "<a href=\"javascript:;\" onclick=\"colomboAlerta.exibeAlertaHtml();\"><div style=\"text-align: center;margin-top: 8%;\">Tentar novamente.</div></a>");
          }
},
error:function(e){
$("#fancybox-inner #conteudoHtmlAlerta").remove();
            $("#fancybox-inner").html("<div style=\"text-align: center;margin-top: 13%;\">Ocorreu um erro ao salvar, por favor tente novamente.</div>"+
            "<a href=\"javascript:;\" onclick=\"colomboAlerta.exibeAlertaHtml();\"><div style=\"text-align: center;margin-top: 8%;\">Tentar novamente.</div></a>");
}
});
});
});');

insert into web_alerta_modelo(codigo,html,flativo,descricao,url,css,js)values(seq_web_alerta_modelo.nextval,
' <div id="conteudoAlerta"></div>','S','Modelo Newsletter','/newsletterAlerta',null,'$(document).ready(function(){

    $("#fancybox-inner #conteudoHtmlAlerta input[name=atributo1],#fancybox-inner #conteudoHtmlAlerta input[name=atributo2]").live("focus",function(){
      $(this).val("");
      $(this).css("color","black");
    });

$("#fancybox-inner #conteudoHtmlAlerta input[type=button]").live("click",function(){
var data = $("#fancybox-inner #conteudoHtmlAlerta input[type=text]").serialize();
data += "&"+$("#codigoAlerta").serialize();
$.ajax({
url: $("#urlAlertaPost").val(),
type: "post",
data: data,
dataType: "json",
success: function(retorno){
 if(retorno && retorno.status === "ok"){
$("#fancybox-inner #conteudoHtmlAlerta").remove();
$("#fancybox-inner").html("<div style=\"text-align: center;margin-top: 13%;\">"+retorno.mensagem+"</div>");
 }else if(retorno && retorno.status === "erro"){
              if(retorno.mensagemEmail){
                  var $input = $("#fancybox-inner #conteudoHtmlAlerta input[name=atributo2]");
                  $input.css("color","red");
                  $input.val(retorno.mensagemEmail);
              }else if(retorno.mensagemNome){
                  var $input = $("#fancybox-inner #conteudoHtmlAlerta input[name=atributo1]");
                  $input.css("color","red");
                  $input.val(retorno.mensagemNome);
              }else if(retorno.mensagem){
                  $("#fancybox-inner #conteudoHtmlAlerta").remove();
                  $("#fancybox-inner").html("<div style=\"text-align: center;margin-top: 13%;\">"+retorno.mensagem+"</div>"+
                  "<a href=\"javascript:;\" onclick=\"colomboAlerta.exibeAlertaHtml();\"><div style=\"text-align: center;margin-top: 8%;\">Tentar novamente.</div></a>");
              }
          }
},
error:function(e){
$("#fancybox-inner #conteudoHtmlAlerta").remove();
           $("#fancybox-inner").html("<div style=\"text-align: center;margin-top: 13%;\">Ocorreu um erro ao salvar, por favor tente novamente.</div>"+
            "<a href=\"javascript:;\" onclick=\"colomboAlerta.exibeAlertaHtml();\"><div style=\"text-align: center;margin-top: 8%;\">Tentar novamente.</div></a>");
}
});
});
});');



