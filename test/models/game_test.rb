require "test_helper"

class GameTest < ActiveSupport::TestCase
  setup do
    Geocoder::Lookup::Test.add_stub("10 rue de Rivoli, Paris", [
      { "coordinates" => [48.8566, 2.3522], "address" => "10 rue de Rivoli, Paris" }
    ])
    @user = User.create!(username: "dave", email: "dave@example.com", password: "password123",
                         address: "10 rue de Rivoli, Paris")
  end

  test "un jeu hérite automatiquement de l'adresse de son user" do
    game = Game.create!(title: "Chess", user: @user)

    assert_equal "10 rue de Rivoli, Paris", game.address
  end

  test "un jeu créé sans adresse est quand même géocodé via l'adresse du user" do
    game = Game.create!(title: "Chess", user: @user)

    assert_in_delta 48.8566, game.lat, 0.001
    assert_in_delta 2.3522, game.lng, 0.001
  end
end
