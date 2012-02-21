/*
  Web  Server

 criado em 09/02/2012
 Adaptação WebServer para monitoramento de entradas análogicas, digitais e acionamento de saídas digitais
 por Sérgio de Miranda e Castro Mokshin
 
 Protocolo para acionar saída
 ligar saida 3 IS31
 desligar saida 3 IS30
 
 */
#define DHT11_PIN 0      // ADC0
#define BUFSIZ 100
#include <SPI.h>
#include <Ethernet.h>


byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,1, 70 };

Server server(80);
char clientline[BUFSIZ];
char comando[BUFSIZ];
int index;
int tamanhocomando;

boolean inicioComando1;
boolean inicioComando2;
boolean fimComando;


void setup(){
  
    DDRC |= _BV(DHT11_PIN);
  PORTC |= _BV(DHT11_PIN);
  Serial.begin(9600);
  Serial.println("Ready");


    
  for (int i=0;i<=7;i++){
    pinMode(i, OUTPUT);       
    digitalWrite(i, LOW);  
  } 
  for (int i=8;i<=12;i++) {
      pinMode(i, INPUT);     
  }
 
  Ethernet.begin(mac, ip);
  server.begin();
  inicioComando1 = false;
  inicioComando2 = false;
  fimComando = false;
   

}


void loop(){
  AguardaComandosWEB(); 
}

void AguardaComandosWEB(){   
  
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
          clientline[index] = 0;               
          DisparaComando();               
          PutHtml(client);          
          break;
      }
    }
    delay(1);
    client.stop();
  }
}
void PutHtml(Client client){
  Header(client); 
  Inputs(client);
  Outputs(client);                                       
  Footer(client);    
}

void DisparaComando(){  
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

void DisparaSaida(){
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

void Header(Client client){
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

void TemperaturaUmidade(Client client){  
byte dht11_dat[5];
  byte dht11_in;
  byte i;// start condition
	 // 1. pull-down i/o pin from 18ms
  PORTC &= ~_BV(DHT11_PIN);
  delay(18);
  PORTC |= _BV(DHT11_PIN);
  delayMicroseconds(40);
  DDRC &= ~_BV(DHT11_PIN);
  delayMicroseconds(40);
  
  dht11_in = PINC & _BV(DHT11_PIN);
  if(dht11_in)
  {
    client.println("dht11 start condition 1 not met");
    return;
  }
  delayMicroseconds(80);
  dht11_in = PINC & _BV(DHT11_PIN);
  if(!dht11_in)
  {
    client.println("dht11 start condition 2 not met");
    return;
  }
  
  delayMicroseconds(80);// now ready for data reception
  for (i=0; i<5; i++)
    dht11_dat[i] = read_dht11_dat();
  DDRC |= _BV(DHT11_PIN);
  PORTC |= _BV(DHT11_PIN);
  byte dht11_check_sum = dht11_dat[0]+dht11_dat[1]+dht11_dat[2]+dht11_dat[3];// check check_sum
  if(dht11_dat[4]!= dht11_check_sum)
  {
    client.println("DHT11 checksum error");
  }
  client.print("<span>Umidade Relativa = ");
  client.print(dht11_dat[0], DEC);
  client.print(".");
  client.print(dht11_dat[1], DEC);
  client.print("%</span>");
  client.print("<span>Temperatura = ");
  client.print(dht11_dat[2], DEC);
  client.print(".");
  client.print(dht11_dat[3], DEC);
  client.println("C</span>");
  
  
}

void Inputs(Client client){
  client.print("<div class='BlocoMonitorEntrada'><div class='BlocoItensMonitor'>");
  client.print("Entradas Analogicas<br/>"); 
  client.println("<br/>");
  
  
  TemperaturaUmidade(client);
  
  for (int analogChannel = 2; analogChannel <=5; analogChannel++) {
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

void Outputs(Client client){
  
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

void Footer(Client client){
  client.println("</div></div></body></html>");
}

byte read_dht11_dat()
{
  byte i = 0;
  byte result=0;
  for(i=0; i< 8; i++)
  {
    while(!(PINC & _BV(DHT11_PIN)));  // wait for 50us
    delayMicroseconds(30);
    if(PINC & _BV(DHT11_PIN)) 
      result |=(1<<(7-i));
    while((PINC & _BV(DHT11_PIN)));  // wait '1' finish
    }
    return result;
}



