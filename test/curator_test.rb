require 'minitest/autorun'
require 'minitest/pride'
require './lib/curator'

class CuratorTest < Minitest::Test
  def setup
    @curator = Curator.new
    @photo_1 = Photograph.new({
      id: "1",
      name: "Rue Mouffetard, Paris (Boy with Bottles)",
      artist_id: "1",
      year: "1954"
    })
    @photo_2 = Photograph.new({
      id: "2",
      name: "Moonrise, Hernandez",
      artist_id: "2",
      year: "1941"
    })
    @photo_3 = Photograph.new({
      id: "3",
      name: "Identical Twins, Roselle, New Jersey",
      artist_id: "3",
      year: "1967"
    })
    @photo_4 = Photograph.new({
      id: "4",
      name: "Monolith, The Face of Half Dome",
      artist_id: "3",
      year: "1927"
    })
    @artist_1 = Artist.new({
      id: "1",
      name: "Henri Cartier-Bresson",
      born: "1908",
      died: "2004",
      country: "France"
    })
    @artist_2 = Artist.new({
      id: "2",
      name: "Ansel Adams",
      born: "1902",
      died: "1984",
      country: "United States"
    })
    @artist_3 = Artist.new({
      id: "3",
      name: "Diane Arbus",
      born: "1923",
      died: "1971",
      country: "United States"
    })
  end

  def test_it_exists
    assert_instance_of Curator, @curator
  end

  def test_it_inits_with_empty_arys_of_photographs_and_artists
    assert_equal [], @curator.photographs
    assert_equal [], @curator.artists
  end

  def test_add_photograph_adds_to_photographs_ary
    @curator.add_photograph(@photo_1)
    @curator.add_photograph(@photo_2)

    assert_equal [@photo_1, @photo_2], @curator.photographs
  end

  def test_add_artist_adds_to_artists_ary
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)

    assert_equal [@artist_1, @artist_2], @curator.artists
  end

  def test_find_artist_by_id_returns_artist_object_with_given_id
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)

    assert_equal @artist_1, @curator.find_artist_by_id("1")
  end

  def test_add_photograph_adds_to_photographs_ary
    @curator.add_photograph(@photo_1)
    @curator.add_photograph(@photo_2)

    assert_equal @photo_2, @curator.find_photograph_by_id("2")
  end

  def test_find_photographs_by_artist_returns_ary_of_all_of_an_artists_photos
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)
    @curator.add_photograph(@photo_1)
    @curator.add_photograph(@photo_2)
    @curator.add_photograph(@photo_3)
    @curator.add_photograph(@photo_4)

    expected = [@photo_3, @photo_4]

    assert_equal expected, @curator.find_photographs_by_artist(@artist_3)
  end

  def test_artists_with_multiple_photographs_returns_ary_of_artist_objs
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)
    @curator.add_photograph(@photo_1)
    @curator.add_photograph(@photo_2)
    @curator.add_photograph(@photo_3)
    @curator.add_photograph(@photo_4)

    assert_equal [@artist_3], @curator.artists_with_multiple_photographs
  end

  def test_photographs_taken_by_artists_from_returns_ary_of_photos_taken_by_photogs_from_that_country
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)
    @curator.add_photograph(@photo_1)
    @curator.add_photograph(@photo_2)
    @curator.add_photograph(@photo_3)
    @curator.add_photograph(@photo_4)

    actual = @curator.photographs_taken_by_artist_from("United States")

    assert_equal [@photo_2, @photo_3, @photo_4], actual
    assert_equal [], @curator.photographs_taken_by_artist_from("Argentina")
  end

  def test_load_photographs_makes_photo_objs_and_adds_them_to_photographs_ary
    @curator.load_photographs('./data/photographs.csv')

    expected_names = [
      "Rue Mouffetard, Paris (Boy with Bottles)",
      "Moonrise, Hernandez",
      "Identical Twins, Roselle, New Jersey",
      "Monolith, The Face of Half Dome"
    ]

    expected_years = ["1954", "1941", "1967", "1927"]

    assert_equal ["1", "2", "3", "4"], @curator.photographs.map(&:id)
    assert_equal expected_names, @curator.photographs.map(&:name)
    assert_equal ["1", "2", "3", "3"], @curator.photographs.map(&:artist_id)
    assert_equal expected_years, @curator.photographs.map(&:year)
  end

  def test_load_artists_makes_artist_objs_and_adds_them_to_artists_ary
    @curator.load_artists('./data/artists.csv')

    expected_countries = ["France", "United States", "United States"]

    assert_equal ["1", "2", "3"], @curator.artists.map(&:id)
    assert_equal ["Henri Cartier-Bresson", "Ansel Adams", "Diane Arbus"], @curator.artists.map(&:name)
    assert_equal ["1908", "1902", "1923"], @curator.artists.map(&:born)
    assert_equal ["2004", "1984", "1971"], @curator.artists.map(&:died)
    assert_equal expected_countries, @curator.artists.map(&:country)
  end

  def test_photographs_taken_between_returns_ary_of_photos_w_year_in_that_range
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)
    @curator.add_photograph(@photo_1)
    @curator.add_photograph(@photo_2)
    @curator.add_photograph(@photo_3)
    @curator.add_photograph(@photo_4)

    assert_equal [@photo_1], @curator.photographs_taken_between(1950..1965)
  end

  def test_artists_photographs_by_age_is_hash_of_artist_ages_and_photo_names
    @curator.load_photographs('./data/photographs_amy.csv')
    @curator.load_artists('./data/artists_amy.csv')

    diane_arbus = @curator.find_artist_by_id("3")

    expected = {
      44=>"Identical Twins, Roselle, New Jersey",
      39=>"Child with Toy Hand Grenade in Central Park"
    }

    assert_equal expected, @curator.artists_photographs_by_age(diane_arbus)
  end
end
