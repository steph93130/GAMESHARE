require "faker"
require "open-uri"
# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
CONDITIONS = ["Unused", "Excellent", "Worn", "Disrepair"]
AGE = ["0-6", "6-12","12 et +"]
CATEGORY = ["Ambiance", "famille", "coopératif", "stratégie", "enquête", "solo", "à deux", "adulte"]
DEPOSIT = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 150]

  IMAGES_GAME = {
    "monopoly" => "https://cdn.cultura.com/cdn-cgi/image/width=1280/media/pim/23_244147_1_10_FR.jpg",
    "skyjo" => "https://b4049544.smushcdn.com/4049544/wp-content/uploads/2025/03/35084-d19-Skyjo.jpg?lossy=2&strip=1&webp=1",
    "uno" => "https://m.media-amazon.com/images/I/71n61AtC+VL._AC_SL1500_.jpg",
    "scrabble" => "https://cdn.cultura.com/cdn-cgi/image/width=1280/media/pim/77_241905_1_10_FR.jpg",
    "7 Wonders Duel" => "https://joueclub-joueclub-fr-storage.omn.proximis.com/Imagestorage/imagesSynchro/0/0/9a83031b0e2cde5f643c6f359ec68e0e6dc045da_06024252.jpeg",
    "Dobble Anarchy Pancakes" => "https://joueclub-joueclub-fr-storage.omn.proximis.com/Imagestorage/imagesSynchro/0/0/6184f9286500b24c1dd3eca416f2a280e57d7fdd_41151433_02.jpeg",
    "Catan Duel" => "https://joueclub-joueclub-fr-storage.omn.proximis.com/Imagestorage/imagesSynchro/0/0/38070c417b6d6312968121153535e3c88d96155f_06027542.jpeg",
    "Splendor" => "https://joueclub-joueclub-fr-storage.omn.proximis.com/Imagestorage/imagesSynchro/0/0/c6559d12ec8729ac0a79820be58f6c29cddb2fa1_06024261_03.jpeg"
  }

puts "nettoyage de la db booking message chat game user"
Booking.destroy_all
Message.destroy_all
Chat.destroy_all
Game.destroy_all
User.destroy_all

puts "Création des users"


bruno = User.create!(
username: "Bruno",
email: "bruno@wagon.fr",
password: "123456",
rating: rand(0.0..5),
address: "130 avenue sainte marguerite, nice"
)


celine = User.create!(
username: "Céline",
email: "celine@wagon.fr",
password: "123456",
rating: rand(0.0..5),
address: "197 promenade des anglais, nice"
)

stephane = User.create!(
username: "Stephane",
email: "stephane@wagon.fr",
password: "123456",
rating: rand(0.0..5),
address: "7 rue barberis, nice"
)

patrice = User.create!(
username: "patrice",
email: "patrice@wagon.fr",
password: "123456",
rating: rand(0.0..5),
address: "31 boulevard franck pilatte, nice"
)

puts "Creating des games..."


skyjo = Game.create!(
  title: "Skyjo",
  user: celine,
  condition: CONDITIONS.sample,
  player_number: 6,
  rent_duration: rand(2..15),
  age: AGE.sample,
  category: CATEGORY.sample,
  description: Faker::Lorem.paragraphs(number: 1),
  available: true,
  deposit: DEPOSIT.sample,
  rules: <<~RULES
    ## But du jeu

    Avoir le moins de points possible à la fin de la partie.

    ## Résumé des règles

    - Chaque joueur possède une grille de cartes face cachée.
    - À son tour, un joueur pioche ou prend la carte visible de la défausse.
    - Il peut remplacer une carte de sa grille ou défausser la carte piochée.
    - Les cartes révélées comptent dans le score du joueur.
    - La manche se termine quand un joueur a révélé toutes ses cartes.
    - Après plusieurs manches, le plus petit total gagne.
  RULES
)

file = URI.open(
  "https://res.cloudinary.com/dzzss6x1d/image/upload/v1780654697/skyjo_bb5vfn.webp"
)

skyjo.picture.attach(
  io: file,
  filename: "skyjo.webp",
  content_type: "image/webp"
)


monopoly =Game.create!(
  title: "Monopoly",
  user: bruno,
  condition: CONDITIONS.sample,
  player_number: 6,
  # picture: IMAGES_GAME["monopoly"],
  rent_duration: rand(2..15),
  age: AGE.sample,
  category: CATEGORY.sample,
  description: Faker::Lorem.paragraphs(number: 1),
  available: true,
  deposit: DEPOSIT.sample,
  rules: <<~RULES
    ## But du jeu

    Acheter des propriétés, construire des maisons et hôtels, puis faire payer des loyers aux autres joueurs.

    ## Résumé des règles

    - Chaque joueur lance les dés et avance son pion.
    - Si une propriété libre est atteinte, le joueur peut l'acheter.
    - Si la propriété appartient à un autre joueur, il faut payer un loyer.
    - Les groupes de couleur complets permettent de construire.
    - Un joueur est éliminé s'il ne peut plus payer ses dettes.
    - Le dernier joueur encore en jeu gagne la partie.
  RULES
)


file = URI.open(
  "https://res.cloudinary.com/dzzss6x1d/image/upload/v1780654691/monopoly_xpwelj.webp"
)

monopoly.picture.attach(
  io: file,
  filename: "monopoly_xpwelj.webp",
  content_type: "image/webp"
)



uno = Game.create!(
  title: "Uno",
  user: stephane,
  condition: CONDITIONS.sample,
  player_number: 8,
  # picture: IMAGES_GAME["uno"],
  rent_duration: rand(2..15),
  age: AGE.sample,
  category: CATEGORY.sample,
  description: Faker::Lorem.paragraphs(number: 1),
  available: true,
  deposit: DEPOSIT.sample,
  rules: <<~RULES
    ## But du jeu

    Être le premier joueur à ne plus avoir de cartes en main.

    ## Résumé des règles

    - Chaque joueur reçoit des cartes.
    - À son tour, il faut poser une carte de même couleur, même chiffre ou même symbole.
    - Si aucun coup n'est possible, le joueur pioche une carte.
    - Les cartes spéciales changent le sens, font passer un tour ou ajoutent des cartes à piocher.
    - Quand il ne reste qu'une carte, le joueur doit annoncer Uno.
    - Le premier joueur sans carte remporte la manche.
  RULES
)

file = URI.open(
  "https://res.cloudinary.com/dzzss6x1d/image/upload/v1780654702/uno_uufeck.webp"
)

uno.picture.attach(
  io: file,
  filename: "uno_uufeck.webp",
  content_type: "image/webp"
)


scrabble=Game.create!(
  title: "Scrabble",
  user: patrice,
  condition: CONDITIONS.sample,
  player_number: 4,
  # picture: IMAGES_GAME["scrabble"],
  rent_duration: rand(2..15),
  age: AGE.sample,
  category: CATEGORY.sample,
  description: Faker::Lorem.paragraphs(number: 1),
  available: true,
  deposit: DEPOSIT.sample,
  rules: <<~RULES
    ## But du jeu

    Former des mots sur le plateau pour marquer plus de points que les autres joueurs.

    ## Résumé des règles

    - Chaque joueur pioche des lettres.
    - À son tour, un joueur place un mot connecté aux mots déjà présents.
    - Les mots doivent être valides dans le dictionnaire choisi.
    - Les lettres et cases bonus donnent des points.
    - Le joueur complète sa main après avoir joué.
    - La partie se termine quand il n'y a plus de lettres ou plus de coups possibles.
  RULES
)

file = URI.open(
  "https://res.cloudinary.com/dzzss6x1d/image/upload/v1780654708/scrabble_cbnfgg.webp"
)

scrabble.picture.attach(
  io: file,
  filename: "scrabble_cbnfgg.webp",
  content_type: "image/webp"
)


wonders = Game.create!(
  title: "7 Wonders Duel",
  user: patrice,
  condition: CONDITIONS.sample,
  player_number: 6,
  # picture: IMAGES_GAME["7 Wonders Duel"],
  rent_duration: rand(2..15),
  age: AGE.sample,
  category: CATEGORY.sample,
  description: Faker::Lorem.paragraphs(number: 1),
  available: true,
  deposit: DEPOSIT.sample,
  rules: <<~RULES
    ## But du jeu

    Développer la civilisation la plus puissante face à un seul adversaire.

    ## Résumé des règles

    - La partie se joue en trois âges.
    - À chaque tour, un joueur choisit une carte disponible.
    - Les cartes permettent de produire des ressources, construire des bâtiments ou gagner des points.
    - La victoire peut arriver par domination militaire ou scientifique.
    - Si aucune victoire immédiate n'arrive, les points sont comptés à la fin du troisième âge.
    - Le joueur avec le meilleur score gagne la partie.
  RULES
)


file = URI.open(
  "https://res.cloudinary.com/dzzss6x1d/image/upload/v1780654713/duel_mwplyy.webp"
)

wonders.picture.attach(
  io: file,
  filename: "duel_mwplyy.webp",
  content_type: "image/webp"
)

anarchy = Game.create!(
  title: "Dobble Anarchy Pancakes",
  user: stephane,
  condition: CONDITIONS.sample,
  player_number: 6,
  # picture: IMAGES_GAME["Dobble Anarchy Pancakes"],
  rent_duration: rand(2..15),
  age: AGE.sample,
  category: CATEGORY.sample,
  description: Faker::Lorem.paragraphs(number: 1),
  available: true,
  deposit: DEPOSIT.sample,
  rules: <<~RULES
    ## But du jeu

    Être le premier joueur à gagner deux manches en posant rapidement ses cartes pancakes.

    ## Résumé des règles

    - Chaque joueur reçoit des cartes pancakes.
    - Au signal, tout le monde joue en même temps.
    - Il faut repérer un ingrédient commun entre ses cartes et celles des autres joueurs.
    - Quand un ingrédient commun est trouvé, le joueur pose sa carte sur la pile correspondante.
    - La rapidité et l'observation sont essentielles.
    - Le premier joueur à remporter deux manches gagne la partie.
  RULES
)

file = URI.open(
  "https://res.cloudinary.com/dzzss6x1d/image/upload/v1780656050/anarchy_li7ns3.webp"
)

anarchy.picture.attach(
  io: file,
  filename: "anarchy_li7ns3.webp",
  content_type: "image/webp"
)

catan = Game.create!(
  title: "Catan Duel",
  user: bruno,
  condition: CONDITIONS.sample,
  player_number: 2,
  # picture: IMAGES_GAME["Catan Duel"],
  rent_duration: rand(2..15),
  age: AGE.sample,
  category: "à deux",
  description: Faker::Lorem.paragraphs(number: 1),
  available: true,
  deposit: DEPOSIT.sample,
  rules: <<~RULES
    ## But du jeu

    Développer sa principauté de Catan plus efficacement que son adversaire.

    ## Résumé des règles

    - Chaque joueur commence avec une petite principauté.
    - Les dés produisent des ressources selon les cartes en jeu.
    - Les ressources servent à construire des routes, colonies, villes et bâtiments.
    - Les joueurs peuvent améliorer leur économie et renforcer leur stratégie.
    - Certaines cartes apportent des avantages ou gênent l'adversaire.
    - Le premier joueur à atteindre l'objectif de points remporte la partie.
  RULES
)

file = URI.open(
  "https://res.cloudinary.com/dzzss6x1d/image/upload/v1780656359/catan_sluoaz.webp"
)

catan.picture.attach(
  io: file,
  filename: "catan_sluoaz.webp",
  content_type: "image/webp"
)

splendor=Game.create!(
  title: "Splendor",
  user:celine,
  condition: CONDITIONS.sample,
  player_number: 4,
  # picture: IMAGES_GAME["Splendor"],
  rent_duration: rand(2..15),
  age: AGE.sample,
  category: CATEGORY.sample,
  description: "",
  available: true,
  deposit: DEPOSIT.sample,
  rules: <<~RULES
    ## But du jeu

    Devenir le marchand le plus prestigieux en achetant des cartes de développement.

    ## Résumé des règles

    - À son tour, un joueur prend des jetons, réserve une carte ou achète une carte.
    - Les jetons servent à payer les cartes de développement.
    - Les cartes achetées donnent des bonus permanents pour les prochains achats.
    - Certaines cartes rapportent des points de prestige.
    - Les nobles peuvent rejoindre un joueur qui possède les bons bonus.
    - La partie se termine quand un joueur atteint le seuil de points requis.
  RULES
)


file = URI.open(
  "https://res.cloudinary.com/dzzss6x1d/image/upload/v1780656489/splendor_kk9den.webp"
)

splendor.picture.attach(
  io: file,
  filename: "splendor_kk9den.webp",
  content_type: "image/webp"
)

puts "#{Game.count} jeux créés - ok."
puts "Seed Finished!"
