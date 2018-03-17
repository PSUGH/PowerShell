# Docker dir einen
Christian Imhorst (@datenteiler)

## Was ist Docker?

* Server-Apps, die alles, was sie brauchen, schon mitbringen
* Container kapseln alle Eigenheiten
* Frachtcontainer: Unabhängig vom Inhalt immer gleiche Abmessung
* Erleichterte Installation und Betrieb
* Löscht man das Image, sind alle Spuren vom System verschwunden
* Container gab es früher auch schon, Docker hat Boom ausgelöst

## Was ist Docker nicht?

* Docker startet kein eigenes Betriebssystem
* Container sind keine Virtuellen Maschine, sie nutze Kernel des Host
* Entsprechender Kernel muss sonst auf dem Host virtualisiert werden
* Alle Container laufen auf demselben Kernel
* Nur Userland ist verschieden
* Docker emuliert keine Hardware
* Man bekommt keinen Windows auf einem Linux-Server

## Ist Docker Virtualisierung light?

* Trennung vom Host erfolgt über Prozess und IPC-Namensräume
* Jeder Container kann eigene
1. IP-Adresse
2. Routing-Tabellen
3. Host- und Domännamen
4. gleiche Ports auf unterschiedlichen Host-Ports
haben

## Vorteile von Docker?

* Docker schleppt nicht den Overhead Virtueller Maschinen mit
* Ein Webserver kostet in Docker soviel Ressource wie auf dem Host
* Hunderte Container können gleichzeitig laufen
* Container laufen in Virtuellen (Linux)-Maschinen
* Erhöhte Sicherheit durch Container:
* Kein Zugriff auf Host-Anwendungen
* Wenig Tools im Container

###  Aber: Sie teilen sich alle einen Kernel.

## Riesenvorteil von Docker?

* Der Docker-Hub: Fertige Images stehen zum Download bereit
* Aus jedem Image können beliebig viele Container gestartet werden
* Last von Webapps kann besser verteilt werden (Micro-Services)
* Kaum Handarbeit == Hohes Maß an Automatisierung

## Einstieg in Docker

* Die Minimal-Installation eines Debian Images:

  `docker pull debian`

* Ein erster Container mit dem Image und (i)neraktivem (t)erminal:

  `docker run --name=Debby -it debian bash`

* Alle laufenden Container anzeigen:
 
  `docker ps`

* Container stoppen:

  `docker stop Debby`

* Container löschen:

  `Docker rm Debby`

## Containerumschlag

* Docker ist aber für den Einsatz als Application Container gedacht:

  ```
  mkdir /srv/mysqldata

  docker run -d --name mysql-container -v /srv/mysqldata/:/var/lib/mysql/ -e MYSQL_ROOT_PASSWORD=mysqlpwd mysql

  docker run -d --name wordpress-container --link mysql-container:mysql -p 8080:80 wordpress
  ```

## Wegwerfprinzip

* Kaputte Container werden gelöscht und neue werden gestartet
* Neue Software kann schnell getestet werden:
* Funktioniert sie im neuen Container, wirft man den alten weg
* Funktioniert sie nicht, nimmt man den wieder den alten Container
* Container müssen dafür „stateless“ sein: Keine Zustandsdaten
* Externe Verzeichnisse werden mit -v eingehängt
* Konfigurationsdateien überlagert
* Umgebungsvariablen mit -e überschreibt
  
## Containerwartung

* Logfiles aus einem Docker Container zeigt

  `docker logs wordpress-container`

* In einen laufenden Container mit Konsole einsteigen:

  `docker exec -t -i wordpress-container bash`

* Alle Container/Images anzeigen:

  `docker ps -a –q / docker images -q`
  
* Dateien in einen Container kopieren:

  `docker cp C:\Path\To\My\Code MyContainer:/tmp`
  
* Aktuelles Verzeichnis einbinden

  `docker run --rm -v ${PWD}:/data alpine ls /data`
  
* Größe der Images anzeigen

  `docker system df`
  
## Container selber backen

* Das Rezept für einen schnellen Nginx-Webserver
* Eine index.html erstellen:

     `<html><body><h1>Hallo #PSUGH</h1><p>Das ist mein Nginx.</p></body></html>`

* Ein _Dockerfile_ mit dem Rezept:

```
  FROM debian
  MAINTAINER "Christian Imhorst <@datenteiler>"
  RUN apt-get update && apt-get install -y nginx && apt-get autoclean
  ADD index.html /var/www/html/
  EXPOSE 80
  CMD ["nginx", "-g", "daemon off;"]
```

* Und ab in den Ofen:
 
  `docker build -t psugh .`
  
* Und schon kann der Webserver gestartet werden und über http://localhost:8081/ aufrufen.

  `docker run -d -p 8081:80 psugh`
  
  
