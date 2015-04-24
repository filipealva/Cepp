Cepp
====
iOS application written in [Swift](https://developer.apple.com/swift/).

Icon by: [Rodrigo Nascimento](https://github.com/rodrigok) (tks :D)

**IMPORTANT:** *This project uses [Cocoapods](http://cocoapods.org/) as the dependency manager, make sure you have it installed. After download or clone it, apply the following command in the directory of the project:
```bash 
pod install 
``` 
and then open **Cepp.xcworkspace** file.

**NOTE:** To run this project you'll need Swift 1.1.

**[Available at the Brazilian AppStore](https://itunes.apple.com/br/app/cepp-encontre-ceps/id942709971?ls=1&mt=8)**

© 2014 Filipe Alvarenga

## About

It's a simple application that can find details about an address based on a given zipcode (a.k.a CEP in Brazil). The user also can trace a route in the map using througt Cepp. The API which this app uses to search the information about zipcodes works only with brazilian zipcodes.


This application uses the [Aviso Brasil] (http://avisobrasil.com.br/correio-control/api-de-consulta-de-cep/) API to get the information of a zipcode and the Google Geocoding Service througt the wrapper [SVGeocoder](https://github.com/TransitApp/SVGeocoder) to get the geolocalization.

## Open-source

I've made it open-source to share with the people the way that I used Swift to make this application. 

*P.S: This is my first application written in Swift, and it was written when Swift had 5 months of life. I've learnt a lot after I wrote it and I hope to refactor this project to share with you a better way to write it with Swift soon.*

Feel free to submit a pull request if you have any improvement to sugest. If you have a feedback or wants to talk with me you can send me an e-mail: ofilipealvarenga [at] gmail.com :)

Screen Shots
====
![alt tag](https://raw.github.com/filipealva/Cepp/res/searchi5.png)
![alt tag](https://raw.github.com/filipealva/Cepp/res/detailsi5.png)

