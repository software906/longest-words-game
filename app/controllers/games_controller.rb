require "open-uri"
require "json"

class GamesController < ApplicationController
  def new
    @array_letras = getwords
  end

  def score
    @word = params[:word]
    @time = Time.now - params[:tiempo_ini].to_datetime
    @a = params[:grid].split(",")
    @resultado = run_game(@word, @a, @time)
    @score = @resultado[:score]
    @mensaje = @resultado[:message]
  end

  private

  def getwords
    letters = ('A'..'Z').to_a
    array = (0...10).map { letters.sample }
    return array
  end

  def run_game(attempt, grid, time)
    validacion_gird = validacion(attempt, grid)
    consulta_json = JSON.parse(URI.open("https://wagon-dictionary.herokuapp.com/#{attempt}").read)
    # attempt == english_word?(attempt)
    resultado(consulta_json, validacion_gird, time)
  end

  def english_word?(word)
    repon = URI.open("https://wagon-dictionary.herokuapp.com/#{word}")
    jason = JSON.parse(respon.read)
    jason["found"]
  end

  def validacion(attempt, grid)
    attempt_a = attempt.upcase.chars
    validacion_gird = attempt_a.all? do |letra|
      grid.include?(letra) ? grid.delete_at(grid.index(letra) || grid.length) : false
    end
    return validacion_gird
  end

  def resultado(consulta_json, validacion_gird, time)
    result = {}
    if consulta_json["found"] && validacion_gird
      score = consulta_json["length"] + (100 / time)
      result = { time: time, score: score, message: "well done" }
    elsif validacion_gird
      result = { time: time, score: 0, message: "not an english word" }
    else
      result = { time: time, score: 0, message: "not in the grid" }
    end
    return result
  end
end
