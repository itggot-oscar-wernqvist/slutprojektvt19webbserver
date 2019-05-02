# slutprojektvt19webbserver

# Projektplan

## 1. Projektbeskrivning

Ett webforum likt reddit med stöd för bilder. Inloggningssystem. Man ska kunna göra posts med bilder och sedan kunna kommentera på posts. Det ska finnas en huvusida där man ska kunna rösta på posts. Man ska på huvudsidan kunna sortera posts efter nyast, mest uppröstat och mest kommenterat. 

## 2. Vyer (sidor)

### En loginsida

### En huvudsida ('/')
    Där man kan sortera och upvotea posts

### En publik profilsida  ('/user/:id')
    Där man kan se någon annans profil och posts

### En post-sida ('/post/:id')
    Där man kan se posten och kommentarer till denna
    Man ska kunna upvotea posten
    Man ska kunna skriva kommentarer och ta bort dem ifall man har skrivit dem

### En admin-sida ('/admin')
    Där man kan skriva en post
    Man kan ta bort och redigera sina posts

## 3. Funktionalitet (med sekvensdiagram)

Upvote-system
![](https://i.imgur.com/xHF89Rk.png)

Kommentarsfunktion

skriva post- funktion

## 4. Arkitektur (Beskriv filer och mappar)

Följa MVC, 
en views-mapp med alla slim, en slim per sida + layout
en controller fil - app.rb
en db-fil - database.rb
databasen i db mapp


## 5. (Databas med ER-diagram)

![](https://i.imgur.com/VTEJHTf.png)