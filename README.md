![image](https://github.com/WindoCode/PalvelintenHallintaMiniProjekti/assets/110290723/d926f970-d708-48dd-ab43-a8d69559fb14)# PalvelintenHallintaMiniProjekti

## Työn tavoite
- Tämän miniprojektin tavoitteena on luoda LAMP-stack SaltStackin ja Vagrantin avulla, jossa on yksi master-palvelin ja kaksi minion-palvelinta. Kertaan tällä projektilla kurssin aiheita ja hieman uutta.
- Asennamme ja konfiguroimme molemmille minioneille: Käyttöjärjestelmän-Linux, Web-serverin-Nginx,Ohjelmointikielen-Python sekä Tietokannan-MySQL.

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

## Ohjelmistokieli: python3

- Ensiksi teemme tilalle kansion : python. Teemme tämän /srv/salt-kansioon. `mkdir python`.
- Seuraavaksi luomme python-kansioon skriptin: python.sh
- Sisällytämme komennon: `sudo apt install python3` skriptiin.

![image](https://github.com/WindoCode/PalvelintenHallintaMiniProjekti/assets/110290723/a0d466fe-8e6c-4959-9cb7-018f433909f6)

- Luomme init.sls tiedoston, joka suorittaa tämän skriptin jokaisella minionilla: `


