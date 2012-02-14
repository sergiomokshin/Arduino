/*
  Web  Server

 criado em 09/02/2012
 Adaptação WebServer para monitoramento de entradas análogicas, digitais e acionamento de saídas digitais
 por Sérgio de Miranda e Castro Mokshin
 

 Protocolo para acionar saída
 ligar saida 3 IS31
 desligar saida 3 IS30
 
 */
#define BUFSIZ 100
#include <SPI.h>
#include <Ethernet.h>

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,1, 70 };
char entradas [] = {'E','0','0','0','0','0','0','0','0'};

Server server(80);
char clientline[BUFSIZ];
char comando[BUFSIZ];
int index;
int tamanhocomando;

boolean inicioComando1;
boolean inicioComando2;
boolean fimComando;
int indiceentrada;
void setup()
{
  
  pinMode(0, OUTPUT);     
  pinMode(1, OUTPUT);     
  pinMode(2, OUTPUT);     
  pinMode(3, OUTPUT);     
  pinMode(4, OUTPUT);     
  pinMode(5, OUTPUT);     
  pinMode(6, OUTPUT);     
  pinMode(7, OUTPUT);       
  
  digitalWrite(0, LOW);
  digitalWrite(1, LOW);
  digitalWrite(2, LOW);
  digitalWrite(3, LOW);
  digitalWrite(4, LOW);
  digitalWrite(5, LOW);
  digitalWrite(6, LOW);
  digitalWrite(7, LOW);
 
  pinMode(8, INPUT);     
  pinMode(9, INPUT);     
  pinMode(10, INPUT);     
  pinMode(11, INPUT);     
  pinMode(12, INPUT);     
  
  Serial.begin(9600);
  Ethernet.begin(mac, ip);
  server.begin();
  inicioComando1 = false;
  inicioComando2 = false;
  fimComando = false;
  indiceentrada = 0;
  
}

void loop()
{
  AguardaComandosWEB(); 
}

void AguardaComandosWEB()
{   
  index = 0;
  tamanhocomando = 0;
  Client client = server.available();
  if (client) {  
    boolean currentLineIsBlank = true;
    while (client.connected()) {
      if (client.available()) {
        
        char c = client.read();        
        if (c != '\n' && c != '\r') {
          clientline[index] = c;
          index++;
           if (index >= BUFSIZ) 
              index = BUFSIZ -1;       
          continue;
        }             
          Serial.print(index);
          Serial.print("-");
          Serial.print(clientline);
          
          clientline[index] = 0;               
          DisparaComando();               
          Header(client); 
          Inputs(client);
          Outputs(client);                                       
          Footer(client);   
          break;
      }
    }
    delay(1);
    client.stop();
  }
}

void DisparaComando()
{  
    boolean iniciocomando = false;       
    for (int i = 0; i<index ; i++)
    {    
         if(clientline[i] == 'I')
         {
            iniciocomando = true;
         }
         else if(clientline[i] == 'F')
         {
            break;               
         }               
         else if(iniciocomando)
         {
            comando[tamanhocomando] = clientline[i];
            tamanhocomando++;                                                           
         }                           
    }                

    comando[index] = 0;      
    if (comando[0] == 'S')
    {
       DisparaSaida();      
    }       
}

void DisparaSaida()
{
    int nivel = 0;
    if(comando[2] == '0') 
    {
         nivel = 0;   
    }     
    else  
    {
         nivel = 1;   
    }     
    char pin =  comando[1];
       
  switch (pin) {
     case '0':
	 digitalWrite(0, nivel);
	 break;
     case '1':
	 digitalWrite(1, nivel);
	 break;
     case '2':
	 digitalWrite(2, nivel);
	 break;
     case '3':
	 digitalWrite(3, nivel);
	 break;
     case '4':
	 digitalWrite(4, nivel);
	 break;
     case '5':
	 digitalWrite(5, nivel);
	 break;
     case '6':
	 digitalWrite(6, nivel);
	 break;
     case '7':
	 digitalWrite(7, nivel);
	 break;
     }
 }

void Header(Client client)
{
  client.println("HTTP/1.1 200 OK");
  client.println("Content-Type: text/html");
  client.println();
  client.println("<html><head><title>Webserver</title>");
  client.println("</head> ");

  client.println("<style>");
  client.println(".QuadroSite{width: 960px;margin: 0 auto;}");
  client.println(".Banner{width: 970px;height: 120px;background-color:#3399CC;padding-top: 1px;}");
  client.println(".Principal{padding-top: 30px;width: 970px;background-color:#EEEEEE;height: 500px;margin: 0 auto;overflow:auto;}");
  client.println(".MainMonitor{width:100%;height:100%;position:relative;}");
  client.println(".BlocoMonitorEntrada{padding-left: 20px;margin-left: 20px;background-color: #FFFFFF;width:430px;height:430px;float:left;border:thin solid #CCCCCC;}");
  client.println(".BlocoItensMonitor{padding-top: 10px;}");
  client.println(".TextoSaida{float:left;margin-right:15px;}");        
  client.println(".IcoSaida{width:15px;height:15px;marging-left:50px;margin-right:10px;float:left}");
  client.println("h1{font-size:20px;margin-left: 10px;font-name: Calibri;color:white;padding-top: 5px;}");
  client.println("span{font-size:13px;font-name: Calibri;color:black;}");
  client.println("</style>");

  client.println("<body><div class='QuadroSite'>");
  client.println("<div class='Banner'><h1>WebServer Automacao</h1></div>");
  client.println("<div class='Principal'>");
 
}

void Inputs(Client client)
{
  client.print("<div class='BlocoMonitorEntrada'><div class='BlocoItensMonitor'>");
  client.print("Entradas Analogicas<br/>"); 
  client.println("<br/>");
  for (int analogChannel = 0; analogChannel <=5; analogChannel++) {
      client.print("<span>Entrada Analogica ");
      client.print(analogChannel);
      client.print(" = ");
      client.print(analogRead(analogChannel));
      client.println("</span><br/>");
  }          
  client.println("<br/><br/><br/>");
  client.print("Entradas Digitais<br/>"); 
  client.println("<br/>");      
    for (int digitalChannel = 8; digitalChannel <= 9; digitalChannel++) {
      client.print("<span>Entrada Digital ");
      client.print(digitalChannel-8);
      client.print(" = ");
      client.print(digitalRead(digitalChannel));
      client.println("</span><br/>");
    }    
  client.print("</div>");  
  client.print("</div>");  
}

void Outputs(Client client)
{
  client.print("<div class='BlocoMonitorEntrada'><div class='BlocoItensMonitor'>");
  client.print("Saidas Digitais<br/><br/>");         

    for (int digitalChannel = 0; digitalChannel <= 7; digitalChannel++) {
      
      client.print("<div class='IcoSaida' style='background-color:");                                    
      if(digitalRead(digitalChannel) == 1)
              client.print("red;'></div>");        
      else        
              client.print("lightgray;'></div>");   
              
      client.print("<span>Saida Digital&nbsp;");
      client.print(digitalChannel);
      client.print(" = ");
      client.print(digitalRead(digitalChannel));
      client.println("</span>");      
      client.print("<A HREF ='http://192.168.1.70/IS");
      client.print(digitalChannel);
      if(digitalRead(digitalChannel) == 1)
        client.print("0");
      else  
        client.print("1");
      client.print("'>&nbsp;Alterar saida</A>");

      client.print("");
      client.println("<br/>");      
    }
}

void Footer(Client client)
{
  client.println("</div></div></body></html>");
}






