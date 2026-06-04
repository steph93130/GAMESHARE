require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    Geocoder::Lookup::Test.add_stub("10 rue de Rivoli, Paris", [
      { "coordinates" => [48.8566, 2.3522], "address" => "10 rue de Rivoli, Paris" }
    ])
    Geocoder::Lookup::Test.add_stub("5 avenue Montaigne, Paris", [
      { "coordinates" => [48.8656, 2.3031], "address" => "5 avenue Montaigne, Paris" }
    ])
  end

  test "mise à jour adresse user cascade l'adresse aux jeux" do
    user = User.create!(username: "alice", email: "alice@example.com", password: "password123",
                        address: "10 rue de Rivoli, Paris")
    game = user.games.create!(title: "Catan")

    user.update!(address: "5 avenue Montaigne, Paris")

    assert_equal "5 avenue Montaigne, Paris", game.reload.address
  end

  test "mise à jour adresse user déclenche le geocoding sur les jeux" do
    user = User.create!(username: "bob", email: "bob@example.com", password: "password123",
                        address: "10 rue de Rivoli, Paris")
    game = user.games.create!(title: "Scrabble")

    user.update!(address: "5 avenue Montaigne, Paris")

    game.reload
    assert_in_delta 48.8656, game.lat, 0.001
    assert_in_delta 2.3031, game.lng, 0.001
  end

  test "sans changement d'adresse, les jeux ne sont pas modifiés" do
    user = User.create!(username: "carol", email: "carol@example.com", password: "password123",
                        address: "10 rue de Rivoli, Paris")
    game = user.games.create!(title: "Uno")
    original_updated_at = game.updated_at

    user.update!(username: "carol2")

    assert_equal original_updated_at, game.reload.updated_at
  end
end
