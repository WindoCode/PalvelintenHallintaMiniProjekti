# PalvelintenHallintaMiniProjekti

## Työn tavoite
- Tämän miniprojektin tavoitteena on luoda LAMP-stack SaltStackin ja Vagrantin avulla, jossa on yksi master-palvelin ja kaksi minion-palvelinta. Kertaan tällä projektilla kurssin aiheita ja hieman uutta.
- Asennamme ja konfiguroimme molemmille minioneille: Käyttöjärjestelmän-Linux, Web-serverin-Nginx,Ohjelmointikielen-Python sekä Tietokannan-PostgreSQL.

## Virtuaalikoneiden tekeminen

- Käytämme pohjana tällä kurssilla tutuksi tullutta pohjaa virtuaalikoneiden rakentamiseen, jota käytimme kurssin toisessa kotitehtävässä.
(Ready made Vagrantfile for three computers)[https://terokarvinen.com/2023/salt-vagrant/].

- `sudo apt-get update`
- `sudo apt-get -y install virtualbox vagrant micro`

- `mkdir salt; cd salt`
- `nano Vagrantfile`
- 
```
" # -*- mode: ruby -*-
# vi: set ft=ruby :
# Copyright 2014-2023 Tero Karvinen http://TeroKarvinen.com

$minion = <<MINION
sudo apt-get update
sudo apt-get -qy install salt-minion
echo "master: 192.168.12.3">/etc/salt/minion
sudo service salt-minion restart
echo "See also: https://terokarvinen.com/2023/salt-vagrant/"
MINION

$master = <<MASTER
sudo apt-get update
sudo apt-get -qy install salt-master
echo "See also: https://terokarvinen.com/2023/salt-vagrant/"
MASTER

Vagrant.configure("2") do |config|
	config.vm.box = "debian/bullseye64"

	config.vm.define "t001" do |t001|
		t001.vm.provision :shell, inline: $minion
		t001.vm.network "private_network", ip: "192.168.12.100"
		t001.vm.hostname = "t001"
	end

	config.vm.define "t002" do |t002|
		t002.vm.provision :shell, inline: $minion
		t002.vm.network "private_network", ip: "192.168.12.102"
		t002.vm.hostname = "t002"
	end

	config.vm.define "tmaster", primary: true do |tmaster|
		tmaster.vm.provision :shell, inline: $master
		tmaster.vm.network "private_network", ip: "192.168.12.3"
		tmaster.vm.hostname = "tmaster"
	end
end
```

- `vagrant up`

- Tämän jälkeen kävin päivittämässä molemmille koneille minion tiedoston, jossa sijaitsee masterin IP.
- `vagrant ssh t001` / `vagrant ssh t002`
- `cd /etc/salt`
- `sudo nano minion` - Tiedostoon päivitimme masterin ip:n.
- `systemctl restart salt-minion`
- `logout`

- Tämän jälkeen hyväksymme minioneiden avaimet masterilla. Testaamme vielä yhteyttä: `sudo salt '*' cmd.run 'hostname -I`

![image](https://github.com/WindoCode/PalvelintenHallintaMiniProjekti/assets/110290723/c7c4b125-8dea-49f7-9ba3-67e526ce3d69)


## Web-serveri: Nginx

- Ensimmäiseksi luomme kansion tilalle: nginx. Teemme tämän projektikansion sisälle nimeltä lamp. `mkdir nginx`.
- Seuraavaksi luomme tilan nimeltä nginx:

```
nginx:
  pkg:
    - installed
  service.running:
    - require:
      - pkg: nginx
```

- Ajamme tämän tilan kaikilla minioneilla: `sudo salt ’*’ state.apply nginx`

- Testataan vielä, avautuuko nginx-sivu selaimessamme, kokeillaan ensiksi t001-minionin sivua, osoitteessa http://192.168.12.102/ . Voimme sen todeta avautuneen! Kokeilin vielä t002:n sivustoa, joka toimi.

![image](https://github.com/WindoCode/PalvelintenHallintaMiniProjekti/assets/110290723/01176675-cd87-4e96-acae-83b5992242ff)

## Ohjelmistokieli: python3

- Ensiksi teemme tilalle kansion : python. Teemme tämän /srv/salt-kansioon. `mkdir python`.
- Seuraavaksi luomme python-kansioon skriptin: python.sh
- Sisällytämme komennon: `sudo apt-get python3` skriptiin.

![image](https://github.com/WindoCode/PalvelintenHallintaMiniProjekti/assets/110290723/a0d466fe-8e6c-4959-9cb7-018f433909f6)

- Luomme init.sls tiedoston, joka suorittaa tämän skriptin jokaisella minionilla: `

![image](https://github.com/WindoCode/PalvelintenHallintaMiniProjekti/assets/110290723/73676acc-02d9-4933-bac6-fee71a52e567)

-Lopuksi ajamme tämän salt-tilan kaikilla minioneilla: `sudo salt '*' state.apply python`

- Testataan vielä minionilla: python3

![image](https://github.com/WindoCode/PalvelintenHallintaMiniProjekti/assets/110290723/c9b96a91-efa3-4484-ad3b-d296dc0e47f6)


## Tietokanta: Postgresql

- Luomme tilalle kansion: postgresql
- Seuraavaksi kirjoitamme init.sls tiedoston

![image](https://github.com/WindoCode/PalvelintenHallintaMiniProjekti/assets/110290723/8885d097-716f-4112-8c61-944c7ded30cb)

- init.sls tiedosto sisältää kaksi erillistä komentoa, joista ensimmäinen asentaa PostgreSQL:n. Toinen komento luo käyttäjän nimeltä vagrant ja tietokannan nimeltä vagrant. Komento suoritetaan postgres-käyttäjänä ja se tarkistaa, onko käyttäjää vagrant jo olemassa. Mikäli ne on jo olemassa, komento ei tee mitään.
-  Lopulta voimme ajaa tämän tilan: `sudo salt '*' state.apply postgres`.

![image](https://github.com/WindoCode/PalvelintenHallintaMiniProjekti/assets/110290723/e1e8fdd9-b607-40a4-a7a6-81ce092b1166)

- Komento toimii ja se toimii myös idempodentisti. Testataan vielä minioneilla, toimiiko postgres ja onko salt rakentanut uuden tietokannan: vagrant. Nämä saamme tietoon minionilla komennoilla `psql` sekä `\list`. Voimme todeta, että näin on tapahtunut!

![image](https://github.com/WindoCode/PalvelintenHallintaMiniProjekti/assets/110290723/7c0a0593-484d-4a77-a36c-7b5b1c30068e)

## top.sls-tiedoston luominen

- Koska en halua tehdä näitä kaikkia tiloja yksitellen, voimme luoda top.sls-tiedoston.
- Luomme tiedoston `/srv/salt` - kansioon.

![image](https://github.com/WindoCode/PalvelintenHallintaMiniProjekti/assets/110290723/f3dc4244-96a6-4dcd-bece-b30ca9d1f1d1)

- Voimme kansiossa ajaa nyt koko moduulin. `sudo salt '*' state.apply`.

![image](https://github.com/WindoCode/PalvelintenHallintaMiniProjekti/assets/110290723/9bbe4e5e-cece-45ac-bdd1-9538fcbdf9e9)

## Loppumietteet projektista ja kurssista

- Opin






