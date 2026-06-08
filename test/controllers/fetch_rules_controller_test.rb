require "test_helper"

class FetchRulesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(
      email: "testia_fetch@example.com",
      password: "password123",
      username: "testia_fetch",
      address: "Paris, France",
      rating: 3.0
    )
    # Initialise Warden avant sign_in (obligatoire pour que la session persiste)
    get games_path
    sign_in @user
  end

  teardown do
    @user.destroy
  end

  # ─── 3 jeux × modal owner ───────────────────────────────────────────────────

  test "[owner] Catan : fetch_rules renvoie les règles HTML (200)" do
    stub_llm("Catan") do
      post fetch_rules_games_path, params: { title: "Catan" }
      assert_response :success, "Attendu 200, reçu #{response.status}: #{response.body[0..80]}"
      json = JSON.parse(response.body)
      assert json.key?("rules"), "Clé 'rules' absente de la réponse"
      assert json["rules"].include?("Catan"), "Le nom du jeu doit apparaître dans les règles"
      puts "\n[owner] Catan → HTTP #{response.status} | #{json['rules'][0..70]}..."
    end
  end

  test "[owner] 7 Wonders : fetch_rules renvoie les règles HTML (200)" do
    stub_llm("7 Wonders") do
      post fetch_rules_games_path, params: { title: "7 Wonders" }
      assert_response :success
      json = JSON.parse(response.body)
      assert json.key?("rules")
      assert json["rules"].include?("7 Wonders")
      puts "\n[owner] 7 Wonders → HTTP #{response.status} | #{json['rules'][0..70]}..."
    end
  end

  test "[owner] Ticket to Ride : fetch_rules renvoie les règles HTML (200)" do
    stub_llm("Ticket to Ride") do
      post fetch_rules_games_path, params: { title: "Ticket to Ride" }
      assert_response :success
      json = JSON.parse(response.body)
      assert json.key?("rules")
      assert json["rules"].include?("Ticket to Ride")
      puts "\n[owner] Ticket to Ride → HTTP #{response.status} | #{json['rules'][0..70]}..."
    end
  end

  # ─── 3 jeux × modal borrow ──────────────────────────────────────────────────

  test "[borrow] Pandemic : fetch_rules renvoie les règles HTML (200)" do
    stub_llm("Pandemic") do
      post fetch_rules_games_path, params: { title: "Pandemic" }
      assert_response :success
      json = JSON.parse(response.body)
      assert json.key?("rules")
      assert json["rules"].include?("Pandemic")
      puts "\n[borrow] Pandemic → HTTP #{response.status} | #{json['rules'][0..70]}..."
    end
  end

  test "[borrow] Terraforming Mars : fetch_rules renvoie les règles HTML (200)" do
    stub_llm("Terraforming Mars") do
      post fetch_rules_games_path, params: { title: "Terraforming Mars" }
      assert_response :success
      json = JSON.parse(response.body)
      assert json.key?("rules")
      assert json["rules"].include?("Terraforming Mars")
      puts "\n[borrow] Terraforming Mars → HTTP #{response.status} | #{json['rules'][0..70]}..."
    end
  end

  test "[borrow] Azul : fetch_rules renvoie les règles HTML (200)" do
    stub_llm("Azul") do
      post fetch_rules_games_path, params: { title: "Azul" }
      assert_response :success
      json = JSON.parse(response.body)
      assert json.key?("rules")
      assert json["rules"].include?("Azul")
      puts "\n[borrow] Azul → HTTP #{response.status} | #{json['rules'][0..70]}..."
    end
  end

  # ─── 3 jeux × modal show (profil) ───────────────────────────────────────────

  test "[show] Wingspan : fetch_rules renvoie les règles HTML (200)" do
    stub_llm("Wingspan") do
      post fetch_rules_games_path, params: { title: "Wingspan" }
      assert_response :success
      json = JSON.parse(response.body)
      assert json.key?("rules")
      assert json["rules"].include?("Wingspan")
      puts "\n[show] Wingspan → HTTP #{response.status} | #{json['rules'][0..70]}..."
    end
  end

  test "[show] Dixit : fetch_rules renvoie les règles HTML (200)" do
    stub_llm("Dixit") do
      post fetch_rules_games_path, params: { title: "Dixit" }
      assert_response :success
      json = JSON.parse(response.body)
      assert json.key?("rules")
      assert json["rules"].include?("Dixit")
      puts "\n[show] Dixit → HTTP #{response.status} | #{json['rules'][0..70]}..."
    end
  end

  test "[show] Splendor : fetch_rules renvoie les règles HTML (200)" do
    stub_llm("Splendor") do
      post fetch_rules_games_path, params: { title: "Splendor" }
      assert_response :success
      json = JSON.parse(response.body)
      assert json.key?("rules")
      assert json["rules"].include?("Splendor")
      puts "\n[show] Splendor → HTTP #{response.status} | #{json['rules'][0..70]}..."
    end
  end

  # ─── Cas d'erreur ───────────────────────────────────────────────────────────

  test "titre vide renvoie 400 avec message d'erreur JSON" do
    stub_llm("") do
      post fetch_rules_games_path, params: { title: "" }
      assert_response :bad_request
      json = JSON.parse(response.body)
      assert json.key?("error"), "Un message d'erreur est attendu"
      puts "\n[erreur] titre vide → HTTP #{response.status} | #{json['error']}"
    end
  end

  # ─── Diagnostic : les 3 pages profil contiennent DOMContentLoaded mais pas turbo:load ─────

  test "[diagnostic owner] page owner contient DOMContentLoaded — incompatible Turbo Drive" do
    get owner_path
    assert_response :success, "La page owner doit se charger (HTTP #{response.status})"
    assert_match "fetch-rules-btn", response.body, "Le bouton IA doit être dans la page owner"

    dom_loaded  = response.body.include?("DOMContentLoaded")
    turbo_load  = response.body.include?("turbo:load")

    puts "\n[diagnostic owner] DOMContentLoaded=#{dom_loaded} | turbo:load=#{turbo_load}"
    assert dom_loaded,      "Script DOMContentLoaded présent dans owner (cause du bug)"
    assert_not turbo_load,  "turbo:load absent → bouton inactif après navigation Turbo"
  end

  test "[diagnostic borrow] page borrow contient DOMContentLoaded — incompatible Turbo Drive" do
    get borrow_path
    assert_response :success, "La page borrow doit se charger (HTTP #{response.status})"
    assert_match "fetch-rules-btn", response.body

    dom_loaded  = response.body.include?("DOMContentLoaded")
    turbo_load  = response.body.include?("turbo:load")

    puts "\n[diagnostic borrow] DOMContentLoaded=#{dom_loaded} | turbo:load=#{turbo_load}"
    assert dom_loaded
    assert_not turbo_load
  end

  test "[diagnostic show] page profil contient DOMContentLoaded — incompatible Turbo Drive" do
    get profile_path
    assert_response :success, "La page profil doit se charger (HTTP #{response.status})"
    assert_match "fetch-rules-btn", response.body

    dom_loaded  = response.body.include?("DOMContentLoaded")
    turbo_load  = response.body.include?("turbo:load")

    puts "\n[diagnostic show] DOMContentLoaded=#{dom_loaded} | turbo:load=#{turbo_load}"
    assert dom_loaded
    assert_not turbo_load
  end

  private

  # Remplace temporairement RubyLLM.chat par un stub pour éviter les appels OpenAI
  def stub_llm(title)
    fake_content  = "<h3>Objectif</h3><p>Règles de #{title} (stub test).</p>"
    fake_response = Object.new
    fake_response.define_singleton_method(:content) { fake_content }
    fake_chat     = Object.new
    fake_chat.define_singleton_method(:ask) { |*_a, **_k| fake_response }

    original = RubyLLM.method(:chat)
    RubyLLM.define_singleton_method(:chat) { |**_opts| fake_chat }
    yield
  ensure
    RubyLLM.define_singleton_method(:chat, original)
  end
end
